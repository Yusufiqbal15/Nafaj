# Order System Complete Guide 🚀

## Overview
Yeh system teen dashboards ke liye complete order management provide karta hai:
1. **User Dashboard** - Apne orders dekho
2. **Vendor Dashboard** - Apne products ke orders dekho
3. **Driver Dashboard** - Available orders dekho aur accept karo

---

## 🎯 Key Features

### ✅ User Dashboard
- User apne saare orders dekh sakta hai
- Order mein items ki complete details
- Vendor ka naam, email, phone number
- Order status track kar sakte hain
- Email pe order details milti hain

### ✅ Vendor Dashboard  
- Vendor ko sirf apne products ke orders dikhte hain
- Customer ki complete information (name, email, phone, address)
- Order items aur quantity
- Order status update kar sakte hain (confirmed, preparing, ready)
- Email pe notification

### ✅ Driver Dashboard
- Available orders dekh sakte hain (jo kisi driver ko assign nahi hue)
- Pickup location (vendor address)
- Delivery location (customer address)
- Order accept kar sakte hain
- Apne assigned orders track kar sakte hain
- Status update during delivery

---

## 📋 API Endpoints Summary

| Endpoint | Method | Role | Description |
|----------|--------|------|-------------|
| `/api/orders` | POST | User | Create new order |
| `/api/orders/my-orders` | GET | User | Get user's orders |
| `/api/orders/vendor/orders` | GET | Vendor | Get vendor's orders |
| `/api/orders/driver/orders` | GET | Driver | Get driver's orders |
| `/api/orders/driver/orders?status=available` | GET | Driver | Get available orders |
| `/api/orders/:id/accept` | PATCH | Driver | Accept an order |
| `/api/orders/:id/status` | PATCH | Vendor/Driver | Update order status |
| `/api/orders/:id` | GET | All | Get single order details |

---

## 🔄 Order Status Flow

```
pending → confirmed → preparing → ready → picked_up → delivered
           (Vendor)    (Vendor)   (Vendor)  (Driver)    (Driver)
```

### Status Meanings:
- **pending**: User ne order place kiya
- **confirmed**: Vendor ne order confirm kiya
- **preparing**: Vendor order tayyar kar raha hai
- **ready**: Order pickup ke liye ready hai
- **picked_up**: Driver ne order pickup kar liya
- **delivered**: Order customer ko deliver ho gaya
- **cancelled**: Order cancel ho gaya

---

## 📧 Email Integration

Har API response mein emails included hain:

### User Orders Response:
```json
{
  "user_email": "user@example.com",
  "vendor_email": "vendor@example.com",
  "vendor_name": "Fresh Grocery Store"
}
```

### Vendor Orders Response:
```json
{
  "user_email": "customer@example.com",
  "vendor_email": "vendor@example.com",
  "first_name": "John",
  "last_name": "Doe"
}
```

### Driver Orders Response:
```json
{
  "user_email": "customer@example.com",
  "vendor_email": "vendor@example.com",
  "vendor_name": "Fresh Grocery Store"
}
```

---

## 🧪 Testing

### Quick Test Commands:

1. **Test User Orders:**
```bash
node test-user-orders.js
```

2. **Test Vendor Orders:**
```bash
node test-vendor-orders.js
```

3. **Test Driver Available Orders:**
```bash
node test-driver-available-orders.js
```

4. **Test Driver Accept Order:**
```bash
node test-driver-accept-order.js
```

5. **Test Complete Flow:**
```bash
node test-order-complete-flow.js
```

### Manual Testing with Postman/Thunder Client:

#### 1. User Login & Get Orders:
```http
POST http://localhost:3000/api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

```http
GET http://localhost:3000/api/orders/my-orders
Authorization: Bearer <user_token>
```

#### 2. Vendor Login & Get Orders:
```http
POST http://localhost:3000/api/auth/vendor/login
Content-Type: application/json

{
  "email": "vendor@example.com",
  "password": "password123"
}
```

```http
GET http://localhost:3000/api/orders/vendor/orders
Authorization: Bearer <vendor_token>
```

#### 3. Driver Login & Get Available Orders:
```http
POST http://localhost:3000/api/auth/driver/login
Content-Type: application/json

{
  "email": "driver@example.com",
  "password": "password123"
}
```

```http
GET http://localhost:3000/api/orders/driver/orders?status=available
Authorization: Bearer <driver_token>
```

#### 4. Driver Accept Order:
```http
PATCH http://localhost:3000/api/orders/1/accept
Authorization: Bearer <driver_token>
```

---

## 💡 Example Response Data

### User Orders Response:
```json
{
  "success": true,
  "count": 2,
  "orders": [
    {
      "id": 1,
      "order_number": "ORD-1234567890-123",
      "user_email": "user@example.com",
      "vendor_name": "Fresh Grocery Store",
      "vendor_email": "vendor@example.com",
      "vendor_phone": "03001234567",
      "total_amount": 1500,
      "delivery_fee": 50,
      "final_amount": 1550,
      "order_status": "pending",
      "delivery_address": "House 123, Street 5, Karachi",
      "items": [
        {
          "product_name": "Fresh Apples",
          "quantity": 2,
          "unit_price": 500,
          "total_price": 1000
        }
      ]
    }
  ]
}
```

---

## 🔐 Authentication

Saare endpoints authentication require karte hain:

```
Authorization: Bearer <JWT_TOKEN>
```

Role-based access:
- **User**: Sirf apne orders dekh sakte hain
- **Vendor**: Sirf apne products ke orders dekh sakte hain
- **Driver**: Available orders dekh sakte hain aur accept kar sakte hain

---

## ⚡ Quick Start Guide

### 1. Server Start Karo:
```bash
cd backend
npm install
node src/server.js
```

### 2. Test User Create Karo:
```bash
node test-signup.js
```

### 3. Test Vendor Create Karo:
```bash
node test-create-vendor.js
```

### 4. Order Create Karo (as User):
```bash
node test-product-add.js
```

### 5. Complete Flow Test:
```bash
node test-order-complete-flow.js
```

---

## 📱 Integration with Mobile App

### User App:
```javascript
// Get user orders
const response = await fetch('http://localhost:3000/api/orders/my-orders', {
  headers: {
    'Authorization': `Bearer ${userToken}`
  }
});
const data = await response.json();
console.log('User Email:', data.orders[0].user_email);
console.log('Vendor Email:', data.orders[0].vendor_email);
```

### Vendor App:
```javascript
// Get vendor orders
const response = await fetch('http://localhost:3000/api/orders/vendor/orders', {
  headers: {
    'Authorization': `Bearer ${vendorToken}`
  }
});
const data = await response.json();
console.log('Customer Email:', data.orders[0].user_email);
console.log('Vendor Email:', data.orders[0].vendor_email);
```

### Driver App:
```javascript
// Get available orders
const response = await fetch('http://localhost:3000/api/orders/driver/orders?status=available', {
  headers: {
    'Authorization': `Bearer ${driverToken}`
  }
});
const data = await response.json();

// Accept order
await fetch(`http://localhost:3000/api/orders/${orderId}/accept`, {
  method: 'PATCH',
  headers: {
    'Authorization': `Bearer ${driverToken}`
  }
});
```

---

## 🐛 Common Issues & Solutions

### Issue 1: Orders nahi dikh rahe
**Solution**: Check karo ke user/vendor/driver logged in hai aur sahi token use ho raha hai

### Issue 2: Driver ko orders nahi dikh rahe  
**Solution**: Vendor ne order status "ready" par set kiya hai? Driver ko sirf ready orders dikhte hain

### Issue 3: Email null aa raha hai
**Solution**: Database mein users aur vendors table mein email column check karo

---

## 📞 Support

Koi problem ho toh:
1. Server logs check karo: `console` output dekho
2. Database connection check karo: `node test-db-connection.js`
3. API response dekho: Status code aur error message

---

## ✅ Features Checklist

- [x] User apne orders dekh sakta hai with email
- [x] Vendor ko apne products ke orders dikhte hain with customer email  
- [x] Driver ko available orders dikhte hain
- [x] Driver order accept kar sakta hai
- [x] Order status update hota hai
- [x] Order items with product details
- [x] Complete order flow testing
- [x] Role-based access control
- [x] Email addresses in all responses

---

## 🎉 Congratulations!

Aapka order management system ab complete hai! 

Users, Vendors, aur Drivers sab apne dashboards mein orders dekh sakte hain with complete details aur email addresses! 🚀
