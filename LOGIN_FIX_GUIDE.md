# 🔐 Login Fix - Network Error Solved

## ❌ Problem
Login failing with network error:
```
Network error: The connection errored: The XMLHttpRequest onError callback was called.
This indicates an error which most likely cannot be solved by the library.
```

## ✅ Solution Applied

### Issue 1: CORS Configuration
**Problem**: Flutter app running on random port (e.g., `localhost:58207`) was not in allowed CORS origins.

**Fix**: Updated `.env` to allow all origins in development:
```env
CORS_ORIGIN=*
```

### Issue 2: Backend Not Running
**Problem**: Backend server was not active on port 5000.

**Fix**: Backend restarted successfully:
```
✓ MySQL Database Connected Successfully
✓ Port: 5000
✓ Environment: development
```

---

## 🧪 Test Login

### Existing Test Accounts

**Vendor Account 1**:
```
Email: testvendor1780213223194@example.com
Business: Test Business
```

**Vendor Account 2**:
```
Email: yusuf@gmail.com
Business: yusuf uiqb
```

**Vendor Account 3**:
```
Email: ow@gmail.com
Business: yusuf
```

> **Note**: You need to know the password for these accounts. If you don't remember, create a new account.

---

## 🆕 Create New Vendor Account

### Option 1: Via Flutter App

1. Open app in browser
2. Click "Sign Up" or "Register"
3. Fill vendor details:
   ```
   Email: your@email.com
   Phone: 03001234567
   Password: yourpassword123
   Business Name: Your Shop
   ```
4. Click Register
5. Login with same credentials

### Option 2: Via API Test Script

Create file: `backend/test-vendor-register.js`

```javascript
const axios = require('axios');

async function testRegister() {
  try {
    const response = await axios.post('http://127.0.0.1:5000/api/auth/vendor/register', {
      email: 'newvendor@test.com',
      phone: '03001234567',
      password: 'password123',
      businessName: 'Test Shop',
      ownerFirstName: 'Test',
      ownerLastName: 'User',
    });
    
    console.log('✅ Registration successful!');
    console.log('Vendor ID:', response.data.data.vendorId);
    console.log('Email:', response.data.data.email);
    console.log('Token:', response.data.data.token);
  } catch (error) {
    console.error('❌ Registration failed:', error.response?.data || error.message);
  }
}

testRegister();
```

Run:
```bash
cd backend
node test-vendor-register.js
```

---

## 🔍 Verify Backend is Running

### Check Server Status
```bash
# Windows - Check if port 5000 is listening
netstat -ano | findstr :5000
```

### Test Health Endpoint
Open browser or use curl:
```
http://127.0.0.1:5000/api/health
```

Should return:
```json
{
  "status": "OK",
  "timestamp": "2024-...",
  "environment": "development"
}
```

---

## 🚀 Start Backend (If Not Running)

### Method 1: Normal Start
```bash
cd backend
npm start
```

### Method 2: Development Mode (Auto-restart)
```bash
cd backend
npm run dev
```

### Method 3: Simple Start (No checks)
```bash
cd backend
npm run start:simple
```

---

## 🐛 Troubleshooting

### Error: "ECONNREFUSED"
**Cause**: Backend not running
**Fix**: Start backend server (see above)

### Error: "CORS policy"
**Cause**: CORS not allowing your origin
**Fix**: Ensure `.env` has `CORS_ORIGIN=*` and restart backend

### Error: "Invalid credentials"
**Cause**: Wrong email/password
**Fix**: 
- Try another test account
- Create new account
- Reset password (if feature available)

### Error: "Database connection failed"
**Cause**: MySQL not running or wrong credentials
**Fix**:
1. Start MySQL/XAMPP
2. Check `.env` database settings:
   ```env
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=Yusuf@15
   DB_NAME=nafaj
   DB_PORT=3306
   ```

### Error: "Token expired"
**Cause**: Old token stored in browser
**Fix**:
1. Open browser DevTools
2. Go to Application → Storage
3. Clear all site data
4. Refresh page

---

## 📋 Backend Logs to Watch

When you login, you should see:
```
2024-06-03T08:19:03.654Z - POST /api/auth/vendor/login
```

If no logs appear when you click login:
1. Backend is not running
2. Frontend API URL is wrong
3. CORS blocking request

---

## ✅ Verification Checklist

- [ ] Backend running on port 5000
- [ ] Health endpoint responding
- [ ] `.env` has `CORS_ORIGIN=*`
- [ ] MySQL/XAMPP running
- [ ] Database `nafaj` exists
- [ ] Vendors table has data
- [ ] Flutter app can reach backend
- [ ] No CORS errors in browser console

---

## 🎯 Quick Test Commands

### Test Database Connection
```bash
cd backend
npm run test:db
```

### Test Vendor Login via API
```bash
cd backend
node -e "const axios = require('axios'); axios.post('http://127.0.0.1:5000/api/auth/vendor/login', { email: 'ow@gmail.com', password: 'YOUR_PASSWORD' }).then(r => console.log('✅ Login OK:', r.data)).catch(e => console.error('❌ Login Failed:', e.response?.data))"
```

### Check Backend Logs
```bash
# Backend terminal should show:
✓ MySQL Database Connected Successfully
✓ Port: 5000 running
```

---

## 🔄 Full Restart Process

If still having issues, full restart:

1. **Stop everything**:
   - Close Flutter app
   - Stop backend (Ctrl+C)
   - Stop MySQL (if separate)

2. **Start MySQL**:
   - Open XAMPP
   - Start MySQL

3. **Start Backend**:
   ```bash
   cd backend
   npm start
   ```
   Wait for: `✓ MySQL Database Connected`

4. **Start Flutter**:
   ```bash
   cd stitch_nafaj_driver_dashboard/nafaj
   flutter run -d chrome
   ```

5. **Test Login**:
   - Use: `ow@gmail.com` (or create new account)
   - Should work now ✅

---

## 📞 Still Having Issues?

1. Check backend console for errors
2. Check browser console (F12) for errors
3. Take screenshot of error
4. Share backend logs
5. Verify database has test accounts:
   ```sql
   SELECT id, email, business_name FROM vendors;
   ```

---

**Status**: ✅ CORS fixed, Backend running, Ready to login!
