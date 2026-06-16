# 🧪 API Testing Guide

## Quick Start Testing

### 1. Start Backend Server
```bash
cd backend
npm install
npm run migrate
npm run dev
```

### 2. Test Authentication

#### Register User
```bash
curl -X POST http://localhost:5000/api/auth/user/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@test.com",
    "phone": "+249912345678",
    "password": "password123",
    "firstName": "Ahmed",
    "lastName": "Mohamed"
  }'
```

#### Register Vendor
```bash
curl -X POST http://localhost:5000/api/auth/vendor/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "vendor@test.com",
    "phone": "+249912345679",
    "password": "password123",
    "businessName": "Ahmed Store",
    "ownerFirstName": "Ahmed",
    "ownerLastName": "Ali",
    "city": "Khartoum"
  }'
```

#### Login Vendor
```bash
curl -X POST http://localhost:5000/api/auth/vendor/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "vendor@test.com",
    "password": "password123"
  }'
```

**Save the token from response!**

### 3. Test Product Management

#### Add Product (Vendor)
```bash
curl -X POST http://localhost:5000/api/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_VENDOR_TOKEN" \
  -d '{
    "name": "Fresh Tomatoes",
    "description": "Organic fresh tomatoes",
    "category": "Vegetables",
    "price": 25.50,
    "stockQuantity": 100,
    "unit": "kg"
  }'
```

#### Get All Products
```bash
curl http://localhost:5000/api/products
```

#### Get Vendor Products
```bash
curl http://localhost:5000/api/products/vendor/my-products \
  -H "Authorization: Bearer YOUR_VENDOR_TOKEN"
```

### 4. Test Orders

#### Create Order (User)
```bash
curl -X POST http://localhost:5000/api/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_USER_TOKEN" \
  -d '{
    "vendorId": 1,
    "items": [
      {
        "productId": 1,
        "quantity": 2
      }
    ],
    "deliveryAddress": "Khartoum, Street 45",
    "paymentMethod": "cash"
  }'
```

#### Get User Orders
```bash
curl http://localhost:5000/api/orders/my-orders \
  -H "Authorization: Bearer YOUR_USER_TOKEN"
```

#### Get Vendor Orders
```bash
curl http://localhost:5000/api/orders/vendor/orders \
  -H "Authorization: Bearer YOUR_VENDOR_TOKEN"
```

## Testing with Postman

### 1. Import Collection

Create a new Postman collection with these requests:

**Environment Variables:**
- `base_url`: http://localhost:5000/api
- `user_token`: (will be set after login)
- `vendor_token`: (will be set after login)
- `driver_token`: (will be set after login)

### 2. Authentication Requests

#### User Register
- Method: POST
- URL: `{{base_url}}/auth/user/register`
- Body (JSON):
```json
{
  "email": "user@test.com",
  "phone": "+249912345678",
  "password": "password123",
  "firstName": "Ahmed",
  "lastName": "Mohamed"
}
```

#### Vendor Register
- Method: POST
- URL: `{{base_url}}/auth/vendor/register`
- Body (JSON):
```json
{
  "email": "vendor@test.com",
  "phone": "+249912345679",
  "password": "password123",
  "businessName": "Ahmed Store",
  "ownerFirstName": "Ahmed",
  "ownerLastName": "Ali",
  "city": "Khartoum"
}
```

#### Login (Save token to environment)
- Method: POST
- URL: `{{base_url}}/auth/vendor/login`
- Body (JSON):
```json
{
  "email": "vendor@test.com",
  "password": "password123"
}
```
- Tests (to save token):
```javascript
pm.environment.set("vendor_token", pm.response.json().token);
```

### 3. Product Requests

#### Create Product
- Method: POST
- URL: `{{base_url}}/products`
- Headers: `Authorization: Bearer {{vendor_token}}`
- Body (JSON):
```json
{
  "name": "Fresh Tomatoes",
  "description": "Organic fresh tomatoes",
  "category": "Vegetables",
  "price": 25.50,
  "stockQuantity": 100,
  "unit": "kg",
  "images": ["tomato1.jpg", "tomato2.jpg"]
}
```

#### Get All Products
- Method: GET
- URL: `{{base_url}}/products`

#### Get Vendor Products
- Method: GET
- URL: `{{base_url}}/products/vendor/my-products`
- Headers: `Authorization: Bearer {{vendor_token}}`

### 4. Order Requests

#### Create Order
- Method: POST
- URL: `{{base_url}}/orders`
- Headers: `Authorization: Bearer {{user_token}}`
- Body (JSON):
```json
{
  "vendorId": 1,
  "items": [
    {
      "productId": 1,
      "quantity": 2
    }
  ],
  "deliveryAddress": "Khartoum, Street 45",
  "paymentMethod": "cash",
  "notes": "Please call before delivery"
}
```

## Expected Responses

### Successful Registration
```json
{
  "message": "User registered successfully",
  "userId": 1,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userType": "user"
}
```

### Successful Login
```json
{
  "message": "Login successful",
  "userId": 1,
  "email": "user@test.com",
  "firstName": "Ahmed",
  "lastName": "Mohamed",
  "status": "active",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "userType": "user"
}
```

### Product Created
```json
{
  "message": "Product created successfully",
  "productId": 1
}
```

### Order Created
```json
{
  "message": "Order created successfully",
  "orderId": 1,
  "orderNumber": "ORD-1234567890-123",
  "finalAmount": 101.00
}
```

## Common Errors

### 400 Bad Request
```json
{
  "error": "Email, phone, and password are required"
}
```

### 401 Unauthorized
```json
{
  "error": "Invalid email or password"
}
```

### 403 Forbidden
```json
{
  "error": "Only vendors can add products"
}
```

### 404 Not Found
```json
{
  "error": "Product not found"
}
```

## Testing Workflow

1. **Register Users**
   - Register a user account
   - Register a vendor account
   - Register a driver account

2. **Login and Get Tokens**
   - Login as user → save user_token
   - Login as vendor → save vendor_token
   - Login as driver → save driver_token

3. **Vendor Adds Products**
   - Use vendor_token
   - Create 3-5 products
   - Verify products appear in list

4. **User Places Order**
   - Use user_token
   - Browse products
   - Create order with multiple items
   - Verify order created

5. **Vendor Manages Order**
   - Use vendor_token
   - View orders
   - Update order status
   - Assign driver

6. **Driver Delivers Order**
   - Use driver_token
   - View assigned orders
   - Update delivery status

## Database Verification

Check data in MySQL:

```sql
-- Check users
SELECT * FROM users;

-- Check vendors
SELECT * FROM vendors;

-- Check products
SELECT * FROM products;

-- Check orders
SELECT * FROM orders;

-- Check order items
SELECT * FROM order_items;
```

## Success Criteria

✅ All user types can register
✅ All user types can login
✅ Tokens are generated correctly
✅ Vendors can add products
✅ Products are stored in database
✅ Users can place orders
✅ Orders are stored with items
✅ Stock is updated after order
✅ Vendors can view their orders
✅ Drivers can view assigned orders

## Troubleshooting

### Server won't start
- Check MySQL is running
- Verify .env credentials
- Run migrations first

### Authentication fails
- Check token format
- Verify token not expired
- Check Authorization header

### Products not saving
- Verify vendor is logged in
- Check vendor_id in token
- Verify database connection

### Orders fail
- Check product stock
- Verify product exists
- Check user authentication
