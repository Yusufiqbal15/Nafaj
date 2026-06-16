# Order Management API Guide

## Overview
This guide explains how orders work across User, Vendor, and Driver dashboards.

---

## API Endpoints

### 1. **USER - Get My Orders** 
View all orders placed by the logged-in user with complete details.

**Endpoint:** `GET /api/orders/my-orders`

**Headers:**
```
Authorization: Bearer <user_token>
```

**Query Parameters:**
- `status` (optional): Filter by order status (pending, confirmed, preparing, ready, picked_up, delivered, cancelled)

**Response:**
```json
{
  "success": true,
  "count": 2,
  "orders": [
    {
      "id": 1,
      "order_number": "ORD-1234567890-123",
      "user_id": 1,
      "vendor_id": 5,
      "vendor_name": "Fresh Grocery Store",
      "vendor_email": "vendor@example.com",
      "vendor_phone": "03001234567",
      "user_email": "user@example.com",
      "total_amount": 1500,
      "delivery_fee": 50,
      "final_amount": 1550,
      "order_status": "pending",
      "payment_status": "pending",
      "payment_method": "cash",
      "delivery_address": "House 123, Street 5, Karachi",
      "notes": "Please deliver before 5 PM",
      "created_at": "2024-01-15T10:30:00.000Z",
      "items": [
        {
          "id": 1,
          "order_id": 1,
          "product_id": 10,
          "product_name": "Fresh Apples",
          "quantity": 2,
          "unit_price": 500,
          "total_price": 1000,
          "images": "apple.jpg"
        },
        {
          "id": 2,
          "order_id": 1,
          "product_id": 11,
          "product_name": "Bananas",
          "quantity": 5,
          "unit_price": 100,
          "total_price": 500,
          "images": "banana.jpg"
        }
      ]
    }
  ]
}
```

---

### 2. **VENDOR - Get Vendor Orders**
View all orders for products belonging to the logged-in vendor.

**Endpoint:** `GET /api/orders/vendor/orders`

**Headers:**
```
Authorization: Bearer <vendor_token>
```

**Query Parameters:**
- `status` (optional): Filter by order status

**Response:**
```json
{
  "success": true,
  "count": 3,
  "orders": [
    {
      "id": 1,
      "order_number": "ORD-1234567890-123",
      "user_id": 1,
      "vendor_id": 5,
      "vendor_name": "Fresh Grocery Store",
      "vendor_email": "vendor@example.com",
      "user_email": "customer@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "phone": "03009876543",
      "total_amount": 1500,
      "delivery_fee": 50,
      "final_amount": 1550,
      "order_status": "confirmed",
      "payment_status": "pending",
      "payment_method": "cash",
      "delivery_address": "House 123, Street 5, Karachi",
      "notes": "Please deliver before 5 PM",
      "created_at": "2024-01-15T10:30:00.000Z",
      "items": [
        {
          "id": 1,
          "order_id": 1,
          "product_id": 10,
          "product_name": "Fresh Apples",
          "quantity": 2,
          "unit_price": 500,
          "total_price": 1000,
          "images": "apple.jpg"
        }
      ]
    }
  ]
}
```

---

### 3. **DRIVER - Get Available Orders**
View all orders available for pickup (not assigned to any driver yet).

**Endpoint:** `GET /api/orders/driver/orders?status=available`

**Headers:**
```
Authorization: Bearer <driver_token>
```

**Response:**
```json
{
  "success": true,
  "count": 5,
  "orders": [
    {
      "id": 1,
      "order_number": "ORD-1234567890-123",
      "user_id": 1,
      "vendor_id": 5,
      "vendor_name": "Fresh Grocery Store",
      "vendor_address": "Shop 10, Main Market, Karachi",
      "vendor_email": "vendor@example.com",
      "vendor_phone": "03001234567",
      "first_name": "John",
      "last_name": "Doe",
      "user_phone": "03009876543",
      "user_email": "customer@example.com",
      "total_amount": 1500,
      "delivery_fee": 50,
      "final_amount": 1550,
      "order_status": "ready",
      "payment_method": "cash",
      "delivery_address": "House 123, Street 5, Karachi",
      "delivery_latitude": 24.8607,
      "delivery_longitude": 67.0011,
      "created_at": "2024-01-15T10:30:00.000Z",
      "items": [
        {
          "id": 1,
          "order_id": 1,
          "product_id": 10,
          "product_name": "Fresh Apples",
          "quantity": 2,
          "unit_price": 500,
          "total_price": 1000,
          "images": "apple.jpg"
        }
      ]
    }
  ]
}
```

---

### 4. **DRIVER - Accept Order**
Driver accepts an available order for delivery.

**Endpoint:** `PATCH /api/orders/:id/accept`

**Headers:**
```
Authorization: Bearer <driver_token>
```

**Response:**
```json
{
  "success": true,
  "message": "Order accepted successfully",
  "orderId": 1
}
```

---

### 5. **DRIVER - Get My Orders**
View all orders assigned to the logged-in driver.

**Endpoint:** `GET /api/orders/driver/orders`

**Headers:**
```
Authorization: Bearer <driver_token>
```

**Query Parameters:**
- `status` (optional): Filter by order status

**Response:**
```json
{
  "success": true,
  "count": 2,
  "orders": [
    {
      "id": 1,
      "order_number": "ORD-1234567890-123",
      "driver_id": 3,
      "vendor_name": "Fresh Grocery Store",
      "vendor_email": "vendor@example.com",
      "vendor_phone": "03001234567",
      "first_name": "John",
      "last_name": "Doe",
      "user_phone": "03009876543",
      "user_email": "customer@example.com",
      "order_status": "picked_up",
      "delivery_address": "House 123, Street 5, Karachi",
      "items": [...]
    }
  ]
}
```

---

### 6. **Update Order Status**
Update the status of an order (Vendor or Driver only).

**Endpoint:** `PATCH /api/orders/:id/status`

**Headers:**
```
Authorization: Bearer <vendor_or_driver_token>
```

**Body:**
```json
{
  "status": "preparing"
}
```

**Valid Status Values:**
- `pending` - Initial order state
- `confirmed` - Vendor confirmed the order
- `preparing` - Vendor is preparing the order
- `ready` - Order is ready for pickup
- `picked_up` - Driver picked up the order
- `delivered` - Order delivered to customer
- `cancelled` - Order cancelled

**Response:**
```json
{
  "message": "Order status updated successfully"
}
```

---

## Order Flow

### Complete Order Lifecycle:

1. **User places order** → Status: `pending`
   - User creates order via `POST /api/orders`
   - Order appears in user's dashboard via `GET /api/orders/my-orders`

2. **Vendor receives order** → Status: `confirmed`
   - Vendor sees order in `GET /api/orders/vendor/orders`
   - Vendor confirms: `PATCH /api/orders/:id/status` → `confirmed`

3. **Vendor prepares order** → Status: `preparing`
   - Vendor updates: `PATCH /api/orders/:id/status` → `preparing`

4. **Order ready** → Status: `ready`
   - Vendor updates: `PATCH /api/orders/:id/status` → `ready`
   - Order now visible to drivers via `GET /api/orders/driver/orders?status=available`

5. **Driver accepts order** → Status: `picked_up`
   - Driver accepts: `PATCH /api/orders/:id/accept`
   - Order status automatically changes to `picked_up`
   - Driver assigned to order

6. **Driver delivers order** → Status: `delivered`
   - Driver updates: `PATCH /api/orders/:id/status` → `delivered`

---

## Testing Commands

### Test User Orders:
```bash
node test-user-orders.js
```

### Test Vendor Orders:
```bash
node test-vendor-orders.js
```

### Test Driver Available Orders:
```bash
node test-driver-available-orders.js
```

### Test Driver Accept Order:
```bash
node test-driver-accept-order.js
```

---

## Key Features:

✅ **User Dashboard:**
- View all orders with complete item details
- See vendor information (name, email, phone)
- Track order status in real-time

✅ **Vendor Dashboard:**
- View orders for their products only
- See customer information (name, email, phone, delivery address)
- Update order status (confirm, preparing, ready)
- View order items and quantities

✅ **Driver Dashboard:**
- View available orders (not assigned yet)
- See pickup location (vendor address)
- See delivery location (customer address)
- Accept orders for delivery
- View assigned orders
- Update order status during delivery

---

## Important Notes:

1. All endpoints require authentication via JWT token
2. Email addresses included in all responses for notifications
3. Orders automatically filtered by user role (user/vendor/driver)
4. Available orders shown to all drivers (status: ready, confirmed, or pending)
5. Once driver accepts, order becomes exclusive to that driver
6. Order items always included with product details and images
