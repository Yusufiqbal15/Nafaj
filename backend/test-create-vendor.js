const axios = require('axios');

const BASE_URL = 'http://localhost:5000';

async function createTestVendor() {
  console.log('\n🏪 Creating Test Vendor...\n');

  try {
    const vendorData = {
      email: 'testshop@nafaj.com',
      phone: '03001234567',
      password: 'password123',
      businessName: 'Fresh Market Grocery',
      ownerFirstName: 'Ahmed',
      ownerLastName: 'Ali',
      businessType: 'grocery',
      shopAddress: 'Al-Qasr Street, Block 5',
      city: 'Khartoum',
      ntnNumber: 'NTN123456'
    };

    console.log('Vendor Data:', {
      email: vendorData.email,
      businessName: vendorData.businessName,
      businessType: vendorData.businessType,
      city: vendorData.city
    });

    const response = await axios.post(
      `${BASE_URL}/api/auth/vendor/register`,
      vendorData
    );

    console.log('\n✅ Vendor Created Successfully!');
    console.log('Response:', {
      success: response.data.success,
      vendorId: response.data.data.vendorId,
      businessName: response.data.data.businessName,
      token: response.data.data.token.substring(0, 20) + '...'
    });

    // Now check if vendor appears in list
    console.log('\n📋 Checking Vendors List...');
    const listResponse = await axios.get(`${BASE_URL}/api/auth/vendors?status=active`);
    
    console.log(`\n✅ Vendors Found: ${listResponse.data.count}`);
    if (listResponse.data.count > 0) {
      console.log('\nVendor Details:');
      listResponse.data.data.forEach((vendor, index) => {
        console.log(`\n${index + 1}. ${vendor.businessName}`);
        console.log(`   - Business Type: ${vendor.businessType}`);
        console.log(`   - City: ${vendor.city}`);
        console.log(`   - Phone: ${vendor.phone}`);
        console.log(`   - Address: ${vendor.shopAddress}`);
        console.log(`   - Total Products: ${vendor.totalProducts}`);
      });
    }

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Error Data:', error.response.data);
      
      if (error.response.data.error?.includes('already registered')) {
        console.log('\n✅ Vendor already exists! Checking list...');
        const listResponse = await axios.get(`${BASE_URL}/api/auth/vendors?status=active`);
        console.log(`Vendors Found: ${listResponse.data.count}`);
      }
    }
  }
}

createTestVendor();
