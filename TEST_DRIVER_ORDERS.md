# Driver Orders Testing & Fixes

## Current Issues:

1. **"0 orders" displayed** - API needs driver authentication
2. **Map TypeError** - Google Maps initialization issue  
3. **No real data showing** - Need to login as driver first

---

## Quick Fixes:

### Fix 1: Login as Driver First

**Before testing dashboard, login as driver:**

```
Email: yusf@gmail.com
Phone: 03540837917
```

Or use the test driver:
```
Email: testdriver1780213223194@example.com
Phone: 03366906932
```

### Fix 2: Test API Endpoint Manually

```bash
# Step 1: Login as driver to get token
curl -X POST http://127.0.0.1:5000/api/auth/driver/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"yusf@gmail.com\",\"password\":\"your_password\"}"

# Step 2: Use token to get orders
curl -X GET "http://127.0.0.1:5000/api/orders/driver/orders?status=available" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## Database Check:

### Current Orders in Database:
```
✓ Order #7: SDG 3292 - Al Riyadh District, Khartoum
✓ Order #6: SDG 1050 - Al Riyadh District, Khartoum  
✓ Order #5: SDG 1050 - Al Riyadh District, Khartoum
✓ Order #4: SDG 51 - Al Riyadh District, Khartoum
✓ Order #3: SDG 1050 - Al Riyadh District, Khartoum

All orders: driver_id = NULL, status = 'pending'
```

### Missing Data in Orders:
```
❌ delivery_latitude - NULL
❌ delivery_longitude - NULL
```

**Need to add coordinates for proper map display!**

---

## Solution Steps:

### Step 1: Add Coordinates to Existing Orders

```sql
-- Add coordinates to Al Riyadh District orders
UPDATE orders 
SET delivery_latitude = 15.5107, 
    delivery_longitude = 32.5699 
WHERE delivery_address LIKE '%Al Riyadh%';
```

### Step 2: Activate Drivers

```sql
-- Activate test drivers
UPDATE drivers 
SET status = 'active' 
WHERE email IN ('yusf@gmail.com', 'testdriver1780213223194@example.com');
```

### Step 3: Login as Driver in App

1. Open app
2. Go to Driver Login screen
3. Enter: yusf@gmail.com
4. Enter your password
5. Login
6. Navigate to Driver Dashboard

### Step 4: View Orders

After login, dashboard should show all 5 orders!

---

## Alternative: Create Test Script

Create file: `backend/test-driver-dashboard.js`

```javascript
const axios = require('axios');

async function testDriverDashboard() {
  try {
    // Step 1: Login as driver
    console.log('1. Logging in as driver...');
    const loginRes = await axios.post('http://127.0.0.1:5000/api/auth/driver/login', {
      email: 'yusf@gmail.com',
      password: 'your_password'
    });
    
    const token = loginRes.data.token;
    console.log('✓ Login successful!');
    console.log('Token:', token.substring(0, 20) + '...');
    
    // Step 2: Get available orders
    console.log('\n2. Fetching available orders...');
    const ordersRes = await axios.get('http://127.0.0.1:5000/api/orders/driver/orders?status=available', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    
    console.log('✓ Orders fetched successfully!');
    console.log('Count:', ordersRes.data.count);
    console.log('\nOrders:');
    ordersRes.data.orders.forEach((order, index) => {
      console.log(`\n${index + 1}. Order #${order.order_number}`);
      console.log(`   Vendor: ${order.vendor_name}`);
      console.log(`   Amount: SDG ${order.final_amount}`);
      console.log(`   Address: ${order.delivery_address}`);
      console.log(`   Status: ${order.order_status}`);
    });
    
  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
  }
}

testDriverDashboard();
```

Run with: `node backend/test-driver-dashboard.js`

---

## Expected Flow:

```
User Flow:
1. Open App
   ↓
2. Login as Driver
   ↓
3. Navigate to Dashboard
   ↓
4. API Call with Token
   ↓
5. Backend checks role = 'driver'
   ↓
6. Fetch orders with driver_id = NULL
   ↓
7. Display 5 orders on screen
```

---

## Why "0 orders" Showing:

**Possible Reasons:**

1. ❌ **Not logged in as driver**
   - Solution: Login first

2. ❌ **Wrong role (logged in as user/vendor)**
   - Solution: Logout and login as driver

3. ❌ **Token expired/missing**
   - Solution: Re-login to get new token

4. ❌ **API endpoint not found**
   - Solution: Check backend is running on port 5000

5. ❌ **CORS error**
   - Solution: Check browser console for errors

---

## Debug Steps:

### 1. Check Backend Logs
```bash
cd backend
npm start
# Watch console for incoming requests
```

### 2. Check Flutter Logs
```bash
cd nafaj
flutter run -d chrome
# Watch console for API errors
```

### 3. Check Browser DevTools
- Open Chrome DevTools (F12)
- Go to Network tab
- Try to load dashboard
- Check if API call is made
- Check response status

---

## Common Errors & Solutions:

### Error: "Only drivers can access this endpoint"
**Solution:** Login as driver, not user/vendor

### Error: "401 Unauthorized"
**Solution:** Token missing or expired, re-login

### Error: "Failed to fetch orders"
**Solution:** Backend not running or wrong URL

### Error: "Cannot read properties of undefined"
**Solution:** Data structure mismatch, check API response

---

## Test Without Login (Temporary Fix):

If you want to test without authentication temporarily:

**Modify backend/src/controllers/OrderController.js:**

```javascript
// Comment out authentication check (TEMPORARY - FOR TESTING ONLY!)
static async getDriverOrders(req, res, next) {
  try {
    // TEMP: Skip auth check
    // if (req.user.role !== 'driver') {
    //   return res.status(403).json({ 
    //     success: false,
    //     error: 'Only drivers can access this endpoint' 
    //   });
    // }

    const { status } = req.query;
    const orders = await Order.findAvailableForDriver({ status });
    
    const ordersWithItems = await Promise.all(
      orders.map(async (order) => {
        const items = await Order.getOrderItems(order.id);
        return { ...order, items };
      })
    );

    return res.json({
      success: true,
      count: ordersWithItems.length,
      orders: ordersWithItems
    });
  } catch (error) {
    next(error);
  }
}
```

**⚠️ WARNING:** This is ONLY for testing! Remove this change before production!

---

## Production Solution:

**Keep authentication enabled and:**

1. ✅ Always login as driver first
2. ✅ Store token in local storage
3. ✅ Send token with every API request
4. ✅ Handle token expiration gracefully
5. ✅ Show login screen if not authenticated

---

## Next Steps:

1. **Run SQL Update** to add coordinates
2. **Activate drivers** in database
3. **Login as driver** in app
4. **Test dashboard** - should show 5 orders!
5. **Click accept** - should redirect to tracking
6. **Verify tracking page** shows all details

---

**Created:** June 8, 2026  
**Status:** Testing Required
