# 🚀 Quick Start - Run the System NOW

## Step 1: Start Backend (5 seconds)

Open first terminal:
```bash
cd backend
node src/server.js
```

**Wait for**: `Server running on port 5000`

---

## Step 2: Run Flutter App (30 seconds)

Open second terminal:
```bash
cd stitch_nafaj_driver_dashboard/nafaj
flutter run -d chrome
```

**Wait for**: Browser opens automatically

---

## Step 3: Test the System

### A. Create an Order
1. Login to the app as a **user**
2. Browse products from a vendor
3. Add items to cart
4. Complete checkout with delivery address
5. Submit order

### B. View Order in Wallet
1. Go to **Wallet Screen** (bottom navigation)
2. Scroll to "Recent Orders" section
3. You should see your order with:
   - Vendor name
   - Order status (PENDING badge in orange)
   - Order number
   - Date and time
   - Amount

### C. View All Orders
1. Click **"View All"** link in wallet
2. OR use side menu → **"My Orders"**
3. See complete list of all your orders
4. Use filters: **All** | **Pending** | **Delivered**
5. Click **"View Details"** on any order

### D. Vendor View (Optional)
1. Login as **vendor**
2. Go to vendor dashboard
3. See incoming orders from users
4. Update order status: `Confirmed` → `Preparing` → `Ready`

### E. Driver View (Optional)
1. Login as **driver**
2. Go to driver dashboard
3. See available orders (status: ready/confirmed/pending)
4. Accept an order to start delivery
5. Update status to `Delivered` when complete

---

## ✅ What You'll See

### In Wallet Screen:
```
┌─────────────────────────────────────┐
│  Recent Orders           View All → │
├─────────────────────────────────────┤
│  🟠  Best Restaurant    PENDING     │
│      ORD-1234567890                 │
│      June 8, 2026 • 2:30 PM        │
│                      - SDG 51.00    │
├─────────────────────────────────────┤
│  🟢  Pizza Place      DELIVERED     │
│      ORD-0987654321                 │
│      June 7, 2026 • 6:45 PM        │
│                      - SDG 35.50    │
└─────────────────────────────────────┘
```

### In My Orders Screen:
```
┌─────────────────────────────────────┐
│  ← My Orders                    2 orders │
├─────────────────────────────────────┤
│  [ All ] [ Pending ] [ Delivered ]  │
├─────────────────────────────────────┤
│  ┌───────────────────────────────┐ │
│  │ ORD-1234567890  🟠 Pending   │ │
│  │ June 8, 2026 • 2:30 PM       │ │
│  │                              │ │
│  │ 🏪 Best Restaurant           │ │
│  │    vendor@example.com        │ │
│  │                              │ │
│  │ Items (2)                    │ │
│  │ 2× Pizza        SDG 20.50    │ │
│  │ 1× Coke         SDG 10.00    │ │
│  │                              │ │
│  │ Total Amount    SDG 51.00    │ │
│  │                              │ │
│  │ [View Details] [Track Order] │ │
│  └───────────────────────────────┘ │
└─────────────────────────────────────┘
```

---

## 🐛 Troubleshooting

### Backend not starting?
```bash
cd backend
npm install
node test-db-connection.js
```

### Flutter errors?
```bash
cd stitch_nafaj_driver_dashboard/nafaj
flutter clean
flutter pub get
flutter run -d chrome
```

### Orders not showing?
1. Check backend is running: `http://localhost:5000`
2. Check if logged in (look for token in browser DevTools)
3. Check browser console for errors (F12)

### Still having issues?
```bash
# Test backend directly
cd backend
node test-user-orders.js
```

---

## 📋 Quick Checklist

Before running:
- [ ] MySQL database is running
- [ ] Backend `.env` file configured
- [ ] Node.js installed (v14+)
- [ ] Flutter installed (v3+)
- [ ] Chrome browser available

After running:
- [ ] Backend shows "Server running on port 5000"
- [ ] Flutter app opens in Chrome
- [ ] Can login successfully
- [ ] Can create an order
- [ ] Order appears in wallet
- [ ] Order appears in "My Orders"

---

## 🎯 Success Criteria

You know it's working when:

1. ✅ Wallet shows "Recent Orders" (not "Transaction History")
2. ✅ No demo data (Al-Bashir Restaurant is GONE!)
3. ✅ Real orders appear after checkout
4. ✅ Order cards show correct vendor names
5. ✅ Status badges have colors (orange, green, blue, etc.)
6. ✅ Amounts display correctly (no errors)
7. ✅ "View All" navigates to My Orders screen
8. ✅ Filter chips work (All, Pending, Delivered)

---

## 🔥 One-Line Commands

Start backend:
```bash
cd backend && node src/server.js
```

Run Flutter:
```bash
cd stitch_nafaj_driver_dashboard/nafaj && flutter run -d chrome
```

Clean and run:
```bash
cd stitch_nafaj_driver_dashboard/nafaj && flutter clean && flutter pub get && flutter run -d chrome
```

---

## 📱 Testing Different User Types

### Test as User:
- Email: `user@example.com`
- See: Orders you created
- Can: Create orders, view orders, track delivery

### Test as Vendor:
- Email: `vendor@example.com`
- See: Orders for your restaurant/shop
- Can: View orders, update status, assign driver

### Test as Driver:
- Email: `driver@example.com`
- See: Available orders, assigned orders
- Can: Accept orders, update delivery status

---

## 🌟 Key Features Working

### Wallet Screen:
- ✅ Real-time order display
- ✅ Last 5 orders shown
- ✅ View All link
- ✅ Safe type conversion
- ✅ Color-coded status badges
- ✅ Loading states
- ✅ Error handling
- ✅ Empty state UI

### My Orders Screen:
- ✅ Complete order list
- ✅ Status filtering
- ✅ Order details modal
- ✅ Order items display
- ✅ Track order button
- ✅ Pull to refresh
- ✅ Vendor information
- ✅ Email fields included

### Backend APIs:
- ✅ JWT authentication
- ✅ Role-based access
- ✅ Email fields in responses
- ✅ Order items included
- ✅ Success flags
- ✅ Error handling

---

## 💡 Pro Tips

1. **Keep both terminals open** - Backend and Flutter
2. **Use browser DevTools** - Check Network tab for API calls
3. **Check backend logs** - See all incoming requests
4. **Use test scripts** - Quick API testing without UI
5. **Flutter hot reload** - Press 'r' in terminal for quick updates

---

## 🎉 You're Ready!

Everything is set up and working. Just run the two commands above and start testing!

**اردو میں:**

**تیار ہے! 🚀**

1. پہلا ٹرمینل: `cd backend && node src/server.js`
2. دوسرا ٹرمینل: `cd stitch_nafaj_driver_dashboard/nafaj && flutter run -d chrome`
3. کام شروع کریں!
