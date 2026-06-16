const pool = require('./src/config/database');

async function checkProducts() {
  try {
    const [rows] = await pool.execute(
      'SELECT id, vendor_id, name, price, images, deleted_at FROM products'
    );
    
    console.log('\n=== ALL PRODUCTS IN DATABASE ===');
    console.log('Total products:', rows.length);
    console.log('\nProducts:');
    rows.forEach(product => {
      console.log(`\nID: ${product.id}`);
      console.log(`Vendor ID: ${product.vendor_id}`);
      console.log(`Name: ${product.name}`);
      console.log(`Price: ${product.price}`);
      console.log(`Images: ${product.images}`);
      console.log(`Deleted: ${product.deleted_at ? 'YES' : 'NO'}`);
    });
    
    const [activeRows] = await pool.execute(
      'SELECT COUNT(*) as count FROM products WHERE deleted_at IS NULL'
    );
    console.log(`\n\nACTIVE Products (not deleted): ${activeRows[0].count}`);
    
    await pool.end();
  } catch (error) {
    console.error('Error:', error);
  }
}

checkProducts();
