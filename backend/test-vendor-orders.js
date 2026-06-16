const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

// Test vendor credentials (replace with actual vendor credentials)
const VENDOR_CREDENTIALS = {
  email: 'vendor@example.com',
  password: 'password123'
};

async function testVendorOrders() {
  try {
    console.log('🔐 Logging in as Vendor...');
    
    // Login
    const loginResponse = await axios.post(`${BASE_URL}/auth/vendor/login`, VENDOR_CREDENTIALS);
    const token = loginResponse.data.token;
    
    console.log('✅ Login successful');
    console.log('Token:', token.substring(0, 20) + '...\n');

    // Get vendor orders
    console.log('📦 Fetching vendor orders...');
    const ordersResponse = await axios.get(`${BASE_URL}/orders/vendor/orders`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    console.log('✅ Orders fetched successfully');
    console.log('Total Orders:', ordersResponse.data.count);
    console.log('\n📋 Order Details:\n');
    console.log(JSON.stringify(ordersResponse.data, null, 2));

    // Test update order status
    if (ordersResponse.data.orders.length > 0) {
      const firstOrderId = ordersResponse.data.orders[0].id;
      
      console.log(`\n🔄 Updating order ${firstOrderId} status to "confirmed"...`);
      const updateResponse = await axios.patch(
        `${BASE_URL}/orders/${firstOrderId}/status`,
        { status: 'confirmed' },
        {
          headers: {
            'Authorization': `Bearer ${token}`
          }
        }
      );

      console.log('✅ Order status updated:', updateResponse.data.message);
    }

  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
  }
}

testVendorOrders();
