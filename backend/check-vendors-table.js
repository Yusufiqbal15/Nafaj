const mysql = require('mysql2/promise');

async function checkVendorsTable() {
  const conn = await mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'Yusuf@15',
    database: 'nafaj'
  });
  
  const [cols] = await conn.execute('DESCRIBE vendors');
  console.log('\n=== Vendors Table Columns ===');
  cols.forEach(c => console.log(`- ${c.Field} (${c.Type})`));
  
  await conn.end();
}

checkVendorsTable().catch(console.error);
