const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

// Test driver credentials (replace with actual driver credentials)
const DRIVER_CREDENTIALS = {
  email: 'driver@example.com',
  password: 'password123'
};

async function testDriverAvailableOrders() {
  try {
    console.log('🔐 Logging in as Driver...');
    
    // Login
    const loginResponse = await axios.post(`${BASE_URL}/auth/driver/login`, DRIVER_CREDENTIALS);
    const token = loginResponse.data.token;
    
    console.log('✅ Login successful');
    console.log('Token:', token.substring(0, 20) + '...\n');

    // Get available orders
    console.log('📦 Fetching available orders for delivery...');
    const ordersResponse = await axios.get(`${BASE_URL}/orders/driver/orders?status=available`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    console.log('✅ Available orders fetched successfully');
    console.log('Total Available Orders:', ordersResponse.data.count);
    console.log('\n📋 Order Details:\n');
    console.log(JSON.stringify(ordersResponse.data, null, 2));

    // Get driver's assigned orders
    console.log('\n📦 Fetching my assigned orders...');
    const myOrdersResponse = await axios.get(`${BASE_URL}/orders/driver/orders`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    console.log('✅ My orders fetched successfully');
    console.log('Total My Orders:', myOrdersResponse.data.count);
    console.log('\n📋 My Order Details:\n');
    console.log(JSON.stringify(myOrdersResponse.data, null, 2));

  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
  }
}

testDriverAvailableOrders();
