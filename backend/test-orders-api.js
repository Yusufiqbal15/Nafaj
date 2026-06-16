// Test Orders API Endpoint
const http = require('http');

function testOrdersAPI() {
  const options = {
    hostname: '127.0.0.1',
    port: 5000,
    path: '/api/orders/driver/orders?status=available',
    method: 'GET',
    headers: {
      'Content-Type': 'application/json'
    }
  };

  console.log('Testing API: http://127.0.0.1:5000/api/orders/driver/orders?status=available\n');

  const req = http.request(options, (res) => {
    let data = '';

    res.on('data', (chunk) => {
      data += chunk;
    });

    res.on('end', () => {
      try {
        const response = JSON.parse(data);
        
        if (response.success) {
          console.log('✅ API Test PASSED!\n');
          console.log(`Found ${response.count} orders:\n`);
          
          response.orders.forEach((order, index) => {
            console.log(`${index + 1}. Order #${order.order_number}`);
            console.log(`   Vendor: ${order.vendor_name}`);
            console.log(`   Amount: SDG ${order.final_amount}`);
            console.log(`   Address: ${order.delivery_address}`);
            console.log(`   Coordinates: ${order.delivery_latitude}, ${order.delivery_longitude}`);
            console.log(`   Items: ${order.items ? order.items.length : 0} items`);
            console.log('');
          });
          
          console.log('🎉 Backend is working correctly!');
          console.log('📱 Now refresh your Flutter app to see these orders.\n');
        } else {
          console.log('❌ API returned error:', response.error || 'Unknown error');
        }
      } catch (error) {
        console.log('❌ Failed to parse response:', error.message);
        console.log('Raw response:', data);
      }
    });
  });

  req.on('error', (error) => {
    console.log('❌ Connection Error:', error.message);
    console.log('\n💡 Make sure backend is running on port 5000');
    console.log('   Run: npm start\n');
  });

  req.end();
}

// Run test
testOrdersAPI();
