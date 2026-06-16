// Test script to verify product add functionality
const axios = require('axios');
const FormData = require('form-data');
const fs = require('fs');

const BASE_URL = 'http://127.0.0.1:5000/api';

// You need to replace this with a valid vendor token
const VENDOR_TOKEN = 'YOUR_VENDOR_TOKEN_HERE';

async function testAddProductWithJSON() {
  console.log('\n=== Test 1: Add Product with Cloudinary URLs ===');
  
  try {
    const response = await axios.post(
      `${BASE_URL}/products`,
      {
        name: 'Test Product with URLs',
        description: 'Testing with Cloudinary images',
        price: 1200,
        stockQuantity: 50,
        category: 'Food',
        unit: 'piece',
        images: [
          'https://res.cloudinary.com/demo/image/upload/sample.jpg',
          'https://res.cloudinary.com/demo/image/upload/sample2.jpg'
        ]
      },
      {
        headers: {
          'Authorization': `Bearer ${VENDOR_TOKEN}`,
          'Content-Type': 'application/json'
        }
      }
    );
    
    console.log('✅ Success!');
    console.log('Response:', response.data);
  } catch (error) {
    console.log('❌ Error!');
    console.log('Error:', error.response?.data || error.message);
  }
}

async function testAddProductWithFile() {
  console.log('\n=== Test 2: Add Product with File Upload ===');
  
  try {
    const form = new FormData();
    form.append('name', 'Test Product with Files');
    form.append('description', 'Testing with file upload');
    form.append('price', '1500');
    form.append('stockQuantity', '100');
    form.append('category', 'Food');
    form.append('unit', 'piece');
    
    // You need to provide a test image file path
    // form.append('images', fs.createReadStream('path/to/test-image.jpg'));
    
    const response = await axios.post(
      `${BASE_URL}/products`,
      form,
      {
        headers: {
          'Authorization': `Bearer ${VENDOR_TOKEN}`,
          ...form.getHeaders()
        }
      }
    );
    
    console.log('✅ Success!');
    console.log('Response:', response.data);
  } catch (error) {
    console.log('❌ Error!');
    console.log('Error:', error.response?.data || error.message);
  }
}

async function testGetVendorProducts() {
  console.log('\n=== Test 3: Get Vendor Products ===');
  
  try {
    const response = await axios.get(
      `${BASE_URL}/products/vendor/my-products`,
      {
        headers: {
          'Authorization': `Bearer ${VENDOR_TOKEN}`
        }
      }
    );
    
    console.log('✅ Success!');
    console.log(`Found ${response.data.count} products`);
    console.log('Products:', JSON.stringify(response.data.data, null, 2));
  } catch (error) {
    console.log('❌ Error!');
    console.log('Error:', error.response?.data || error.message);
  }
}

// Run tests
async function runTests() {
  console.log('🧪 Product Add Test Suite');
  console.log('=========================');
  
  if (VENDOR_TOKEN === 'YOUR_VENDOR_TOKEN_HERE') {
    console.log('\n⚠️  Please update VENDOR_TOKEN in this file first!');
    console.log('   1. Login as vendor in the app');
    console.log('   2. Get token from browser storage or backend logs');
    console.log('   3. Replace VENDOR_TOKEN value in this file');
    return;
  }
  
  await testAddProductWithJSON();
  await new Promise(resolve => setTimeout(resolve, 1000));
  
  // Uncomment to test file upload
  // await testAddProductWithFile();
  // await new Promise(resolve => setTimeout(resolve, 1000));
  
  await testGetVendorProducts();
  
  console.log('\n✅ All tests completed!');
}

runTests();
