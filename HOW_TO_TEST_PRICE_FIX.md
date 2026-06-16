# 🧪 How to Test Price Fix

## ✅ Changes Made

Fixed pricing to show **discount_price** consistently across:
- Product display in marketplace
- Cart calculations
- Checkout totals  
- Order history

## 🚀 Quick Test Steps

### Step 1: Restart Flutter App

**Option A: Hot Restart (Recommended)**
```
1. Go to the terminal where Flutter is running
2. Press 'R' (capital R) for hot restart
3. Wait for "Application finished" message
```

**Option B: Full Restart**
```bash
# Stop current app (press 'q' in Flutter terminal)
# Then run:
cd stitch_nafaj_driver_dashboard/nafaj
flutter run -d chrome --web-port=8080
```

---

### Step 2: Test with Existing Product

**Go to Vendor Dashboard:**
1. Login as vendor
2. Go to Products section
3. Find a product

**Check Product Prices:**
```
Example Product:
- Regular Price: 1000 SDG
- Discount Price: 1 SDG  (or 100 SDG)
```

**Current Expected Behavior:**
- If product has `discount_price` set, that price should show everywhere
- If no `discount_price`, regular `price` shows

---

### Step 3: Test User Flow

**As User (Customer):**

1. **Browse Products**
   - Open marketplace/home screen
   - Look at product prices
   - **Expected**: Should show discount_price if available

2. **Add to Cart**
   - Add 2-3 products to cart
   - Check cart total
   - **Expected**: Cart total = (discount_price × quantity) for each item

3. **Checkout**
   - Go to checkout screen
   - Verify subtotal matches cart
   - **Expected**: Each item shows correct price per unit

4. **Place Order**
   - Complete the order
   - Note the order number

5. **Check Order History**
   - Go to Orders screen (click Orders in bottom nav)
   - Find your order
   - Check item prices
   - **Expected**: Order shows same prices you saw in cart

---

### Step 4: Verify Database (Optional)

**Check what's saved in database:**

```bash
cd backend
node -e "
const pool = require('./src/config/database');
(async () => {
  const [orders] = await pool.execute('SELECT * FROM orders ORDER BY id DESC LIMIT 1');
  console.log('Latest Order:', orders[0]);
  
  if (orders[0]) {
    const [items] = await pool.execute('SELECT oi.*, p.name, p.price, p.discount_price FROM order_items oi JOIN products p ON oi.product_id = p.id WHERE oi.order_id = ?', [orders[0].id]);
    console.log('Order Items:');
    items.forEach(item => {
      console.log('  -', item.name);
      console.log('    Product Price:', item.price);
      console.log('    Product Discount:', item.discount_price);
      console.log('    Saved Unit Price:', item.unit_price);
      console.log('    Total Price:', item.total_price);
    });
  }
  process.exit(0);
})();
"
```

**Expected Output:**
```
Order Items:
  - Product Name
    Product Price: 1000.00
    Product Discount: 1.00
    Saved Unit Price: 1.00  ← Should match discount_price
    Total Price: 2.00        ← Should be unit_price × quantity
```

---

## 🎯 Success Criteria

### ✅ Pass Conditions

1. **Product Display**
   - Shows discount_price when available ✅
   - Shows regular price when no discount ✅

2. **Cart Calculations**
   - Cart total matches displayed prices ✅
   - Subtotal = sum of (effective_price × quantity) ✅

3. **Order Creation**
   - Backend saves correct unit_price ✅
   - unit_price = discount_price (if available) or price ✅

4. **Order Display**
   - Order history shows same prices ✅
   - No duplicate or wrong amounts ✅

### ❌ Fail Conditions

If you see:
- Cart showing 1000 SDG but product showed 100 SDG
- Order history showing 1000 SDG but you were charged 100 SDG
- Different prices in cart vs checkout vs order history

Then please report the specific screen and values.

---

## 🐛 Common Issues & Solutions

### Issue 1: Still Seeing Old Prices
**Solution**: Make sure you did **Hot Restart (R)** not just hot reload (r)

### Issue 2: Cart Service Error
**Solution**: 
```bash
cd nafaj
flutter clean
flutter pub get
flutter run -d chrome --web-port=8080
```

### Issue 3: Products Not Loading
**Solution**: Check backend is running on port 5000
```bash
cd backend
node src/server.js
```

---

## 📸 Visual Test Guide

### 1. Product Card Should Show:
```
┌─────────────────┐
│   [Image]       │
│                 │
│ Product Name    │
│ 100 SDG    ← This should be discount_price
│                 │
│ [+ Add to Cart] │
└─────────────────┘
```

### 2. Cart Should Show:
```
┌──────────────────────────────┐
│ My Cart                      │
│                              │
│ Product Name                 │
│ 2 × 100 SDG = 200 SDG   ← Correct calculation
│                              │
│ Subtotal:       200 SDG      │
│ Delivery:        50 SDG      │
│ Total:          250 SDG      │
└──────────────────────────────┘
```

### 3. Order History Should Show:
```
┌──────────────────────────────┐
│ Order #ORD-XXX               │
│                              │
│ Product Name                 │
│ 2 kg × 100 SDG = 200 SDG ← Same as cart
│                              │
│ Total: 250 SDG               │
└──────────────────────────────┘
```

---

## ✅ Quick Verification

**One-liner test:**
1. Check product price on home: **100 SDG**
2. Add 2 to cart, check cart total: **200 SDG**
3. Place order
4. Check order history: **2 × 100 = 200 SDG**

If all three show the same price (100 SDG per item), **TEST PASSED** ✅

---

## 📞 Report Results

After testing, please confirm:
- ✅ "All prices match - Fixed!" 
- ❌ "Still seeing issue: [describe what you see]"

---

**Happy Testing!** 🎉
