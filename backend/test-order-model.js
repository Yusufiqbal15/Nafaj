const Order = require('./src/models/Order');

async function testOrderModel() {
  try {
    console.log('Testing Order.findAvailableForDriver()...\n');
    
    const orders = await Order.findAvailableForDriver({});
    
    console.log(`Found ${orders.length} orders\n`);
    
    if (orders.length > 0) {
      console.log('First order:');
      console.log(JSON.stringify(orders[0], null, 2));
    } else {
      console.log('❌ No orders found! This is the problem.');
    }
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

testOrderModel();
