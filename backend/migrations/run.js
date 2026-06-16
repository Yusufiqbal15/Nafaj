const fs = require('fs');
const path = require('path');
const pool = require('../src/config/database');

const migrationFiles = [
  'migration_users_table.sql',
  'migration_drivers_table.sql',
  'migration_vendors_table.sql',
  'migration_categories_table.sql',
  'migration_products_table.sql',
  'migration_orders_table.sql',
  'migration_jobs_table.sql',
  'migration_cart_table.sql'
];

async function runMigrations() {
  try {
    console.log('Starting database migrations...\n');

    for (const file of migrationFiles) {
      const filePath = path.join(__dirname, file);

      if (!fs.existsSync(filePath)) {
        console.log(`⚠ Skipping ${file} - file not found`);
        continue;
      }

      const sql = fs.readFileSync(filePath, 'utf8');
      const statements = sql.split(';').filter(s => s.trim());

      for (const statement of statements) {
        if (statement.trim()) {
          await pool.execute(statement);
        }
      }

      console.log(`✓ Completed: ${file}`);
    }

    console.log('\n✓ All migrations completed successfully');
    process.exit(0);
  } catch (error) {
    console.error('✗ Migration failed:', error.message);
    process.exit(1);
  }
}

runMigrations();
