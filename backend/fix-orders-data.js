const mysql = require('mysql2/promise');
require('dotenv').config();

async function fixOrdersData() {
  let connection;
  
  try {
    // Connect to database
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_NAME || 'nafaj'
    });

    console.log('✓ Connected to database\n');

    // Step 1: Add coordinates to orders without them
    console.log('Step 1: Adding coordinates to orders...');
    const [updateResult] = await connection.execute(`
      UPDATE orders 
      SET delivery_latitude = 15.5107, 
          delivery_longitude = 32.5699 
      WHERE delivery_latitude IS NULL OR delivery_longitude IS NULL
    `);
    console.log(`✓ Updated ${updateResult.affectedRows} orders with coordinates\n`);

    // Step 2: Activate all drivers
    console.log('Step 2: Activating drivers...');
    const [activateResult] = await connection.execute(`
      UPDATE drivers 
      SET status = 'active' 
      WHERE status = 'pending_verification'
    `);
    console.log(`✓ Activated ${activateResult.affectedRows} drivers\n`);

    // Step 3: Show current orders
    console.log('Step 3: Current available orders for drivers:\n');
    const [orders] = await connection.execute(`
      SELECT 
        o.id,
        o.order_number,
        o.final_amount,
        o.delivery_address,
        o.delivery_latitude,
        o.delivery_longitude,
        o.order_status,
        o.driver_id,
        v.business_name as vendor_name,
        u.first_name,
        u.last_name
      FROM orders o
      LEFT JOIN vendors v ON o.vendor_id = v.id
      LEFT JOIN users u ON o.user_id = u.id
      WHERE o.driver_id IS NULL
      AND o.order_status IN ('pending', 'confirmed', 'ready')
      ORDER BY o.created_at DESC
      LIMIT 10
    `);

    console.log(`Found ${orders.length} available orders:\n`);
    orders.forEach((order, index) => {
      console.log(`${index + 1}. Order #${order.order_number}`);
      console.log(`   Vendor: ${order.vendor_name}`);
      console.log(`   Customer: ${order.first_name} ${order.last_name}`);
      console.log(`   Amount: SDG ${order.final_amount}`);
      console.log(`   Address: ${order.delivery_address}`);
      console.log(`   Coordinates: ${order.delivery_latitude}, ${order.delivery_longitude}`);
      console.log(`   Status: ${order.order_status}`);
      console.log('');
    });

    // Step 4: Show active drivers
    console.log('Step 4: Active drivers:\n');
    const [drivers] = await connection.execute(`
      SELECT id, email, phone, status, created_at
      FROM drivers
      WHERE status = 'active'
      ORDER BY created_at DESC
    `);

    console.log(`Found ${drivers.length} active drivers:\n`);
    drivers.forEach((driver, index) => {
      console.log(`${index + 1}. Driver ID: ${driver.id}`);
      console.log(`   Email: ${driver.email}`);
      console.log(`   Phone: ${driver.phone}`);
      console.log(`   Status: ${driver.status}`);
      console.log('');
    });

    console.log('✅ All fixes applied successfully!');
    console.log('\n📱 Next Steps:');
    console.log('1. Login to app as driver');
    console.log('2. Navigate to Driver Dashboard');
    console.log('3. You should see', orders.length, 'orders available');

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

fixOrdersData();
