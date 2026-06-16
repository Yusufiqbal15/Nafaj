const mysql = require('mysql2/promise');

async function addVendorImage() {
  const conn = await mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'Yusuf@15',
    database: 'nafaj'
  });
  
  // Add profile image to first vendor (Test Business)
  await conn.execute(
    'UPDATE vendors SET profile_image = ? WHERE id = ?',
    ['/uploads/images-1780492168467-92994212.png', 1]
  );
  
  console.log('✓ Added profile image to Test Business');
  
  // Add to Fresh Market Grocery
  await conn.execute(
    'UPDATE vendors SET profile_image = ? WHERE id = ?',
    ['/uploads/images-1780491446532-642690805.png', 5]
  );
  
  console.log('✓ Added profile image to Fresh Market Grocery');
  
  // Check updated vendors
  const [vendors] = await conn.execute(
    'SELECT id, business_name, profile_image FROM vendors WHERE id IN (1, 5)'
  );
  
  console.log('\n=== Vendors with Images ===');
  vendors.forEach(v => {
    console.log(`${v.id}. ${v.business_name} - ${v.profile_image}`);
  });
  
  await conn.end();
}

addVendorImage().catch(console.error);
