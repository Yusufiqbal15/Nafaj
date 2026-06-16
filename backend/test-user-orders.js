const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

// Test user credentials (replace with actual user credentials)
const USER_CREDENTIALS = {
  email: 'user@example.com',
  password: 'password123'
};

async function testUserOrders() {
  try {
    console.log('🔐 Logging in as User...');
    
    // Login
    const loginResponse = await axios.post(`${BASE_URL}/auth/login`, USER_CREDENTIALS);
    const token = loginResponse.data.token;
    
    console.log('✅ Login successful');
    console.log('Token:', token.substring(0, 20) + '...\n');

    // Get user orders
    console.log('📦 Fetching user orders...');
    const ordersResponse = await axios.get(`${BASE_URL}/orders/my-orders`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    console.log('✅ Orders fetched successfully');
    console.log('Total Orders:', ordersResponse.data.count);
    console.log('\n📋 Order Details:\n');
    console.log(JSON.stringify(ordersResponse.data, null, 2));

    // Test with status filter
    console.log('\n📦 Fetching pending orders only...');
    const pendingOrdersResponse = await axios.get(`${BASE_URL}/orders/my-orders?status=pending`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    console.log('✅ Pending orders fetched');
    console.log('Pending Orders Count:', pendingOrdersResponse.data.count);

  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
  }
}

testUserOrders();
