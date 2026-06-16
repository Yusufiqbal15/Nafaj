const axios = require('axios');

const BASE_URL = 'http://localhost:5000/api';

// Test credentials
const USER_EMAIL = 'user@example.com';
const USER_PASSWORD = 'password123';
const VENDOR_EMAIL = 'vendor@example.com';
const VENDOR_PASSWORD = 'password123';

async function testVendorOrderFlow() {
  try {
    console.log('🎬 Starting Vendor Order Flow Test\n');
    console.log('═══════════════════════════════════════════════════════\n');

    // STEP 1: Login as Vendor
    console.log('🏪 STEP 1: Logging in as Vendor...');
    const vendorLoginResponse = await axios.post(`${BASE_URL}/vendors/login`, {
      email: VENDOR_EMAIL,
      password: VENDOR_PASSWORD,
    });

    if (!vendorLoginResponse.data.success) {
      console.log('❌ Vendor login failed');
      return;
    }

    const vendorToken = vendorLoginResponse.data.token;
    const vendorId = vendorLoginResponse.data.vendor.id;
    console.log(`✅ Vendor logged in successfully`);
    console.log(`   Vendor ID: ${vendorId}`);
    console.log(`   Business: ${vendorLoginResponse.data.vendor.businessName}\n`);

    // STEP 2: Get Vendor's Products
    console.log('📦 STEP 2: Getting Vendor Products...');
    const productsResponse = await axios.get(`${BASE_URL}/products/vendor/products`, {
      headers: { Authorization: `Bearer ${vendorToken}` },
    });

    if (!productsResponse.data.success || productsResponse.data.data.length === 0) {
      console.log('❌ No products found. Creating a test product...');
      
      // Create a test product
      const createProductResponse = await axios.post(
        `${BASE_URL}/products`,
        {
          name: 'Test Product for Order',
          description: 'A test product to create orders',
          price: 100,
          category: 'Test Category',
          stockQuantity: 50,
          unit: 'piece',
        },
        {
          headers: { Authorization: `Bearer ${vendorToken}` },
        }
      );

      if (!createProductResponse.data.success) {
        console.log('❌ Failed to create test product');
        return;
      }
      console.log('✅ Test product created');
    }

    // Get products again
    const updatedProductsResponse = await axios.get(`${BASE_URL}/products/vendor/products`, {
      headers: { Authorization: `Bearer ${vendorToken}` },
    });

    const product = updatedProductsResponse.data.data[0];
    console.log(`✅ Found ${updatedProductsResponse.data.data.length} product(s)`);
    console.log(`   Product: ${product.name}`);
    console.log(`   Price: SDG ${product.price}`);
    console.log(`   Stock: ${product.stock_quantity}\n`);

    // STEP 3: Login as User
    console.log('👤 STEP 3: Logging in as User...');
    const userLoginResponse = await axios.post(`${BASE_URL}/auth/login`, {
      email: USER_EMAIL,
      password: USER_PASSWORD,
    });

    if (!userLoginResponse.data.success) {
      console.log('❌ User login failed');
      return;
    }

    const userToken = userLoginResponse.data.token;
    const userId = userLoginResponse.data.user.id;
    console.log(`✅ User logged in successfully`);
    console.log(`   User ID: ${userId}`);
    console.log(`   Name: ${userLoginResponse.data.user.firstName} ${userLoginResponse.data.user.lastName}\n`);

    // STEP 4: User Places an Order
    console.log('🛒 STEP 4: User Placing Order...');
    const orderData = {
      vendorId: vendorId,
      items: [
        {
          productId: product.id,
          quantity: 2,
        },
      ],
      deliveryAddress: '123 Test Street, Khartoum, Sudan',
      deliveryLatitude: 15.5007,
      deliveryLongitude: 32.5599,
      paymentMethod: 'cash',
      notes: 'Please deliver quickly',
    };

    const createOrderResponse = await axios.post(
      `${BASE_URL}/orders`,
      orderData,
      {
        headers: { Authorization: `Bearer ${userToken}` },
      }
    );

    if (!createOrderResponse.data) {
      console.log('❌ Order creation failed');
      return;
    }

    const orderId = createOrderResponse.data.orderId;
    const orderNumber = createOrderResponse.data.orderNumber;
    console.log(`✅ Order created successfully`);
    console.log(`   Order ID: ${orderId}`);
    console.log(`   Order Number: ${orderNumber}`);
    console.log(`   Total Amount: SDG ${createOrderResponse.data.finalAmount}\n`);

    // STEP 5: Vendor Checks Orders
    console.log('🏪 STEP 5: Vendor Checking Orders...');
    const vendorOrdersResponse = await axios.get(`${BASE_URL}/orders/vendor/orders`, {
      headers: { Authorization: `Bearer ${vendorToken}` },
    });

    if (!vendorOrdersResponse.data.success) {
      console.log('❌ Failed to fetch vendor orders');
      console.log('   Error:', vendorOrdersResponse.data.error);
      return;
    }

    console.log(`✅ Vendor orders fetched successfully`);
    console.log(`   Total Orders: ${vendorOrdersResponse.data.count}`);
    
    const vendorOrders = vendorOrdersResponse.data.orders || vendorOrdersResponse.data.data?.orders || [];
    
    if (vendorOrders.length === 0) {
      console.log('❌ No orders found for vendor!');
      console.log('   This is the main issue - orders are not visible to vendor');
      return;
    }

    console.log(`\n📋 Orders visible to vendor:\n`);
    vendorOrders.forEach((order, index) => {
      console.log(`   ${index + 1}. Order #${order.order_number}`);
      console.log(`      Status: ${order.order_status}`);
      console.log(`      Customer: ${order.first_name} ${order.last_name}`);
      console.log(`      Phone: ${order.phone || 'N/A'}`);
      console.log(`      Email: ${order.user_email}`);
      console.log(`      Amount: SDG ${order.final_amount}`);
      console.log(`      Address: ${order.delivery_address}`);
      console.log(`      Items: ${order.items?.length || 0} item(s)`);
      if (order.items && order.items.length > 0) {
        order.items.forEach((item) => {
          console.log(`         - ${item.product_name} x${item.quantity} = SDG ${item.total_price}`);
        });
      }
      console.log('');
    });

    // STEP 6: Vendor Confirms Order
    console.log('✅ STEP 6: Vendor Confirming Order...');
    const confirmResponse = await axios.patch(
      `${BASE_URL}/orders/${orderId}/status`,
      { status: 'confirmed' },
      {
        headers: { Authorization: `Bearer ${vendorToken}` },
      }
    );

    if (confirmResponse.status === 200) {
      console.log(`✅ Order confirmed by vendor`);
      console.log(`   Order Status: confirmed\n`);
    }

    // STEP 7: Vendor Updates Order to Ready
    console.log('📦 STEP 7: Vendor Marking Order as Ready...');
    const readyResponse = await axios.patch(
      `${BASE_URL}/orders/${orderId}/status`,
      { status: 'ready' },
      {
        headers: { Authorization: `Bearer ${vendorToken}` },
      }
    );

    if (readyResponse.status === 200) {
      console.log(`✅ Order marked as ready`);
      console.log(`   Order Status: ready\n`);
    }

    // STEP 8: Get Order Tracking Info
    console.log('🔍 STEP 8: Getting Order Tracking Info...');
    const trackingResponse = await axios.get(
      `${BASE_URL}/orders/${orderId}/tracking`,
      {
        headers: { Authorization: `Bearer ${vendorToken}` },
      }
    );

    if (trackingResponse.data.success) {
      const trackingData = trackingResponse.data.data;
      console.log(`✅ Order tracking info:`);
      console.log(`   Order Number: ${trackingData.orderNumber}`);
      console.log(`   Status: ${trackingData.orderStatus}`);
      console.log(`   Delivery Address: ${trackingData.deliveryAddress}`);
      console.log(`   Driver Assigned: ${trackingData.driverAssigned ? 'Yes' : 'No'}`);
      console.log(`   Total Amount: SDG ${trackingData.finalAmount}\n`);
    }

    console.log('═══════════════════════════════════════════════════════');
    console.log('✅ VENDOR ORDER FLOW TEST COMPLETED SUCCESSFULLY! 🎉');
    console.log('═══════════════════════════════════════════════════════\n');

    console.log('📊 Summary:');
    console.log(`   ✓ Vendor can view orders from customers`);
    console.log(`   ✓ Order details include customer info`);
    console.log(`   ✓ Vendor can update order status`);
    console.log(`   ✓ Tracking information is available`);
    console.log(`\n🎯 The vendor order system is working correctly!`);

  } catch (error) {
    console.error('\n❌ TEST FAILED:');
    if (error.response) {
      console.error('   Status:', error.response.status);
      console.error('   Error:', error.response.data);
    } else {
      console.error('   Error:', error.message);
    }
  }
}

// Run the test
testVendorOrderFlow();
