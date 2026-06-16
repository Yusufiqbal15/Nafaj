const axios = require('axios');

const BASE_URL = 'http://localhost:5000';

async function testHomeScreenData() {
  console.log('\n🧪 Testing Home Screen Data...\n');

  try {
    // Test 1: Get Products
    console.log('1️⃣  Testing Products Endpoint...');
    const productsRes = await axios.get(`${BASE_URL}/api/products`, {
      params: {
        status: 'active',
        limit: 10
      }
    });

    console.log(`✅ Products Response:`);
    console.log(`   - Success: ${productsRes.data.success}`);
    console.log(`   - Count: ${productsRes.data.count}`);
    console.log(`   - Products Found: ${productsRes.data.data.length}`);
    
    if (productsRes.data.data.length > 0) {
      const firstProduct = productsRes.data.data[0];
      console.log(`\n   📦 Sample Product:`);
      console.log(`   - ID: ${firstProduct.id}`);
      console.log(`   - Name: ${firstProduct.name}`);
      console.log(`   - Price: SDG ${firstProduct.price}`);
      console.log(`   - Unit: ${firstProduct.unit || 'N/A'}`);
      console.log(`   - Images: ${firstProduct.images?.length || 0}`);
      if (firstProduct.images && firstProduct.images.length > 0) {
        console.log(`   - First Image: ${firstProduct.images[0].substring(0, 60)}...`);
      }
    } else {
      console.log('   ⚠️  No products found. Add some products first!');
    }

    // Test 2: Get Vendors
    console.log('\n2️⃣  Testing Vendors Endpoint...');
    const vendorsRes = await axios.get(`${BASE_URL}/auth/vendors`, {
      params: {
        status: 'active',
        limit: 10
      }
    });

    console.log(`✅ Vendors Response:`);
    console.log(`   - Success: ${vendorsRes.data.success}`);
    console.log(`   - Count: ${vendorsRes.data.count}`);
    console.log(`   - Vendors Found: ${vendorsRes.data.data.length}`);
    
    if (vendorsRes.data.data.length > 0) {
      const firstVendor = vendorsRes.data.data[0];
      console.log(`\n   🏪 Sample Vendor:`);
      console.log(`   - ID: ${firstVendor.id}`);
      console.log(`   - Business Name: ${firstVendor.businessName}`);
      console.log(`   - Business Type: ${firstVendor.businessType || 'N/A'}`);
      console.log(`   - City: ${firstVendor.city || 'N/A'}`);
      console.log(`   - Total Products: ${firstVendor.totalProducts || 0}`);
      console.log(`   - Rating: ${firstVendor.rating || 0}`);
    } else {
      console.log('   ⚠️  No vendors found. Register some vendors first!');
    }

    // Summary
    console.log('\n' + '='.repeat(50));
    console.log('📊 SUMMARY');
    console.log('='.repeat(50));
    console.log(`✅ Products API: Working (${productsRes.data.data.length} products)`);
    console.log(`✅ Vendors API: Working (${vendorsRes.data.data.length} vendors)`);
    
    if (productsRes.data.data.length === 0) {
      console.log('\n⚠️  WARNING: No products available for home screen!');
      console.log('   👉 Add products using vendor dashboard');
    }
    
    if (vendorsRes.data.data.length === 0) {
      console.log('\n⚠️  WARNING: No vendors available for home screen!');
      console.log('   👉 Register vendors using signup');
    }

    if (productsRes.data.data.length > 0 && vendorsRes.data.data.length > 0) {
      console.log('\n🎉 Home screen has data! Ready to test in Flutter app!');
    }

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    if (error.response) {
      console.error('Response Status:', error.response.status);
      console.error('Response Data:', error.response.data);
    } else if (error.code === 'ECONNREFUSED') {
      console.error('\n🚫 Cannot connect to backend!');
      console.error('   👉 Make sure backend is running: node src/server.js');
    }
  }
}

// Run the test
console.log('═'.repeat(50));
console.log('  HOME SCREEN DATA TEST');
console.log('═'.repeat(50));

testHomeScreenData();
