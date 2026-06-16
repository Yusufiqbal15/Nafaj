const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT || 3306,
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
      console.log(`  Host: ${process.env.DB_HOST}`);
      console.log(`  Database: ${process.env.DB_NAME}`);
      connection.release();
      return true;
    } catch (error) {
      console.error(`✗ Database Connection Attempt ${i + 1}/${retries} Failed:`, error.message);
      if (i === retries - 1) {
        console.error('✗ Could not connect to database. Please check:');
        console.error('  1. MySQL server is running');
        console.error('  2. Database credentials in .env file are correct');
        console.error('  3. Database "nafaj" exists');
        console.error('  4. Run migrations if tables are missing');
        process.exit(1);
      }
      // Wait 2 seconds before retry
      await new Promise(resolve => setTimeout(resolve, 2000));
    }
  }
};

testConnection();

module.exports = pool;
