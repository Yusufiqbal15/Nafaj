const mysql = require('mysql2/promise');
require('dotenv').config();

function getDbConfig() {
  const mysqlUrl = process.env.MYSQL_URL || process.env.MYSQL_PUBLIC_URL;

  if (mysqlUrl) {
    try {
      const url = new URL(mysqlUrl);
      console.log(`Connecting via URL to: ${url.hostname}:${url.port}`);
      return {
        host: url.hostname,
        user: decodeURIComponent(url.username),
        password: decodeURIComponent(url.password),
        database: url.pathname.replace(/^\//, ''),
        port: parseInt(url.port) || 3306,
        ssl: { rejectUnauthorized: false }
      };
    } catch (e) {
      console.error('Failed to parse MYSQL_URL:', e.message);
    }
  }

  console.log(`Connecting via env vars to: ${process.env.DB_HOST}:${process.env.DB_PORT}`);
  return {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: parseInt(process.env.DB_PORT) || 3306,
    ssl: process.env.DB_HOST && !process.env.DB_HOST.includes('localhost') && !process.env.DB_HOST.includes('127.0.0.1') && !process.env.DB_HOST.includes('railway.internal')
      ? { rejectUnauthorized: false }
      : false
  };
}

const dbConfig = getDbConfig();

const pool = mysql.createPool({
  ...dbConfig,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  connectTimeout: 30000,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0
});

const testConnection = async (retries = 5) => {
  for (let i = 0; i < retries; i++) {
    try {
      const connection = await pool.getConnection();
      console.log('✓ MySQL Database Connected Successfully');
      console.log(`  Host: ${dbConfig.host}:${dbConfig.port}`);
      console.log(`  Database: ${dbConfig.database}`);
      connection.release();
      return true;
    } catch (error) {
      console.error(`✗ Database Connection Attempt ${i + 1}/${retries} Failed:`, error.message);
      if (i === retries - 1) {
        console.error('✗ Could not connect to database after all retries');
        process.exit(1);
      }
      await new Promise(resolve => setTimeout(resolve, 3000));
    }
  }
};

testConnection();

module.exports = pool;
