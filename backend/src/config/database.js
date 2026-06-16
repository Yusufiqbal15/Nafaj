const mysql = require('mysql2/promise');
require('dotenv').config();

// ─── Env variable resolution ────────────────────────────────────────────────
// Railway can inject the DB name under several different key names.
// We check all known variants in priority order.
function resolveDbName() {
  const candidates = [
    ['MYSQL_DATABASE',  process.env.MYSQL_DATABASE],
    ['MYSQLDATABASE',   process.env.MYSQLDATABASE],
    ['DB_NAME',         process.env.DB_NAME],
    ['DATABASE_URL',    null], // handled separately via URL parse
  ];

  for (const [key, val] of candidates) {
    if (val) {
      console.log(`  DB_NAME source  : ${key} = "${val}"`);
      return val;
    }
  }

  // Try to extract from DATABASE_URL / MYSQL_URL
  const rawUrl = process.env.DATABASE_URL || process.env.MYSQL_URL || process.env.MYSQL_PUBLIC_URL;
  if (rawUrl) {
    try {
      const dbFromUrl = new URL(rawUrl).pathname.replace(/^\//, '');
      if (dbFromUrl) {
        console.log(`  DB_NAME source  : URL pathname = "${dbFromUrl}"`);
        return dbFromUrl;
      }
    } catch (_) {}
  }

  console.warn('  DB_NAME source  : NONE FOUND — will attempt connection without database');
  return null;
}

// ─── Build connection config ─────────────────────────────────────────────────
function getDbConfig() {
  console.log('\n══════════════════════════════════════════════');
  console.log('  DATABASE CONFIGURATION STARTUP CHECK');
  console.log('══════════════════════════════════════════════');

  // Log every relevant env variable so Railway logs are unambiguous
  console.log('  Env variables received:');
  console.log(`    MYSQL_URL        : ${process.env.MYSQL_URL        ? '[SET]' : '[NOT SET]'}`);
  console.log(`    MYSQL_PUBLIC_URL : ${process.env.MYSQL_PUBLIC_URL ? '[SET]' : '[NOT SET]'}`);
  console.log(`    DATABASE_URL     : ${process.env.DATABASE_URL     ? '[SET]' : '[NOT SET]'}`);
  console.log(`    MYSQL_DATABASE   : ${process.env.MYSQL_DATABASE   || '[NOT SET]'}`);
  console.log(`    MYSQLDATABASE    : ${process.env.MYSQLDATABASE    || '[NOT SET]'}`);
  console.log(`    DB_HOST          : ${process.env.DB_HOST          || '[NOT SET]'}`);
  console.log(`    DB_PORT          : ${process.env.DB_PORT          || '[NOT SET]'}`);
  console.log(`    DB_USER          : ${process.env.DB_USER          || '[NOT SET]'}`);
  console.log(`    DB_NAME          : ${process.env.DB_NAME          || '[NOT SET]'}`);
  console.log(`    DB_PASSWORD      : ${process.env.DB_PASSWORD      ? '[SET]' : '[NOT SET]'}`);
  console.log('──────────────────────────────────────────────');

  // URL-based config takes priority (Railway plugin auto-injects MYSQL_URL)
  const rawUrl = process.env.MYSQL_URL || process.env.MYSQL_PUBLIC_URL;
  if (rawUrl) {
    try {
      const url = new URL(rawUrl);
      const dbName = url.pathname.replace(/^\//, '') || resolveDbName();
      const cfg = {
        host:     url.hostname,
        user:     decodeURIComponent(url.username),
        password: decodeURIComponent(url.password),
        database: dbName,
        port:     parseInt(url.port) || 3306,
        ssl:      { rejectUnauthorized: false },
      };
      console.log(`  Config source   : MYSQL_URL`);
      console.log(`  DB_HOST         : ${cfg.host}`);
      console.log(`  DB_PORT         : ${cfg.port}`);
      console.log(`  DB_USER         : ${cfg.user}`);
      console.log(`  DB_NAME         : ${cfg.database}`);
      console.log('══════════════════════════════════════════════\n');
      return cfg;
    } catch (e) {
      console.error('  Failed to parse MYSQL_URL:', e.message);
    }
  }

  // Fallback: individual env vars
  const dbName = resolveDbName();
  const host   = process.env.DB_HOST || 'localhost';
  const port   = parseInt(process.env.DB_PORT) || 3306;

  // Detect public-proxy-from-inside-Railway misconfiguration.
  // railway.internal is the private network; metro.proxy.rlwy.net is the public proxy.
  // Railway blocks connections from its own services to the public proxy (causes TCP_INVALID_SYN).
  const isPublicProxyFromRailway =
    process.env.RAILWAY_ENVIRONMENT &&
    host.includes('rlwy.net');
  if (isPublicProxyFromRailway) {
    console.warn('⚠ WARNING: DB_HOST points to Railway public proxy (*.rlwy.net)');
    console.warn('  but this app is running INSIDE Railway.');
    console.warn('  Set DB_HOST=mysql.railway.internal and DB_PORT=3306 in Railway Variables.');
  }

  const useSSL = host && !host.includes('localhost') && !host.includes('127.0.0.1') && !host.includes('railway.internal');

  const cfg = {
    host,
    user:     process.env.DB_USER     || 'root',
    password: process.env.DB_PASSWORD || '',
    database: dbName,
    port,
    ssl:      useSSL ? { rejectUnauthorized: false } : false,
  };

  console.log(`  Config source   : individual env vars`);
  console.log(`  DB_HOST         : ${cfg.host}`);
  console.log(`  DB_PORT         : ${cfg.port}`);
  console.log(`  DB_USER         : ${cfg.user}`);
  console.log(`  DB_NAME         : ${cfg.database || '(none)'}`);
  console.log(`  SSL             : ${useSSL ? 'enabled' : 'disabled'}`);
  console.log('══════════════════════════════════════════════\n');
  return cfg;
}

const dbConfig = getDbConfig();

// ─── Pool (used by all controllers) ──────────────────────────────────────────
const pool = mysql.createPool({
  ...dbConfig,
  waitForConnections: true,
  connectionLimit:    10,
  queueLimit:         0,
  connectTimeout:     30000,
  enableKeepAlive:    true,
  keepAliveInitialDelay: 0,
});

// ─── Startup: verify DB exists, create it if missing ─────────────────────────
const initDatabase = async (retries = 5) => {
  const targetDb = dbConfig.database;

  for (let attempt = 1; attempt <= retries; attempt++) {
    // Connect WITHOUT specifying a database first so we can run SHOW DATABASES
    let rootConn;
    try {
      rootConn = await mysql.createConnection({
        host:     dbConfig.host,
        port:     dbConfig.port,
        user:     dbConfig.user,
        password: dbConfig.password,
        ssl:      dbConfig.ssl,
        connectTimeout: 30000,
      });
    } catch (err) {
      console.error(`✗ [${attempt}/${retries}] Cannot reach MySQL server: ${err.message}`);
      if (attempt === retries) {
        console.error('✗ Server unreachable after all retries — app will continue without DB');
        return false;
      }
      await new Promise(r => setTimeout(r, 3000));
      continue;
    }

    try {
      // Check which databases exist
      const [rows] = await rootConn.query('SHOW DATABASES;');
      const available = rows.map(r => Object.values(r)[0]);
      console.log(`  Available databases on server: [${available.join(', ')}]`);

      if (!targetDb) {
        console.error('✗ DB_NAME / MYSQL_DATABASE is not set — cannot select a database.');
        console.error('  Set DB_NAME in Railway Variables and redeploy.');
        await rootConn.end();
        return false;
      }

      if (!available.includes(targetDb)) {
        // ── Database does not exist — create it ──────────────────────────────
        console.warn(`⚠ Database "${targetDb}" NOT FOUND on server.`);
        console.warn(`  WHY THIS HAPPENS: Railway MySQL is a blank instance; the`);
        console.warn(`  database must be created before first use.`);
        console.warn(`  → Auto-creating database "${targetDb}" now…`);

        await rootConn.query(`CREATE DATABASE IF NOT EXISTS \`${targetDb}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`);
        console.log(`✓ Database "${targetDb}" created successfully.`);
      } else {
        console.log(`✓ Database "${targetDb}" exists.`);
      }

      await rootConn.end();

      // Now test the pool (which has the DB name set)
      const conn = await pool.getConnection();
      console.log(`✓ Pool connected to "${targetDb}" successfully.`);
      conn.release();
      return true;

    } catch (err) {
      console.error(`✗ [${attempt}/${retries}] DB init error: ${err.message}`);
      try { await rootConn.end(); } catch (_) {}

      if (attempt === retries) {
        console.error('✗ Could not initialize database after all retries — app will keep running');
        return false;
      }
      await new Promise(r => setTimeout(r, 3000));
    }
  }
};

// .catch() is mandatory — Node 18 crashes the entire process on unhandled
// promise rejections. initDatabase() has internal try/catch but this is a
// safety net for any unexpected throw that escapes the function.
initDatabase().catch((err) => {
  console.error('═══ initDatabase threw unexpectedly (process kept alive) ═══');
  console.error(err.message);
});

module.exports = pool;
