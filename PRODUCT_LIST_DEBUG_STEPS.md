# Product List Not Showing - Debug Steps 🔍

## Issue
Products page par products nahi dikh rahe hain.

## Debug Steps

### Step 1: Console Output Check Karo
App run karo aur Products tab par jao. Console mein ye output dikhna chahiye:

```
=== Loading Vendor Products ===
=== Getting Vendor Products ===
Request URI: http://your-backend/products/vendor/my-products
Response status: 200
Response data: {success: true, count: 2, data: [...]}
Products count: 2
Products data type: List<dynamic>
Data received: [...]
Data type: List<dynamic>
Parsing product: {...}
Parsing product: {...}
Products parsed: 2
```

### Step 2: Agar Token Error Aaye

Agar ye error dikhe:
```
DioException: 401
Response: {error: No token provided}
```

**Solution:**
1. App ko completely close karo
2. Phir se run karo
3. Login karo fresh se
4. Token automatically save ho jayega

### Step 3: Agar Backend Not Running

Agar ye error dikhe:
```
DioException: Connection refused
```

**Solution:**
```bash
cd backend
node src/server.js
```

Backend should show:
```
Server running on port 3000
Database connected
```

### Step 4: Database Check Karo

Backend console mein ye query run kar ke dekho:

```bash
# Backend folder mein
node
```

```javascript
const mysql = require('mysql2/promise');

async function checkProducts() {
  const connection = await mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'your_password',
    database: 'your_database'
  });
  
  const [rows] = await connection.execute('SELECT * FROM products');
  console.log('Total products:', rows.length);
  console.log('Products:', rows);
  
  await connection.end();
}

checkProducts();
```

### Step 5: Manual API Test

Postman ya browser mein test karo:

**Request:**
```
GET http://localhost:3000/products/vendor/my-products
Headers:
  Authorization: Bearer YOUR_TOKEN_HERE
```

**Expected Response:**
```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "id": 1,
      "vendor_id": 1,
      "name": "Product 1",
      "price": 100,
      "images": ["url1", "url2"],
      ...
    }
  ]
}
```

### Step 6: Check Vendor Login

Console mein check karo vendor login ke baad:

```
=== Vendor Login Success ===
Token saved: eyJhbGc...
User ID: 1
Role: vendor
```

## Common Issues & Solutions

### Issue 1: "No products yet" dikhe par products database mein hain

**Problem:** Token missing ya wrong vendor_id
**Solution:**
1. Logout karo
2. Fresh login karo
3. Token save hoga properly

### Issue 2: Products add hote hain par list mein nahi dikhte

**Problem:** _loadProducts() call nahi ho raha after add
**Solution:** Already fixed - `_loadProducts()` is called after successful add

### Issue 3: Loading indicator hi dikhe

**Problem:** API call fail ho rahi hai
**Solution:** Console check karo error message

### Issue 4: Empty list dikhta hai

**Possible Reasons:**
1. Database mein products nahi hain
2. Wrong vendor_id se filter ho raha hai
3. Products deleted_at != NULL hain

**Check Database:**
```sql
SELECT id, vendor_id, name, deleted_at 
FROM products 
WHERE deleted_at IS NULL;
```

## Quick Test

### Test 1: Add Product Manually Database Mein

```sql
INSERT INTO products (
  vendor_id, 
  name, 
  price, 
  stock_quantity, 
  unit, 
  images, 
  created_at, 
  updated_at
) VALUES (
  1,                                          -- Your vendor ID
  'Test Product',
  999.99,
  10,
  'piece',
  '["https://via.placeholder.com/150"]',
  NOW(),
  NOW()
);
```

Phir app refresh karo - ye product dikhna chahiye.

### Test 2: Check API Response Directly

Browser mein (agar token hai):
```
http://localhost:3000/products/vendor/my-products
```

Ya curl se:
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:3000/products/vendor/my-products
```

## Expected Flow

1. ✅ App opens
2. ✅ ApiService.initialize() runs → Token interceptor active
3. ✅ User logs in → Token saved to secure storage
4. ✅ Navigate to Products tab → _loadProducts() called
5. ✅ API call with token → Backend gets vendor_id
6. ✅ Backend returns vendor's products → Frontend parses
7. ✅ Products display in list

## What to Send Me

Agar problem persist kare toh ye details bhejo:

1. **Console Output:**
   ```
   [Paste complete console output here]
   ```

2. **Backend Console Output:**
   ```
   [Paste backend logs here]
   ```

3. **Database Query Result:**
   ```sql
   SELECT COUNT(*) as total, vendor_id 
   FROM products 
   WHERE deleted_at IS NULL 
   GROUP BY vendor_id;
   ```

4. **Token Check:**
   - Logout karo
   - Login karo
   - Console mein "Token saved" message dikhe?

## Next Steps

1. **Run the app** with console open
2. **Go to Products tab**
3. **Copy paste console output** and send to me
4. I'll tell you exactly what's wrong

---

## Temporary Workaround

Agar urgent hai toh ye karo:

1. Backend mein directly products add karo database mein
2. Vendor_id apna login vendor ka use karo
3. App refresh karo

**Quick Add Script:**
```javascript
// backend/test-add-product.js
const pool = require('./src/config/database');

async function addTestProduct() {
  const [result] = await pool.execute(
    `INSERT INTO products (vendor_id, name, price, stock_quantity, unit, images, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())`,
    [1, 'Test Product', 500, 20, 'piece', '[]']
  );
  console.log('Product added:', result.insertId);
}

addTestProduct();
```

Run: `node backend/test-add-product.js`

---

**Abhi console output bhejo, main exact problem bataunga!** 🚀
