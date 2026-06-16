require('dotenv').config();
const mysql = require('mysql2/promise');
const { execSync } = require('child_process');

async function checkDatabase() {
  console.log('Checking database connection...');
  
  try {
    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      port: process.env.DB_PORT || 3306
    });

    console.log('✓ MySQL connection successful');

    // Check if database exists
    const [databases] = await connection.execute(
      `SHOW DATABASES LIKE '${process.env.DB_NAME}'`
    );

    if (databases.length === 0) {
      console.log(`\n⚠ Database '${process.env.DB_NAME}' does not exist`);
      console.log('Creating database...');
      await connection.execute(`CREATE DATABASE ${process.env.DB_NAME}`);
      console.log(`✓ Database '${process.env.DB_NAME}' created`);
    } else {
      console.log(`✓ Database '${process.env.DB_NAME}' exists`);
    }

    await connection.end();

    // Now connect to the specific database
    const dbConnection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      port: process.env.DB_PORT || 3306
    });

    // Check if tables exist
    const tables = ['users', 'vendors', 'drivers'];
    const missingTables = [];

    for (const table of tables) {
      const [rows] = await dbConnection.execute(`SHOW TABLES LIKE '${table}'`);
      if (rows.length === 0) {
        missingTables.push(table);
      }
    }

    if (missingTables.length > 0) {
      console.log(`\n⚠ Missing tables: ${missingTables.join(', ')}`);
      console.log('Running migrations...');
      
      try {
        execSync('node migrations/run.js', { 
          stdio: 'inherit',
          cwd: __dirname
        });
        console.log('✓ Migrations completed');
      } catch (error) {
        console.error('✗ Migration failed:', error.message);
        process.exit(1);
      }
    } else {
      console.log('✓ All required tables exist');
    }

    await dbConnection.end();
    return true;
  } catch (error) {
    console.error('✗ Database check failed:', error.message);
    console.error('\nPlease ensure:');
    console.error('1. MySQL server is running');
    console.error('2. Credentials in .env file are correct');
    console.error('3. MySQL user has proper permissions');
    return false;
  }
}

async function startServer() {
  console.log('\n╔════════════════════════════════════════════════╗');
  console.log('║   Nafaj Backend Server Startup                 ║');
  console.log('╚════════════════════════════════════════════════╝\n');

  const dbOk = await checkDatabase();
  
  if (!dbOk) {
    console.error('\n✗ Cannot start server due to database issues');
    process.exit(1);
  }

  console.log('\n✓ All checks passed! Starting server...\n');
  
  // Start the actual server
  require('./src/server');
}

startServer();
