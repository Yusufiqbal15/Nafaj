// Test script to create and login drivers
const axios = require('axios');

const API_BASE = 'http://127.0.0.1:5000/api';

// Test drivers
const drivers = [
  {
    email: 'driver1@gmail.com',
    password: 'password123',
    phone: '03123456789',
    firstName: 'Ahmed',
    lastName: 'Hassan',
    licenseNumber: 'DL12345',
    vehicleType: 'Motorcycle',
    vehiclePlate: 'ABC-123'
  },
  {
    email: 'driver2@gmail.com',
    password: 'password123',
    phone: '03987654321',
    firstName: 'Mohammed',
    lastName: 'Ali',
    licenseNumber: 'DL67890',
    vehicleType: 'Car',
    vehiclePlate: 'XYZ-789'
  }
];

async function registerDriver(driver) {
  try {
    console.log(`\n📝 Registering driver: ${driver.email}`);
    const response = await axios.post(`${API_BASE}/auth/driver/register`, driver);
    console.log('✅ Driver registered successfully');
    console.log(`   Driver ID: ${response.data.data.driverId}`);
    console.log(`   Token: ${response.data.data.token.substring(0, 20)}...`);
    return response.data.data;
  } catch (error) {
    if (error.response?.status === 400 && error.response?.data?.error?.includes('already exists')) {
      console.log('⚠️  Driver already exists, trying login...');
      return await loginDriver(driver.email, driver.password);
    }
    console.error('❌ Registration failed:', error.response?.data?.error || error.message);
    return null;
  }
}

async function loginDriver(email, password) {
  try {
    console.log(`\n🔑 Logging in driver: ${email}`);
    const response = await axios.post(`${API_BASE}/auth/driver/login`, {
      email,
      password
    });
    console.log('✅ Driver logged in successfully');
    console.log(`   Driver ID: ${response.data.driverId}`);
    console.log(`   Token: ${response.data.token.substring(0, 20)}...`);
    return response.data;
  } catch (error) {
    console.error('❌ Login failed:', error.response?.data?.error || error.message);
    return null;
  }
}

async function testDriverOrders(token, driverEmail) {
  try {
    console.log(`\n📦 Fetching orders for ${driverEmail}...`);
    const response = await axios.get(`${API_BASE}/orders/driver/orders`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });
    console.log(`✅ Found ${response.data.count} orders for this driver`);
    if (response.data.orders.length > 0) {
      console.log('   First order:', {
        id: response.data.orders[0].order_number,
        status: response.data.orders[0].order_status,
        driverId: response.data.orders[0].driver_id
      });
    }
  } catch (error) {
    console.error('❌ Failed to fetch orders:', error.response?.data?.error || error.message);
  }
}

async function acceptOrder(token, orderId, driverEmail) {
  try {
    console.log(`\n✋ Driver ${driverEmail} accepting order ${orderId}...`);
    const response = await axios.patch(
      `${API_BASE}/orders/${orderId}/accept`,
      {},
      {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      }
    );
    console.log('✅ Order accepted successfully');
    console.log(`   Order ID: ${response.data.orderId}`);
    console.log(`   Driver ID: ${response.data.driverId}`);
  } catch (error) {
    console.error('❌ Failed to accept order:', error.response?.data?.error || error.message);
  }
}

async function main() {
  console.log('🚀 Testing Driver Authentication & Orders\n');
  console.log('='.repeat(60));

  // Register/Login Driver 1
  const driver1Data = await registerDriver(drivers[0]);
  if (!driver1Data) {
    console.error('Failed to setup driver 1');
    return;
  }

  // Register/Login Driver 2
  const driver2Data = await registerDriver(drivers[1]);
  if (!driver2Data) {
    console.error('Failed to setup driver 2');
    return;
  }

  console.log('\n' + '='.repeat(60));
  console.log('\n📊 Testing Order Access...\n');

  // Test: Driver 1 checks their orders
  await testDriverOrders(driver1Data.token, drivers[0].email);

  // Test: Driver 2 checks their orders
  await testDriverOrders(driver2Data.token, drivers[1].email);

  console.log('\n' + '='.repeat(60));
  console.log('\n✅ Test Complete!\n');
  console.log('📋 Summary:');
  console.log(`   Driver 1: ${drivers[0].email} (ID: ${driver1Data.driverId})`);
  console.log(`   Driver 2: ${drivers[1].email} (ID: ${driver2Data.driverId})`);
  console.log('\n🔑 Use these credentials to login in Flutter app:');
  console.log(`   Email: ${drivers[0].email}`);
  console.log(`   Password: ${drivers[0].password}`);
  console.log('\n💡 To accept an order from Flutter, login with driver1@gmail.com');
  console.log('   Then go to dashboard and accept an order.');
  console.log('   Only driver1 will see that order in history!');
}

main().catch(console.error);
