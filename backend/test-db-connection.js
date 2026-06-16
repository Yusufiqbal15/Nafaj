require('dotenv').config();
const mysql = require('mysql2/promise');

async function testDatabaseConnection() {
  console.log('Testing Database Connection...\n');
  
  try {
    // Test connection
    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      port: process.env.DB_PORT || 3306
    });

    console.log('✓ Database connection successful!');
    console.log(`  Host: ${process.env.DB_HOST}`);
    console.log(`  Database: ${process.env.DB_NAME}\n`);

    // Check if tables exist
    const tables = ['users', 'vendors', 'drivers'];
    console.log('Checking tables...\n');

    for (const table of tables) {
      try {
        const [rows] = await connection.execute(`SHOW TABLES LIKE '${table}'`);
        if (rows.length > 0) {
          console.log(`✓ Table '${table}' exists`);
          
          // Get table structure
          const [columns] = await connection.execute(`DESCRIBE ${table}`);
          console.log(`  Columns: ${columns.map(c => c.Field).join(', ')}`);
        } else {
          console.log(`✗ Table '${table}' NOT FOUND`);
        }
      } catch (error) {
        console.log(`✗ Error checking table '${table}':`, error.message);
      }
    }

    await connection.end();
    console.log('\n✓ Test completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('✗ Database connection failed:', error.message);
    console.error('\nPlease check:');
    console.error('1. MySQL server is running');
    console.error('2. Database credentials in .env file are correct');
    console.error('3. Database "nafaj" exists');
    console.error('4. Run migrations: node migrations/run.js');
    process.exit(1);
  }
}

testDatabaseConnection();
