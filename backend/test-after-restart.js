const axios = require('axios');

const BASE_URL = 'http://localhost:5000';

async function testAllEndpoints() {
  console.log('\n' + '═'.repeat(60));
  console.log('  🧪 TESTING ALL HOME SCREEN ENDPOINTS');
  console.log('═'.repeat(60) + '\n');

  let allPassed = true;

  // Test 1: Products Endpoint
  console.log('1️⃣  Testing Products API...');
  try {
    const productsRes = await axios.get(`${BASE_URL}/api/products`, {
      params: { status: 'active', limit: 10 }
    });

    if (productsRes.data.success) {
      console.log(`   ✅ Products API Working!`);
      console.log(`   📦 Found: ${productsRes.data.count} products`);
      
      if (productsRes.data.data.length > 0) {
        const p = productsRes.data.data[0];
        console.log(`   📋 Sample: ${p.name} - SDG ${p.price}`);
      }
    } else {
      console.log(`   ❌ Products API returned success: false`);
      allPassed = false;
    }
  } catch (error) {
    console.log(`   ❌ Products API Failed!`);
    console.log(`   Error: ${error.message}`);
    if (error.response?.data) {
      console.log(`   Details: ${JSON.stringify(error.response.data)}`);
    }
    allPassed = false;
  }

  console.log('');

  // Test 2: Vendors Endpoint
  console.log('2️⃣  Testing Vendors API...');
  try {
    const vendorsRes = await axios.get(`${BASE_URL}/api/auth/vendors`, {
      params: { status: 'active', limit: 10 }
    });

    if (vendorsRes.data.success) {
      console.log(`   ✅ Vendors API Working!`);
      console.log(`   🏪 Found: ${vendorsRes.data.count} vendors`);
      
      if (vendorsRes.data.data.length > 0) {
        const v = vendorsRes.data.data[0];
        console.log(`   📋 Sample: ${v.businessName}`);
        console.log(`   📍 Location: ${v.city || v.shopAddress}`);
        console.log(`   📞 Phone: ${v.phone || 'N/A'}`);
        
        if (!v.phone) {
          console.log(`   ⚠️  WARNING: Phone number missing! Backend needs restart!`);
          allPassed = false;
        }
      }
    } else {
      console.log(`   ❌ Vendors API returned success: false`);
      allPassed = false;
    }
  } catch (error) {
    console.log(`   ❌ Vendors API Failed!`);
    console.log(`   Error: ${error.message}`);
    if (error.response?.data) {
      console.log(`   Details: ${JSON.stringify(error.response.data)}`);
    }
    allPassed = false;
  }

  console.log('\n' + '═'.repeat(60));
  
  if (allPassed) {
    console.log('  ✅ ALL TESTS PASSED!');
    console.log('  🎉 Flutter app should work now!');
    console.log('\n  Next Steps:');
    console.log('  1. Open Flutter app');
    console.log('  2. Press \'R\' for hot restart');
    console.log('  3. Products and vendors should appear!');
  } else {
    console.log('  ❌ SOME TESTS FAILED!');
    console.log('\n  Troubleshooting:');
    console.log('  1. Make sure backend is running: node src/server.js');
    console.log('  2. Check database connection');
    console.log('  3. Verify products and vendors exist in database');
    console.log('  4. If phone missing, restart backend server!');
  }
  
  console.log('═'.repeat(60) + '\n');
}

// Run tests
testAllEndpoints().catch(err => {
  console.error('\n❌ Test script failed:', err.message);
  console.log('\n💡 Make sure backend server is running:');
  console.log('   cd backend && node src/server.js\n');
});
