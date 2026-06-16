# ⚡ Quick Start - 3 User Types Test Data

## 🚀 Copy-Paste Ready Test Credentials

Ready to test? Use these credentials!

---

## 👤 USER Credentials

### Register a USER:
```bash
curl -X POST http://localhost:5000/api/auth/user/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@test.com",
    "phone": "03001234567",
    "password": "User@123",
    "firstName": "Ahmed",
    "lastName": "Hassan"
  }'
```

**Save Response Token!** You'll need it.

### Login as USER:
```bash
curl -X POST http://localhost:5000/api/auth/user/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@test.com",
    "password": "User@123"
  }'
```

### Get USER Profile:
```bash
curl http://localhost:5000/api/auth/user/profile \
  -H "Authorization: Bearer YOUR_USER_TOKEN"
```

---

## 🚗 DRIVER Credentials

### Register a DRIVER:
```bash
curl -X POST http://localhost:5000/api/auth/driver/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "driver@test.com",
    "phone": "03105551234",
    "password": "Driver@123",
    "firstName": "Ali",
    "lastName": "Khan",
    "licenseNumber": "DL-12345",
    "vehicleType": "Car",
    "vehiclePlate": "ABC-123"
  }'
```

**Save Response Token!** You'll need it.

### Login as DRIVER:
```bash
curl -X POST http://localhost:5000/api/auth/driver/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "driver@test.com",
    "password": "Driver@123"
  }'
```

### Get DRIVER Profile:
```bash
curl http://localhost:5000/api/auth/driver/profile \
  -H "Authorization: Bearer YOUR_DRIVER_TOKEN"
```

---

## 🏪 VENDOR Credentials

### Register a VENDOR:
```bash
curl -X POST http://localhost:5000/api/auth/vendor/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "vendor@test.com",
    "phone": "03215551234",
    "password": "Vendor@123",
    "businessName": "Tech Store",
    "ownerFirstName": "Fatima",
    "ownerLastName": "Ali",
    "businessType": "Electronics",
    "shopAddress": "123 Main St",
    "city": "Lahore",
    "ntnNumber": "NTN-123"
  }'
```

**Save Response Token!** You'll need it.

### Login as VENDOR:
```bash
curl -X POST http://localhost:5000/api/auth/vendor/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "vendor@test.com",
    "password": "Vendor@123"
  }'
```

### Get VENDOR Profile:
```bash
curl http://localhost:5000/api/auth/vendor/profile \
  -H "Authorization: Bearer YOUR_VENDOR_TOKEN"
```

---

## 📝 Database Check

After registration, verify data in database:

```bash
# Connect to MySQL
mysql -u root -pYusuf@15 nafaj

# Check Users table
SELECT * FROM users;

# Check Drivers table
SELECT * FROM drivers;

# Check Vendors table
SELECT * FROM vendors;

# Exit
EXIT;
```

---

## ✨ Step-by-Step Testing Process

### 1️⃣ Start Backend
```bash
cd backend
npm install      # (first time only)
npm run migrate  # (first time only)
npm run dev
```

### 2️⃣ Register Test Users (in new terminal)
```bash
# Copy-paste each command above to register:
# - 1 User
# - 1 Driver
# - 1 Vendor
```

### 3️⃣ Login and Get Tokens
```bash
# Copy-paste each login command to get tokens
# Save each token from response
```

### 4️⃣ Test Profiles
```bash
# Replace YOUR_USER_TOKEN, YOUR_DRIVER_TOKEN, YOUR_VENDOR_TOKEN
# with actual tokens from login responses
```

### 5️⃣ Check Database
```bash
# Verify all 3 tables have data
```

---

## 📊 What You Should See

### After User Registration:
```json
{
  "message": "User registered successfully",
  "userId": 1,
  "token": "eyJ...",
  "userType": "user"
}
```

### After User Login:
```json
{
  "message": "Login successful",
  "userId": 1,
  "email": "user@test.com",
  "firstName": "Ahmed",
  "lastName": "Hassan",
  "token": "eyJ...",
  "userType": "user"
}
```

### User Profile:
```json
{
  "id": 1,
  "email": "user@test.com",
  "phone": "03001234567",
  "firstName": "Ahmed",
  "lastName": "Hassan",
  "status": "active",
  "userType": "user"
}
```

---

## 🎯 Quick Reference

| Action | User | Driver | Vendor |
|--------|------|--------|--------|
| Register | `/auth/user/register` | `/auth/driver/register` | `/auth/vendor/register` |
| Login | `/auth/user/login` | `/auth/driver/login` | `/auth/vendor/login` |
| Profile | `/auth/user/profile` | `/auth/driver/profile` | `/auth/vendor/profile` |
| Update | `/auth/user/profile` (PUT) | `/auth/driver/profile` (PUT) | `/auth/vendor/profile` (PUT) |

---

## 🔐 Important Notes

✅ **Each user type has its own table:**
- Users in `users` table
- Drivers in `drivers` table  
- Vendors in `vendors` table

✅ **Tokens are type-specific:**
- User token only works for user endpoints
- Driver token only works for driver endpoints
- Vendor token only works for vendor endpoints

✅ **Passwords are hashed:**
- Never stored in plain text
- bcryptjs used for security

✅ **All emails/phones are unique:**
- Can't register same email twice in same table
- Different tables can have same email (user@test.com can be user AND driver AND vendor)

---

## 🚀 Now What?

After successful testing:

1. Integrate with Flutter app
2. Create UI for user selection (User/Driver/Vendor)
3. Store user type and token locally
4. Use correct endpoints based on user type

**Everything is ready to use!** 🎉
