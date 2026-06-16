const Order = require('./src/models/Order');
const pool = require('./src/config/database');

async function testOrderModel() {
  try {
    console.log('\n=== Testing Order Model - getOrderItems() Method ===\n');

    // Get any order from database
    console.log('Step 1: Finding an order in database...');
    const [orders] = await pool.execute('SELECT * FROM orders LIMIT 1');
    
    if (orders.length === 0) {
      console.log('❌ No orders found in database');
      console.log('\n💡 TIP: Create an order first using the app, then run this test.');
      process.exit(0);
    }

    const orderId = orders[0].id;
    console.log(`✅ Found order ID: ${orderId}`);
    console.log(`   Order Number: ${orders[0].order_number}`);
    console.log(`   Status: ${orders[0].order_status}`);

    // Test getOrderItems method
    console.log('\nStep 2: Calling Order.getOrderItems()...');
    const items = await Order.getOrderItems(orderId);
    
    console.log(`✅ Retrieved ${items.length} items`);

    if (items.length === 0) {
      console.log('\n⚠️  Order has no items');
      process.exit(0);
    }

    // Check product details for each item
    console.log('\nStep 3: Verifying product details in items...\n');
    
    items.forEach((item, index) => {
      console.log(`Item ${index + 1}:`);
      console.log(`  ├─ Product ID: ${item.product_id || '❌ MISSING'}`);
      console.log(`  ├─ Product Name: ${item.product_name || '❌ MISSING'}`);
      console.log(`  ├─ Description: ${item.product_description || '(none)'}`);
      console.log(`  ├─ Category: ${item.category_name || '❌ MISSING'}`);
      console.log(`  ├─ Unit: ${item.product_unit || '❌ MISSING'}`);
      console.log(`  ├─ Images: ${item.product_images ? '✅ Available' : '❌ MISSING'}`);
      console.log(`  ├─ Original Price: SDG ${item.product_price || '❌ MISSING'}`);
      console.log(`  ├─ Discount Price: ${item.product_discount_price ? 'SDG ' + item.product_discount_price : '(none)'}`);
      console.log(`  ├─ Stock Quantity: ${item.stock_quantity !== null && item.stock_quantity !== undefined ? item.stock_quantity : '❌ MISSING'}`);
      console.log(`  ├─ Order Quantity: ${item.quantity || '❌ MISSING'}`);
      console.log(`  ├─ Unit Price at Order: SDG ${item.unit_price || '❌ MISSING'}`);
      console.log(`  └─ Total Price: SDG ${item.total_price || '❌ MISSING'}`);
      console.log('');
    });

    // Verify all required fields
    console.log('✅ VERIFICATION RESULTS:');
    const requiredFields = [
      'product_id', 'product_name', 'product_description', 'product_images',
      'product_price', 'category_name', 'product_unit', 'stock_quantity',
      'quantity', 'unit_price', 'total_price'
    ];

    let allFieldsPresent = true;
    requiredFields.forEach(field => {
      const hasField = items.every(item => 
        item[field] !== undefined && item[field] !== null && item[field] !== ''
      );
      if (hasField) {
        console.log(`  ✅ ${field}: Present in all items`);
      } else {
        const missingCount = items.filter(item => 
          item[field] === undefined || item[field] === null || item[field] === ''
        ).length;
        console.log(`  ⚠️  ${field}: Missing in ${missingCount}/${items.length} items`);
        allFieldsPresent = false;
      }
    });

    if (allFieldsPresent) {
      console.log('\n🎉 SUCCESS! All product details are included in order items!');
      console.log('✅ The Order.getOrderItems() method is working correctly.');
      console.log('✅ The backend is ready to serve complete product details.');
    } else {
      console.log('\n⚠️  Some fields might be null/empty in the database.');
      console.log('💡 This is okay if products don\'t have all optional fields filled.');
    }

    process.exit(0);

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.error(error);
    process.exit(1);
  }
}

testOrderModel();
