const pool = require('./src/config/database');

async function runMigration() {
  try {
    console.log('🔄 Running vendor confirmation workflow migration...');

    await pool.execute(`
      ALTER TABLE orders
      MODIFY COLUMN order_status ENUM(
        'pending_vendor_confirmation',
        'vendor_confirmed',
        'driver_assigned',
        'pending',
        'confirmed',
        'preparing',
        'ready',
        'picked_up',
        'out_for_delivery',
        'pending_confirmation',
        'delivered',
        'cancelled'
      ) DEFAULT 'pending_vendor_confirmation'
    `);
    console.log('✅ order_status ENUM updated with new statuses');

    // Add vendor_confirmed_at column (ignore if already exists)
    try {
      await pool.execute(`
        ALTER TABLE orders
        ADD COLUMN vendor_confirmed_at TIMESTAMP NULL DEFAULT NULL AFTER updated_at
      `);
      console.log('✅ vendor_confirmed_at column added');
    } catch (e) {
      if (e.code === 'ER_DUP_FIELDNAME') {
        console.log('ℹ️  vendor_confirmed_at already exists');
      } else throw e;
    }

    // Add driver_accepted_at column (ignore if already exists)
    try {
      await pool.execute(`
        ALTER TABLE orders
        ADD COLUMN driver_accepted_at TIMESTAMP NULL DEFAULT NULL AFTER vendor_confirmed_at
      `);
      console.log('✅ driver_accepted_at column added');
    } catch (e) {
      if (e.code === 'ER_DUP_FIELDNAME') {
        console.log('ℹ️  driver_accepted_at already exists');
      } else throw e;
    }

    console.log('\n✅ Migration completed successfully!');
    console.log('New statuses: pending_vendor_confirmation → vendor_confirmed → driver_assigned → picked_up → out_for_delivery → pending_confirmation → delivered');
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration failed:', error.message);
    process.exit(1);
  }
}

runMigration();
