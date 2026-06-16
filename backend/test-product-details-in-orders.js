const axios = require('axios');

const BASE_URL = 'http://localhost:5000/api';

// Test credentials - will register if not exists
const TEST_USER = {
  firstName: 'Test',
  lastName: 'User',
  email: `test${Date.now()}@user.com`,
  password: 'password123',
  phone: '1234567890',
  address: 'Test Address'
};

async function testProductDetailsInOrders() {
  try {
    console.log('\n=== Testing Product Details in Orders ===\n');

    // Step 1: Register or Login
    console.log('Step 1: Registering new user...');
    let token;
    
    try {
      const registerResponse = await axios.post(`${BASE_URL}/auth/user/register`, TEST_USER);
      if (registerResponse.data.success) {
        token = registerResponse.data.data.token;
        console.log('✅ Registration successful');
        console.log(`   Email: ${TEST_USER.email}`);
        console.log(`   Token: ${token.substring(0, 20)}...`);
      }
    } catch (regError) {
      console.log('⚠️  Registration failed, trying login...');
      const loginResponse = await axios.post(`${BASE_URL}/auth/user/login`, {
        email: TEST_USER.email,
        password: TEST_USER.password
      });
      
      if (!loginResponse.data.success) {
        console.error('❌ Login failed');
        console.error('Please create a user account first or check existing orders.');
        console.error('\nAlternatively, you can directly check an order by ID:');
        console.error('  node -e "require(\'./src/models/Order\').getOrderItems(1).then(items => console.log(JSON.stringify(items, null, 2)))"');
        return;
      }
      
      token = loginResponse.data.data.token;
      console.log('✅ Login successful');
      console.log(`   Token: ${token.substring(0, 20)}...`);
    }

    // Step 2: Get user orders
    console.log('\nStep 2: Fetching user orders...');
    const ordersResponse = await axios.get(`${BASE_URL}/orders/user`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    if (!ordersResponse.data.success) {
      console.error('❌ Failed to fetch orders');
      return;
    }

    const orders = ordersResponse.data.data.orders;
    console.log(`✅ Fetched ${orders.length} orders`);

    if (orders.length === 0) {
      console.log('\n⚠️  No orders found. Create an order first to test product details.');
      return;
    }

    // Step 3: Check first order for complete product details
    console.log('\nStep 3: Checking product details in first order...');
    const firstOrder = orders[0];
    
    console.log(`\n📦 Order #${firstOrder.order_number}`);
    console.log(`   Status: ${firstOrder.order_status}`);
    console.log(`   Vendor: ${firstOrder.vendor_name}`);
    console.log(`   Total: SDG ${firstOrder.final_amount}`);

    // Check if items are included
    if (!firstOrder.items || firstOrder.items.length === 0) {
      console.log('\n❌ NO ITEMS FOUND - This should not happen!');
      return;
    }

    console.log(`\n✅ Found ${firstOrder.items.length} items in order`);

    // Check each item for complete product details
    console.log('\n🔍 Checking product details for each item:');
    firstOrder.items.forEach((item, index) => {
      console.log(`\n   Item ${index + 1}:`);
      console.log(`   ├─ Product ID: ${item.product_id || '❌ MISSING'}`);
      console.log(`   ├─ Product Name: ${item.product_name || '❌ MISSING'}`);
      console.log(`   ├─ Description: ${item.product_description || '(none)'}`);
      console.log(`   ├─ Category: ${item.category_name || '❌ MISSING'}`);
      console.log(`   ├─ Unit: ${item.product_unit || '❌ MISSING'}`);
      console.log(`   ├─ Images: ${item.product_images ? '✅ Available' : '❌ MISSING'}`);
      console.log(`   ├─ Original Price: SDG ${item.product_price || '❌ MISSING'}`);
      console.log(`   ├─ Discount Price: SDG ${item.product_discount_price || '(none)'}`);
      console.log(`   ├─ Stock Quantity: ${item.stock_quantity || '❌ MISSING'}`);
      console.log(`   ├─ Order Quantity: ${item.quantity || '❌ MISSING'}`);
      console.log(`   ├─ Unit Price at Order: SDG ${item.unit_price || '❌ MISSING'}`);
      console.log(`   └─ Total Price: SDG ${item.total_price || '❌ MISSING'}`);
    });

    // Verify all required fields are present
    console.log('\n✅ VERIFICATION RESULTS:');
    const requiredFields = [
      'product_id', 'product_name', 'product_description', 'product_images',
      'product_price', 'category_name', 'product_unit', 'stock_quantity',
      'quantity', 'unit_price', 'total_price'
    ];

    let allFieldsPresent = true;
    requiredFields.forEach(field => {
      const hasField = firstOrder.items.every(item => 
        item[field] !== undefined && item[field] !== null
      );
      if (hasField) {
        console.log(`   ✅ ${field}: Present in all items`);
      } else {
        console.log(`   ❌ ${field}: Missing in some items`);
        allFieldsPresent = false;
      }
    });

    if (allFieldsPresent) {
      console.log('\n🎉 SUCCESS! All product details are included in order items!');
    } else {
      console.log('\n⚠️  Some product details are missing. Please check the Order.getOrderItems() method.');
    }

  } catch (error) {
    console.error('\n❌ Error:', error.response?.data || error.message);
  }
}

// Run the test
testProductDetailsInOrders();
