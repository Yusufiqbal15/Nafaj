const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

async function runMigration() {
  let connection;
  
  try {
    // Create database connection
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_NAME || 'nafaj_db',
      multipleStatements: true
    });

    console.log('📦 Connected to database');

    // Read migration file
    const migrationPath = path.join(__dirname, 'migrations', 'add_pending_confirmation_status.sql');
    const migrationSQL = fs.readFileSync(migrationPath, 'utf8');

    console.log('🔄 Running pending_confirmation status migration...');
    await connection.query(migrationSQL);
    
    console.log('✅ Migration completed successfully!');
    console.log('✅ Added pending_confirmation and out_for_delivery statuses to orders table');

  } catch (error) {
    console.error('❌ Migration failed:', error.message);
    process.exit(1);
  } finally {
    if (connection) {
      await connection.end();
      console.log('📦 Database connection closed');
    }
  }
}

runMigration();
