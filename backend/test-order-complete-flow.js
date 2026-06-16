const axios = require('axios');

const BASE_URL = 'http://localhost:3000/api';

// Test credentials (replace with actual credentials)
const USER_CREDENTIALS = {
  email: 'user@example.com',
  password: 'password123'
};

const VENDOR_CREDENTIALS = {
  email: 'vendor@example.com',
  password: 'password123'
};

const DRIVER_CREDENTIALS = {
  email: 'driver@example.com',
  password: 'password123'
};

async function testCompleteOrderFlow() {
  try {
    console.log('🚀 Starting Complete Order Flow Test\n');
    console.log('=' .repeat(60));

    // STEP 1: User creates order
    console.log('\n📝 STEP 1: User Creates Order');
    console.log('-'.repeat(60));
    
    const userLoginResponse = await axios.post(`${BASE_URL}/auth/login`, USER_CREDENTIALS);
    const userToken = userLoginResponse.data.token;
    console.log('✅ User logged in');

    const orderData = {
      vendorId: 1, // Replace with actual vendor ID
      items: [
        {
          productId: 1, // Replace with actual product ID
          quantity: 2
        }
      ],
      deliveryAddress: 'House 123, Street 5, Karachi',
      deliveryLatitude: 24.8607,
      deliveryLongitude: 67.0011,
      paymentMethod: 'cash',
      notes: 'Please deliver before 5 PM'
    };

    const createOrderResponse = await axios.post(
      `${BASE_URL}/orders`,
      orderData,
      {
        headers: { 'Authorization': `Bearer ${userToken}` }
      }
    );

    const orderId = createOrderResponse.data.orderId;
    const orderNumber = createOrderResponse.data.orderNumber;
    
    console.log('✅ Order created successfully');
    console.log('   Order ID:', orderId);
    console.log('   Order Number:', orderNumber);

    // STEP 2: User views their orders
    console.log('\n👤 STEP 2: User Views Their Orders');
    console.log('-'.repeat(60));
    
    const userOrdersResponse = await axios.get(`${BASE_URL}/orders/my-orders`, {
      headers: { 'Authorization': `Bearer ${userToken}` }
    });

    console.log('✅ User orders fetched');
    console.log('   Total Orders:', userOrdersResponse.data.count);
    console.log('   User Email:', userOrdersResponse.data.orders[0]?.user_email);
    console.log('   Vendor Name:', userOrdersResponse.data.orders[0]?.vendor_name);

    // STEP 3: Vendor views their orders
    console.log('\n🏪 STEP 3: Vendor Views Their Orders');
    console.log('-'.repeat(60));
    
    const vendorLoginResponse = await axios.post(`${BASE_URL}/auth/vendor/login`, VENDOR_CREDENTIALS);
    const vendorToken = vendorLoginResponse.data.token;
    console.log('✅ Vendor logged in');

    const vendorOrdersResponse = await axios.get(`${BASE_URL}/orders/vendor/orders`, {
      headers: { 'Authorization': `Bearer ${vendorToken}` }
    });

    console.log('✅ Vendor orders fetched');
    console.log('   Total Orders:', vendorOrdersResponse.data.count);
    
    const vendorOrder = vendorOrdersResponse.data.orders.find(o => o.id === orderId);
    if (vendorOrder) {
      console.log('   Customer Name:', `${vendorOrder.first_name} ${vendorOrder.last_name}`);
      console.log('   Customer Email:', vendorOrder.user_email);
      console.log('   Customer Phone:', vendorOrder.phone);
      console.log('   Items Count:', vendorOrder.items.length);
    }

    // STEP 4: Vendor confirms order
    console.log('\n✅ STEP 4: Vendor Confirms Order');
    console.log('-'.repeat(60));
    
    await axios.patch(
      `${BASE_URL}/orders/${orderId}/status`,
      { status: 'confirmed' },
      {
        headers: { 'Authorization': `Bearer ${vendorToken}` }
      }
    );
    console.log('✅ Order status updated to "confirmed"');

    // STEP 5: Vendor marks order as ready
    console.log('\n📦 STEP 5: Vendor Marks Order as Ready');
    console.log('-'.repeat(60));
    
    await axios.patch(
      `${BASE_URL}/orders/${orderId}/status`,
      { status: 'ready' },
      {
        headers: { 'Authorization': `Bearer ${vendorToken}` }
      }
    );
    console.log('✅ Order status updated to "ready"');

    // STEP 6: Driver views available orders
    console.log('\n🚚 STEP 6: Driver Views Available Orders');
    console.log('-'.repeat(60));
    
    const driverLoginResponse = await axios.post(`${BASE_URL}/auth/driver/login`, DRIVER_CREDENTIALS);
    const driverToken = driverLoginResponse.data.token;
    console.log('✅ Driver logged in');

    const availableOrdersResponse = await axios.get(
      `${BASE_URL}/orders/driver/orders?status=available`,
      {
        headers: { 'Authorization': `Bearer ${driverToken}` }
      }
    );

    console.log('✅ Available orders fetched');
    console.log('   Total Available Orders:', availableOrdersResponse.data.count);
    
    const availableOrder = availableOrdersResponse.data.orders.find(o => o.id === orderId);
    if (availableOrder) {
      console.log('   Order Number:', availableOrder.order_number);
      console.log('   Vendor Name:', availableOrder.vendor_name);
      console.log('   Vendor Address:', availableOrder.vendor_address);
      console.log('   Customer Name:', `${availableOrder.first_name} ${availableOrder.last_name}`);
      console.log('   Delivery Address:', availableOrder.delivery_address);
      console.log('   Items:', availableOrder.items.length);
    }

    // STEP 7: Driver accepts order
    console.log('\n✅ STEP 7: Driver Accepts Order');
    console.log('-'.repeat(60));
    
    const acceptResponse = await axios.patch(
      `${BASE_URL}/orders/${orderId}/accept`,
      {},
      {
        headers: { 'Authorization': `Bearer ${driverToken}` }
      }
    );

    console.log('✅ Order accepted by driver');
    console.log('   Message:', acceptResponse.data.message);

    // STEP 8: Driver views their orders
    console.log('\n📋 STEP 8: Driver Views Their Orders');
    console.log('-'.repeat(60));
    
    const driverOrdersResponse = await axios.get(`${BASE_URL}/orders/driver/orders`, {
      headers: { 'Authorization': `Bearer ${driverToken}` }
    });

    console.log('✅ Driver orders fetched');
    console.log('   Total My Orders:', driverOrdersResponse.data.count);
    
    const driverOrder = driverOrdersResponse.data.orders.find(o => o.id === orderId);
    if (driverOrder) {
      console.log('   Order Status:', driverOrder.order_status);
      console.log('   Driver ID:', driverOrder.driver_id);
    }

    // STEP 9: Driver marks as delivered
    console.log('\n🎉 STEP 9: Driver Marks Order as Delivered');
    console.log('-'.repeat(60));
    
    await axios.patch(
      `${BASE_URL}/orders/${orderId}/status`,
      { status: 'delivered' },
      {
        headers: { 'Authorization': `Bearer ${driverToken}` }
      }
    );
    console.log('✅ Order status updated to "delivered"');

    // STEP 10: Verify final status
    console.log('\n🔍 STEP 10: Verify Final Status');
    console.log('-'.repeat(60));
    
    const finalOrderResponse = await axios.get(`${BASE_URL}/orders/${orderId}`, {
      headers: { 'Authorization': `Bearer ${userToken}` }
    });

    console.log('✅ Order details:');
    console.log('   Order Number:', finalOrderResponse.data.order_number);
    console.log('   Status:', finalOrderResponse.data.order_status);
    console.log('   Payment Status:', finalOrderResponse.data.payment_status);
    console.log('   Final Amount:', finalOrderResponse.data.final_amount);

    console.log('\n' + '='.repeat(60));
    console.log('🎊 COMPLETE ORDER FLOW TEST SUCCESSFUL! 🎊');
    console.log('='.repeat(60) + '\n');

  } catch (error) {
    console.error('\n❌ ERROR:', error.response?.data || error.message);
    console.error('\nStack:', error.stack);
  }
}

testCompleteOrderFlow();
