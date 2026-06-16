const pool = require('./src/config/database');

async function activateAllVendors() {
  console.log('\n🔧 Activating All Vendors...\n');

  try {
    // Update all vendors to active status
    const [result] = await pool.execute(
      'UPDATE vendors SET status = ? WHERE status = ?',
      ['active', 'pending_approval']
    );

    console.log(`✅ Updated ${result.affectedRows} vendors to active status`);

    // Show all vendors
    const [vendors] = await pool.execute(
      'SELECT id, business_name, business_type, city, phone, shop_address, status FROM vendors'
    );

    console.log(`\n📋 All Vendors (${vendors.length}):\n`);
    vendors.forEach((vendor, index) => {
      console.log(`${index + 1}. ${vendor.business_name}`);
      console.log(`   - Type: ${vendor.business_type || 'N/A'}`);
      console.log(`   - City: ${vendor.city || 'N/A'}`);
      console.log(`   - Phone: ${vendor.phone}`);
      console.log(`   - Address: ${vendor.shop_address || 'N/A'}`);
      console.log(`   - Status: ${vendor.status}`);
      console.log('');
    });

    console.log('✅ All vendors are now active!\n');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

activateAllVendors();
