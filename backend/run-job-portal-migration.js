require('dotenv').config();
const mysql = require('mysql2/promise');
const fs = require('fs').promises;
const path = require('path');

async function runJobPortalMigration() {
  let connection;
  
  try {
    console.log('Connecting to database...');
    connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      port: process.env.DB_PORT || 3306,
      multipleStatements: true
    });
    
    console.log('✓ Connected to database');
    
    // Read the migration file
    const migrationPath = path.join(__dirname, 'migrations', 'add_job_portal_fields.sql');
    const migrationSQL = await fs.readFile(migrationPath, 'utf8');
    
    console.log('\nRunning job portal migration...');
    console.log('Migration SQL:', migrationSQL);
    
    // Execute the migration
    await connection.query(migrationSQL);
    
    console.log('✓ Job portal fields migration completed successfully');
    
    // Verify the changes
    const [columns] = await connection.query(`
      SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
      FROM INFORMATION_SCHEMA.COLUMNS
      WHERE TABLE_SCHEMA = ? AND TABLE_NAME = 'jobs'
      ORDER BY ORDINAL_POSITION
    `, [process.env.DB_NAME]);
    
    console.log('\n✓ Jobs table structure:');
    columns.forEach(col => {
      console.log(`  - ${col.COLUMN_NAME}: ${col.DATA_TYPE} ${col.IS_NULLABLE === 'YES' ? 'NULL' : 'NOT NULL'} ${col.COLUMN_DEFAULT ? `DEFAULT ${col.COLUMN_DEFAULT}` : ''}`);
    });
    
  } catch (error) {
    console.error('✗ Migration failed:', error.message);
    process.exit(1);
  } finally {
    if (connection) {
      await connection.end();
      console.log('\n✓ Database connection closed');
    }
  }
}

runJobPortalMigration();
