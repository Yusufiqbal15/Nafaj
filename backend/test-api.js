const axios = require('axios');

async function testAPI() {
  try {
    console.log('Testing GET /api/products...\n');
    
    const response = await axios.get('http://localhost:5000/api/products');
    
    console.log('Status:', response.status);
    console.log('Success:', response.data.success);
    console.log('Count:', response.data.count);
    console.log('\nProducts:');
    
    if (response.data.data) {
      response.data.data.forEach((product, index) => {
        console.log(`\n${index + 1}. ${product.name}`);
        console.log(`   Price: ${product.price} SDG`);
        console.log(`   Vendor ID: ${product.vendor_id}`);
        console.log(`   Images: ${JSON.stringify(product.images)}`);
        console.log(`   Stock: ${product.stock_quantity}`);
      });
    }
    
  } catch (error) {
    console.error('Error:', error.message);
    if (error.response) {
      console.error('Response:', error.response.data);
    }
  }
}

testAPI();
