# 🎯 Complete Testing Guide - 3 User Types (User, Driver, Vendor)

## Setup Instructions

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Create Database
```bash
mysql -u root -pYusuf@15 -e "CREATE DATABASE nafaj;"
```

### 3. Run Migrations (Creates All 3 Tables)
```bash
npm run migrate
```

### 4. Start Server
```bash
npm run dev
```

Server will run on `http://localhost:5000`

---

## 📋 Database Tables Created

### 1. **users** table (Regular Users)
- email, phone, password (hashed)
- first_name, last_name
- status (active, inactive, suspended)
- rating, reviews_count
- Timestamps: created_at, updated_at, deleted_at

### 2. **drivers** table (Drivers)
- email, phone, password (hashed)
- first_name, last_name
- license_number, vehicle_type, vehicle_plate
- status (active, inactive, suspended, pending_verification)
- Documents verification, ratings, earnings
- Timestamps: created_at, updated_at, deleted_at

### 3. **vendors** table (Vendors)
- email, phone, password (hashed)
- business_name, owner_first_name, owner_last_name
- business_type, shop_address, city
- status (active, inactive, suspended, pending_approval)
- NTN number, document verification, earnings
- Timestamps: created_at, updated_at, deleted_at

---

## 🧪 Testing - USER TYPE

### USER: Register (Sign Up)
```bash
curl -X POST http://localhost:5000/api/auth/user/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "phone": "03001234567",
    "password": "User@123",
    "firstName": "Ahmed",
    "lastName": "Hassan"
  }'
```

**Expected Response:**
```json
{
  "message": "User registered successfully",
  "userId": 1,
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "userType": "user"
}
```

### USER: Login
```bash
curl -X POST http://localhost:5000/api/auth/user/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "User@123"
  }'
```

**Expected Response:**
```json
{
  "message": "Login successful",
  "userId": 1,
  "email": "user@example.com",
  "firstName": "Ahmed",
  "lastName": "Hassan",
  "status": "active",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "userType": "user"
}
```

**Save this token!** Use it in header as: `Authorization: Bearer TOKEN`

### USER: Get Profile (needs login token)
```bash
curl http://localhost:5000/api/auth/user/profile \
  -H "Authorization: Bearer YOUR_USER_TOKEN_HERE"
```

**Expected Response:**
```json
{
  "id": 1,
  "email": "user@example.com",
  "phone": "03001234567",
  "firstName": "Ahmed",
  "lastName": "Hassan",
  "status": "active",
  "rating": 0,
  "reviewsCount": 0,
  "createdAt": "2026-05-23T...",
  "userType": "user"
}
```

### USER: Update Profile
```bash
curl -X PUT http://localhost:5000/api/auth/user/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_USER_TOKEN_HERE" \
  -d '{
    "firstName": "Ahmed",
    "lastName": "Khan",
    "phone": "03009876543"
  }'
```

---

## 🚗 Testing - DRIVER TYPE

### DRIVER: Register (Sign Up)
```bash
curl -X POST http://localhost:5000/api/auth/driver/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "driver@example.com",
    "phone": "03105551234",
    "password": "Driver@123",
    "firstName": "Ali",
    "lastName": "Khan",
    "licenseNumber": "DL-12345-ABC",
    "vehicleType": "Car",
    "vehiclePlate": "ABC-123"
  }'
```

**Expected Response:**
```json
{
  "message": "Driver registered successfully",
  "driverId": 1,
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "userType": "driver"
}
```

### DRIVER: Login
```bash
curl -X POST http://localhost:5000/api/auth/driver/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "driver@example.com",
    "password": "Driver@123"
  }'
```

**Expected Response:**
```json
{
  "message": "Login successful",
  "driverId": 1,
  "email": "driver@example.com",
  "firstName": "Ali",
  "lastName": "Khan",
  "licenseNumber": "DL-12345-ABC",
  "vehicleType": "Car",
  "status": "pending_verification",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "userType": "driver"
}
```

**Save this token!** Use it in header as: `Authorization: Bearer TOKEN`

### DRIVER: Get Profile (needs login token)
```bash
curl http://localhost:5000/api/auth/driver/profile \
  -H "Authorization: Bearer YOUR_DRIVER_TOKEN_HERE"
```

**Expected Response:**
```json
{
  "id": 1,
  "email": "driver@example.com",
  "phone": "03105551234",
  "firstName": "Ali",
  "lastName": "Khan",
  "licenseNumber": "DL-12345-ABC",
  "vehicleType": "Car",
  "vehiclePlate": "ABC-123",
  "status": "pending_verification",
  "rating": 0,
  "reviewsCount": 0,
  "totalRides": 0,
  "totalEarnings": 0,
  "createdAt": "2026-05-23T...",
  "userType": "driver"
}
```

### DRIVER: Update Profile
```bash
curl -X PUT http://localhost:5000/api/auth/driver/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_DRIVER_TOKEN_HERE" \
  -d '{
    "vehicleType": "Motorcycle",
    "vehiclePlate": "XYZ-789",
    "phone": "03105559999"
  }'
```

---

## 🏪 Testing - VENDOR TYPE

### VENDOR: Register (Sign Up)
```bash
curl -X POST http://localhost:5000/api/auth/vendor/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "vendor@example.com",
    "phone": "03215551234",
    "password": "Vendor@123",
    "businessName": "Tech Store Pakistan",
    "ownerFirstName": "Fatima",
    "ownerLastName": "Ali",
    "businessType": "Electronics",
    "shopAddress": "123 Main Street, Lahore",
    "city": "Lahore",
    "ntnNumber": "NTN-1234567890"
  }'
```

**Expected Response:**
```json
{
  "message": "Vendor registered successfully",
  "vendorId": 1,
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "userType": "vendor"
}
```

### VENDOR: Login
```bash
curl -X POST http://localhost:5000/api/auth/vendor/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "vendor@example.com",
    "password": "Vendor@123"
  }'
```

**Expected Response:**
```json
{
  "message": "Login successful",
  "vendorId": 1,
  "email": "vendor@example.com",
  "businessName": "Tech Store Pakistan",
  "ownerFirstName": "Fatima",
  "ownerLastName": "Ali",
  "businessType": "Electronics",
  "status": "pending_approval",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "userType": "vendor"
}
```

**Save this token!** Use it in header as: `Authorization: Bearer TOKEN`

### VENDOR: Get Profile (needs login token)
```bash
curl http://localhost:5000/api/auth/vendor/profile \
  -H "Authorization: Bearer YOUR_VENDOR_TOKEN_HERE"
```

**Expected Response:**
```json
{
  "id": 1,
  "email": "vendor@example.com",
  "phone": "03215551234",
  "businessName": "Tech Store Pakistan",
  "ownerFirstName": "Fatima",
  "ownerLastName": "Ali",
  "businessType": "Electronics",
  "shopAddress": "123 Main Street, Lahore",
  "city": "Lahore",
  "ntnNumber": "NTN-1234567890",
  "status": "pending_approval",
  "rating": 0,
  "reviewsCount": 0,
  "totalProducts": 0,
  "totalOrders": 0,
  "totalEarnings": 0,
  "createdAt": "2026-05-23T...",
  "userType": "vendor"
}
```

### VENDOR: Update Profile
```bash
curl -X PUT http://localhost:5000/api/auth/vendor/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_VENDOR_TOKEN_HERE" \
  -d '{
    "businessType": "Computers & Laptops",
    "shopAddress": "456 Tech Road, Lahore",
    "city": "Islamabad"
  }'
```

---

## 🔐 API Endpoints Summary

### USER Endpoints
- `POST /api/auth/user/register` - Register new user
- `POST /api/auth/user/login` - User login
- `GET /api/auth/user/profile` - Get user profile (auth required)
- `PUT /api/auth/user/profile` - Update user profile (auth required)

### DRIVER Endpoints
- `POST /api/auth/driver/register` - Register new driver
- `POST /api/auth/driver/login` - Driver login
- `GET /api/auth/driver/profile` - Get driver profile (auth required)
- `PUT /api/auth/driver/profile` - Update driver profile (auth required)

### VENDOR Endpoints
- `POST /api/auth/vendor/register` - Register new vendor
- `POST /api/auth/vendor/login` - Vendor login
- `GET /api/auth/vendor/profile` - Get vendor profile (auth required)
- `PUT /api/auth/vendor/profile` - Update vendor profile (auth required)

---

## 📊 Database Verification

### Check All Users Table
```bash
mysql -u root -pYusuf@15 nafaj
SELECT * FROM users;
SELECT * FROM drivers;
SELECT * FROM vendors;
```

### Check Specific User
```sql
SELECT * FROM users WHERE email = 'user@example.com';
SELECT * FROM drivers WHERE email = 'driver@example.com';
SELECT * FROM vendors WHERE email = 'vendor@example.com';
```

### Count Records
```sql
SELECT COUNT(*) as 'Total Users' FROM users;
SELECT COUNT(*) as 'Total Drivers' FROM drivers;
SELECT COUNT(*) as 'Total Vendors' FROM vendors;
```

---

## ✅ Testing Checklist

### USER Registration & Login
- [ ] Register user successfully
- [ ] Login with correct credentials
- [ ] Get user profile (with token)
- [ ] Update user profile
- [ ] Data appears in users table

### DRIVER Registration & Login
- [ ] Register driver successfully
- [ ] Login with correct credentials
- [ ] Get driver profile (with token)
- [ ] Update driver profile
- [ ] Data appears in drivers table

### VENDOR Registration & Login
- [ ] Register vendor successfully
- [ ] Login with correct credentials
- [ ] Get vendor profile (with token)
- [ ] Update vendor profile
- [ ] Data appears in vendors table

### Error Testing
- [ ] Try login with wrong password
- [ ] Try login with non-existent email
- [ ] Try register with duplicate email
- [ ] Try register with duplicate phone
- [ ] Try access profile without token

---

## 🔍 Common Issues & Solutions

### "Port 5000 already in use"
```bash
# Kill process using port 5000
lsof -ti:5000 | xargs kill -9
```

### "MySQL connection refused"
- Check MySQL is running
- Verify credentials: root / Yusuf@15

### "Invalid token" error
- Token from login for one user type (driver) won't work for another (user/vendor)
- Always use token from same user type login
- Tokens expire after 7 days

### "Email already registered"
- Use different email for each registration
- Or check if already registered in that specific table

---

## 📁 File Locations

**Migration Files:**
- `backend/migrations/migration_users_table.sql`
- `backend/migrations/migration_drivers_table.sql`
- `backend/migrations/migration_vendors_table.sql`

**Model Files:**
- `backend/src/models/User.js`
- `backend/src/models/Driver.js`
- `backend/src/models/Vendor.js`

**Controller Files:**
- `backend/src/controllers/AuthController.js` (Users)
- `backend/src/controllers/DriverAuthController.js` (Drivers)
- `backend/src/controllers/VendorAuthController.js` (Vendors)

**Route File:**
- `backend/src/routes/auth.js`

---

## 🚀 Next Steps After Testing

1. ✅ Verify all 3 user types can register
2. ✅ Verify all 3 user types can login
3. ✅ Verify profiles work correctly
4. ✅ Check database has all 3 tables with data
5. → Integrate with Flutter app
6. → Test complete flow from app

---

**All 3 user types (User, Driver, Vendor) are now fully functional with separate tables, registration, login, and profile management!** 🎉
