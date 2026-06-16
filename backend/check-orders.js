const mysql = require('mysql2/promise');

async function checkOrders() {
  const conn = await mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'Yusuf@15',
    database: 'nafaj'
  });

  console.log('Checking orders in database...\n');

  // Check total orders
  const [total] = await conn.execute('SELECT COUNT(*) as count FROM orders');
  console.log('Total orders in database:', total[0].count);

  // Check unassigned orders
  const [unassigned] = await conn.execute(
    'SELECT COUNT(*) as count FROM orders WHERE driver_id IS NULL'
  );
  console.log('Unassigned orders (driver_id = NULL):', unassigned[0].count);

  // Check by status
  const [byStatus] = await conn.execute(
    'SELECT order_status, COUNT(*) as count FROM orders GROUP BY order_status'
  );
  console.log('\nOrders by status:');
  byStatus.forEach(s => console.log(`  ${s.order_status}: ${s.count}`));

  // Check orders matching API query
  const [available] = await conn.execute(
    'SELECT id, order_number, driver_id, order_status FROM orders WHERE driver_id IS NULL AND order_status IN ("ready", "confirmed", "pending") ORDER BY created_at DESC'
  );
  console.log('\nOrders that SHOULD show in API:', available.length);
  available.forEach(o => {
    console.log(`  Order #${o.order_number} - Status: ${o.order_status} - Driver: ${o.driver_id}`);
  });

  await conn.end();
}

checkOrders().catch(console.error);
