const mysql = require('mysql2/promise');
require('dotenv').config();

// Parse Railway's MYSQL_URL if available, otherwise use individual env vars
function getDbConfig() {
  const mysqlUrl = process.env.MYSQL_URL || process.env.MYSQL_PUBLIC_URL;

  if (mysqlUrl) {
    try {
      const url = new URL(mysqlUrl);
      return {
        host: url.hostname,
        user: decodeURIComponent(url.username),
        password: decodeURIComponent(url.password),
        database: url.pathname.replace(/^\//, ''),
        port: parseInt(url.port) || 3306,
      };
    } catch (e) {
      console.error('Failed to parse MYSQL_URL, falling back to individual env vars');
    }
  }

  return {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: parseInt(process.env.DB_PORT) || 3306,
  };
}

const dbConfig = getDbConfig();

const pool = mysql.createPool({
  ...dbConfig,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  connectTimeout: 10000,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0
});

// Test connection with retry logic
const testConnection = async (retries = 3) => {
  for (let i = 0; i < retries; i++) {
    try {
      const connection = await pool.getConnection();
      console.log('✓ MySQL Database Connected Successfully');
      console.log(`  Host: ${dbConfig.host}`);
      console.log(`  Database: ${dbConfig.database}`);
      connection.release();
      return true;
    } catch (error) {
      console.error(`✗ Database Connection Attempt ${i + 1}/${retries} Failed:`, error.message);
      if (i === retries - 1) {
        console.error('✗ Could not connect to database. Please check:');
        console.error('  1. MySQL server is running');
        console.error('  2. Database credentials are correct');
        console.error('  3. Database exists');
        process.exit(1);
      }
      await new Promise(resolve => setTimeout(resolve, 2000));
    }
  }
};

testConnection();

module.exports = pool;
