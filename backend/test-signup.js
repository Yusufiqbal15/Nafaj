require('dotenv').config();
const axios = require('axios');

const BASE_URL = `http://localhost:${process.env.SERVER_PORT || 5000}/api`;

// Test data
const testUser = {
  email: `testuser${Date.now()}@example.com`,
  phone: `03${Math.floor(100000000 + Math.random() * 900000000)}`,
  password: 'Test@123',
  firstName: 'Test',
  lastName: 'User'
};

const testVendor = {
  email: `testvendor${Date.now()}@example.com`,
  phone: `03${Math.floor(100000000 + Math.random() * 900000000)}`,
  password: 'Test@123',
  businessName: 'Test Business',
  ownerFirstName: 'Test',
  ownerLastName: 'Owner',
  businessType: 'Retail',
  shopAddress: '123 Test Street',
  city: 'Karachi',
  ntnNumber: '1234567'
};

const testDriver = {
  email: `testdriver${Date.now()}@example.com`,
  phone: `03${Math.floor(100000000 + Math.random() * 900000000)}`,
  password: 'Test@123',
  firstName: 'Test',
  lastName: 'Driver',
  licenseNumber: `DL${Date.now()}`,
  vehicleType: 'Car',
  vehiclePlate: 'ABC-123'
};

async function testSignup(endpoint, data, userType) {
  console.log(`\n${'='.repeat(50)}`);
  console.log(`Testing ${userType} Signup`);
  console.log('='.repeat(50));
  console.log('Endpoint:', `${BASE_URL}${endpoint}`);
  console.log('Data:', JSON.stringify(data, null, 2));
  
  try {
    const response = await axios.post(`${BASE_URL}${endpoint}`, data, {
      headers: {
        'Content-Type': 'application/json'
      },
      timeout: 10000
    });
    
    console.log('\n✓ SUCCESS!');
    console.log('Status:', response.status);
    console.log('Response:', JSON.stringify(response.data, null, 2));
    return true;
  } catch (error) {
    console.log('\n✗ FAILED!');
    if (error.response) {
      console.log('Status:', error.response.status);
      console.log('Error:', JSON.stringify(error.response.data, null, 2));
    } else if (error.request) {
      console.log('Network Error: No response received');
      console.log('Error:', error.message);
      console.log('\nPossible causes:');
      console.log('1. Backend server is not running');
      console.log('2. Wrong port number');
      console.log('3. Firewall blocking the connection');
    } else {
      console.log('Error:', error.message);
    }
    return false;
  }
}

async function runTests() {
  console.log('\n╔════════════════════════════════════════════════╗');
  console.log('║   Testing Signup Endpoints                     ║');
  console.log('╚════════════════════════════════════════════════╝');
  console.log(`\nBase URL: ${BASE_URL}`);
  
  // Test server health
  console.log('\n' + '='.repeat(50));
  console.log('Testing Server Health');
  console.log('='.repeat(50));
  try {
    const health = await axios.get(`${BASE_URL}/health`, { timeout: 5000 });
    console.log('✓ Server is running');
    console.log('Response:', JSON.stringify(health.data, null, 2));
  } catch (error) {
    console.log('✗ Server health check failed');
    console.log('Error:', error.message);
    console.log('\n⚠ Please start the backend server first:');
    console.log('   cd backend');
    console.log('   npm start');
    process.exit(1);
  }

  // Run signup tests
  const results = {
    user: await testSignup('/auth/user/register', testUser, 'User'),
    vendor: await testSignup('/auth/vendor/register', testVendor, 'Vendor'),
    driver: await testSignup('/auth/driver/register', testDriver, 'Driver')
  };

  // Summary
  console.log('\n' + '='.repeat(50));
  console.log('Test Summary');
  console.log('='.repeat(50));
  console.log(`User Signup:   ${results.user ? '✓ PASSED' : '✗ FAILED'}`);
  console.log(`Vendor Signup: ${results.vendor ? '✓ PASSED' : '✗ FAILED'}`);
  console.log(`Driver Signup: ${results.driver ? '✓ PASSED' : '✗ FAILED'}`);
  
  const allPassed = results.user && results.vendor && results.driver;
  console.log('\n' + (allPassed ? '✓ All tests passed!' : '✗ Some tests failed'));
  
  process.exit(allPassed ? 0 : 1);
}

// Check if axios is installed
try {
  require.resolve('axios');
  runTests();
} catch (e) {
  console.log('Installing axios...');
  const { execSync } = require('child_process');
  execSync('npm install axios', { stdio: 'inherit' });
  runTests();
}
