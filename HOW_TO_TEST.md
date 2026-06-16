# How to Test Driver Dashboard - Complete Guide

## ✅ Database Setup Complete!

**Good News:** Database ab ready hai testing ke liye!

### What Was Fixed:

1. ✅ **Coordinates Added** - All 7 orders now have delivery_latitude and delivery_longitude
2. ✅ **Drivers Activated** - 2 drivers are now active and can login
3. ✅ **Backend Running** - Server is running on port 5000

---

## 🎯 Available Test Data

### Orders Ready for Delivery:
```
✓ 7 orders available
✓ All orders: driver_id = NULL (unassigned)
✓ All orders: status = 'pending' (ready for driver)
✓ All orders have coordinates for map display
✓ Vendor: Test Business
✓ Customer: yusuf
✓ Location: Al Riyadh District, Khartoum (15.5107°N, 32.5699°E)
```

### Test Driver Accounts:
```
Driver 1:
  Email: yusf@gmail.com
  Phone: 03540837917
  Status: active ✅

Driver 2:
  Email: testdriver1780213223194@example.com
  Phone: 03366906932
  Status: active ✅
```

---

## 📱 Testing Steps

### Step 1: Start Backend Server

```bash
cd backend
npm start
```

**Expected Output:**
```
✓ MySQL Database Connected Successfully
  Host: localhost
  Database: nafaj
Server running on port 5000
```

### Step 2: Start Flutter App

```bash
cd stitch_nafaj_driver_dashboard/nafaj
flutter run -d chrome
```

### Step 3: Login as Driver

**In the app:**

1. Navigate to **Driver Login** screen
2. Enter credentials:
   ```
   Email: yusf@gmail.com
   Password: [your password]
   ```
3. Click **Login**

**Expected Result:** Login successful, redirected to driver home/dashboard

### Step 4: Navigate to Driver Dashboard

1. Go to **Driver Dashboard** (Animated 3D screen)
2. Wait for orders to load

**Expected Result:**
```
✅ "Available Orders (7)" displayed
✅ 7 order cards visible
✅ Each card shows:
   - Order number
   - Restaurant: Test Business
   - Address: Al Riyadh District
   - Distance: ~1.4 km (calculated)
   - Time: ~13 mins (estimated)
   - Earnings: SDG 51 to SDG 3292
   - Status badge: NEW ORDER
```

### Step 5: Test Order Details

**On each order card, verify:**
- ✅ Restaurant name visible
- ✅ Delivery address visible
- ✅ Distance calculated and displayed
- ✅ Time estimate shown
- ✅ Earnings amount prominent
- ✅ "Slide to Accept" button present

### Step 6: Test Accept Order

1. Choose any order
2. **Slide the "Slide to Accept" button** completely to the right
3. Wait for response

**Expected Result:**
```
✅ Green success message appears
✅ Message: "Order accepted successfully! Redirecting to tracking..."
✅ After 500ms, navigate to tracking page
✅ Tracking page shows complete order details
```

### Step 7: Verify Tracking Page

**On tracking page, check:**
- ✅ Google Map loads (satellite view)
- ✅ Three markers visible:
  - 🚗 Green: Driver
  - 🏪 Red: Restaurant  
  - 🏠 Orange: Customer
- ✅ Order number displayed
- ✅ Customer name: yusuf
- ✅ Delivery address shown
- ✅ Order items list (if any)
- ✅ Earnings breakdown visible
- ✅ Progress timeline displayed

### Step 8: Test Back Navigation

1. Press **Back button** (top-left)
2. Return to dashboard

**Expected Result:**
```
✅ Navigate back to dashboard
✅ Orders list refreshes
✅ Accepted order NOT in available list (now has driver_id assigned)
✅ Remaining 6 orders visible
```

---

## 🐛 If You See "0 orders"

### Troubleshooting Checklist:

#### 1. Check if Logged In as Driver
```
❌ Not logged in
❌ Logged in as user/vendor (wrong role)
✅ Logged in as driver
```

**Solution:** Logout and login again with driver email

#### 2. Check Backend Server
```bash
# Check if backend is running
netstat -ano | findstr :5000

# Should show:
# TCP    0.0.0.0:5000    LISTENING
```

**Solution:** If not running, start with `npm start`

#### 3. Check Browser Console
```
Open Chrome DevTools (F12)
Go to Console tab
Look for errors
```

**Common Errors:**
- `401 Unauthorized` → Not logged in or token expired
- `403 Forbidden` → Wrong role (not driver)
- `Network Error` → Backend not running
- `CORS Error` → Check backend CORS settings

#### 4. Check Network Tab
```
Open Chrome DevTools (F12)
Go to Network tab
Look for API call to: /orders/driver/orders?status=available
Check response
```

**Expected Response:**
```json
{
  "success": true,
  "count": 7,
  "orders": [
    {
      "id": 7,
      "order_number": "ORD-1780928054570-913",
      "vendor_name": "Test Business",
      "final_amount": "3292.00",
      "delivery_address": "Al Riyadh District, Khartoum",
      "delivery_latitude": 15.5107,
      "delivery_longitude": 32.5699,
      ...
    }
  ]
}
```

#### 5. Manual API Test
```bash
# Test API directly
curl -X GET "http://127.0.0.1:5000/api/orders/driver/orders?status=available" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 🔑 Getting Auth Token

If you need to test API manually:

### Method 1: From Browser DevTools
1. Login as driver in app
2. Open Chrome DevTools (F12)
3. Go to Application tab
4. Look in Local Storage
5. Find key: `auth_token`
6. Copy the value

### Method 2: From Login API
```bash
curl -X POST http://127.0.0.1:5000/api/auth/driver/login \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"yusf@gmail.com\",
    \"password\": \"your_password\"
  }"
```

**Response contains:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 2,
    "email": "yusf@gmail.com",
    "role": "driver"
  }
}
```

---

## 📊 Expected Screen Views

### Driver Dashboard View:
```
┌─────────────────────────────────────┐
│  🟢 Online - Ready for orders      │
│                                     │
│  🔍 Search route or restaurant      │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│           Google Map                │
│    (Shows driver & order markers)   │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  Available Orders (7 orders)        │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  🟠 NEW ORDER                       │
│  Order #ORD-1780928054570-913       │
│  EARNINGS: SDG 3292                 │
│                                     │
│  Test Business                      │
│  📍 Al Riyadh District, Khartoum   │
│                                     │
│  📍 1.4 km    ⏰ 13 mins           │
│                                     │
│  [═══ Slide to Accept ═══►]        │
└─────────────────────────────────────┘

(6 more order cards...)
```

### Order Tracking View:
```
┌─────────────────────────────────────┐
│  [◄] 🟢 Driver is on the way       │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│         Google Map (Satellite)      │
│  🚗 Driver → 🏪 Restaurant → 🏠    │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  Order #ORD-XXX    [IN PROGRESS]    │
│                                     │
│  📍 DELIVERY LOCATION               │
│  Al Riyadh District, Khartoum      │
│                                     │
│  👤 CUSTOMER                        │
│  yusuf                  [📞 Call]   │
│  Phone number                       │
│                                     │
│  Order Items                        │
│  (if available)                     │
│                                     │
│  Order Amount        SDG XXX        │
│  Delivery Fee        SDG XX         │
│  YOUR EARNINGS       SDG XX         │
└─────────────────────────────────────┘
```

---

## 🎥 Testing Video Checklist

Record a video showing:

- [ ] Login as driver
- [ ] Navigate to dashboard
- [ ] See 7 orders displayed
- [ ] Check order details on card
- [ ] Slide to accept an order
- [ ] See success message
- [ ] Auto redirect to tracking
- [ ] Tracking page shows all details
- [ ] Map loads with markers
- [ ] Press back button
- [ ] Return to dashboard
- [ ] Orders list refreshed (6 remaining)

---

## 🚀 Performance Expectations

### Load Times:
```
Dashboard load:        < 2 seconds
Orders API call:       < 500ms
Distance calculation:  < 100ms per order
Map rendering:         < 1 second
Accept API call:       < 300ms
Navigation:            < 200ms
```

### Memory Usage:
```
Dashboard:            ~50-80 MB
With Google Maps:     ~120-150 MB
```

---

## 🔧 Quick Fixes

### Fix 1: If Map Shows Error

**Error:** "TypeError: Cannot read properties of undefined (reading 'MapTypeId')"

**Solution:** Add Google Maps API key:

1. Get API key from Google Cloud Console
2. Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

### Fix 2: If Distance Shows "N/A"

**Verify coordinates exist:**
```bash
cd backend
node fix-orders-data.js
```

### Fix 3: If Login Fails

**Check driver exists and is active:**
```sql
SELECT * FROM drivers WHERE email = 'yusf@gmail.com';
-- status should be 'active'
```

**If not active:**
```sql
UPDATE drivers SET status = 'active' WHERE email = 'yusf@gmail.com';
```

---

## 📝 Test Results Template

```
Date: ___________
Tester: ___________
Browser: Chrome / Firefox / Safari
Device: Desktop / Mobile

✅ Backend running: YES / NO
✅ Logged in as driver: YES / NO
✅ Orders loaded: YES / NO (Count: ___)
✅ Distance calculated: YES / NO
✅ Map displayed: YES / NO
✅ Accept order works: YES / NO
✅ Tracking page loads: YES / NO
✅ Back navigation works: YES / NO

Issues Found:
1. ___________
2. ___________

Notes:
___________
```

---

## 💡 Pro Tips

1. **Always login as driver first** before testing dashboard
2. **Check browser console** for any errors
3. **Use Chrome DevTools Network tab** to debug API calls
4. **Refresh page** if orders don't load initially
5. **Clear cache** if seeing old data
6. **Check backend logs** for server-side errors

---

## 🎓 Understanding the Flow

```
App Launch
    ↓
Driver Login (yusf@gmail.com)
    ↓
JWT Token Generated & Stored
    ↓
Navigate to Dashboard
    ↓
API Call: GET /orders/driver/orders?status=available
    Header: Authorization: Bearer <token>
    ↓
Backend Verifies Token
    ↓
Backend Checks Role = 'driver' ✅
    ↓
Backend Query:
    SELECT orders WHERE driver_id IS NULL 
    AND order_status IN ('pending', 'confirmed', 'ready')
    ↓
7 Orders Found
    ↓
For Each Order: Get Items from order_items table
    ↓
Return JSON Response with orders + items
    ↓
Flutter App Receives Data
    ↓
Calculate Distance for Each Order
    ↓
Estimate Delivery Time
    ↓
Format Data for Display
    ↓
Render 7 Order Cards
    ↓
User Slides to Accept Order #7
    ↓
API Call: PATCH /orders/7/accept
    Header: Authorization: Bearer <token>
    ↓
Backend Updates:
    orders.driver_id = 2
    orders.order_status = 'picked_up'
    ↓
Success Response
    ↓
Show Success Message
    ↓
Navigate to Tracking Page (with order data)
    ↓
Tracking Page Displays:
    - Map with markers
    - Order details
    - Customer info
    - Earnings breakdown
    ↓
User Presses Back
    ↓
Return to Dashboard
    ↓
Refresh Orders List
    ↓
Now Shows 6 Orders (Order #7 removed - has driver_id)
```

---

## ✅ Success Criteria

Your test is successful if:

1. ✅ Can login as driver
2. ✅ Dashboard shows 7 orders
3. ✅ Each order shows all details (restaurant, address, distance, time, earnings)
4. ✅ Distance calculated correctly (~1.4 km)
5. ✅ Can slide to accept order
6. ✅ Success message appears
7. ✅ Auto-redirect to tracking page
8. ✅ Tracking page shows complete details
9. ✅ Map loads with 3 markers
10. ✅ Back button returns to dashboard
11. ✅ Orders list refreshes showing 6 orders

---

## 🎉 You're Ready to Test!

**Everything is set up. Just follow these 4 simple steps:**

1. **Start backend:** `cd backend && npm start`
2. **Start app:** `cd nafaj && flutter run -d chrome`
3. **Login:** Use `yusf@gmail.com` as driver
4. **Test:** Navigate to dashboard and see 7 orders!

**Good luck! 🚀**

---

**Document Version:** 1.0.0  
**Last Updated:** June 8, 2026  
**Status:** Ready for Testing ✅
