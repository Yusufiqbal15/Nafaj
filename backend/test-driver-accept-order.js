const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

// Test driver credentials (replace with actual driver credentials)
const DRIVER_CREDENTIALS = {
  email: 'driver@example.com',
  password: 'password123'
};

async function testDriverAcceptOrder() {
  try {
    console.log('🔐 Logging in as Driver...');
    
    // Login
    const loginResponse = await axios.post(`${BASE_URL}/auth/driver/login`, DRIVER_CREDENTIALS);
    const token = loginResponse.data.token;
    
    console.log('✅ Login successful');
    console.log('Token:', token.substring(0, 20) + '...\n');

    // Get available orders
    console.log('📦 Fetching available orders...');
    const ordersResponse = await axios.get(`${BASE_URL}/orders/driver/orders?status=available`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    console.log('✅ Available orders fetched');
    console.log('Total Available Orders:', ordersResponse.data.count);

    if (ordersResponse.data.orders.length === 0) {
      console.log('❌ No available orders to accept');
      return;
    }

    // Accept the first available order
    const firstOrderId = ordersResponse.data.orders[0].id;
    const orderNumber = ordersResponse.data.orders[0].order_number;
    
    console.log(`\n🚚 Accepting order ${orderNumber} (ID: ${firstOrderId})...`);
    
    const acceptResponse = await axios.patch(
      `${BASE_URL}/orders/${firstOrderId}/accept`,
      {},
      {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      }
    );

    console.log('✅ Order accepted successfully!');
    console.log(JSON.stringify(acceptResponse.data, null, 2));

    // Verify the order is now in driver's orders
    console.log('\n📦 Verifying order is now in my orders...');
    const myOrdersResponse = await axios.get(`${BASE_URL}/orders/driver/orders`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    const acceptedOrder = myOrdersResponse.data.orders.find(o => o.id === firstOrderId);
    
    if (acceptedOrder) {
      console.log('✅ Order successfully assigned to driver');
      console.log('Order Status:', acceptedOrder.order_status);
      console.log('Driver ID:', acceptedOrder.driver_id);
    } else {
      console.log('❌ Order not found in driver\'s orders');
    }

  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
  }
}

testDriverAcceptOrder();
