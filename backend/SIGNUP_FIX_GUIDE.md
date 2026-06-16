# Signup Network Error - Fix Guide

## Problem
User, Vendor, and Driver signup forms are showing network errors when submitting.

## Solutions Applied

### 1. Enhanced CORS Configuration
- Added support for all origins in development
- Added proper headers and methods
- Fixed credential handling

### 2. Improved Error Handling
- Better error messages for database issues
- Network timeout handling
- Detailed error logging
- Consistent response format with `success` flag

### 3. Database Connection Improvements
- Added retry logic for database connections
- Better error messages
- Connection timeout configuration
- Keep-alive settings

### 4. Response Format Standardization
All signup endpoints now return:
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "token": "jwt-token-here",
    "userType": "user"
  }
}
```

## How to Test

### Step 1: Test Database Connection
```bash
cd backend
npm run test:db
```

This will:
- Check MySQL connection
- Verify database exists
- Check if all required tables exist

### Step 2: Run Migrations (if needed)
```bash
npm run migrate
```

### Step 3: Start the Server
```bash
npm start
```

The new startup script will:
- Check database connection
- Create database if missing
- Run migrations if tables are missing
- Start the server

### Step 4: Test Signup Endpoints
```bash
npm run test:signup
```

This will test all three signup endpoints:
- User signup: POST /api/auth/user/register
- Vendor signup: POST /api/auth/vendor/register
- Driver signup: POST /api/auth/driver/register

## Manual Testing with cURL

### Test User Signup
```bash
curl -X POST http://localhost:5000/api/auth/user/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@example.com\",\"phone\":\"03001234567\",\"password\":\"Test@123\",\"firstName\":\"Test\",\"lastName\":\"User\"}"
```

### Test Vendor Signup
```bash
curl -X POST http://localhost:5000/api/auth/vendor/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"vendor@example.com\",\"phone\":\"03001234568\",\"password\":\"Test@123\",\"businessName\":\"Test Shop\",\"ownerFirstName\":\"Test\",\"ownerLastName\":\"Owner\"}"
```

### Test Driver Signup
```bash
curl -X POST http://localhost:5000/api/auth/driver/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"driver@example.com\",\"phone\":\"03001234569\",\"password\":\"Test@123\",\"firstName\":\"Test\",\"lastName\":\"Driver\",\"licenseNumber\":\"DL123456\"}"
```

## Common Issues and Solutions

### Issue 1: "Network Error" in Frontend
**Cause**: Backend server not running or wrong URL

**Solution**:
1. Check if backend is running: `npm start`
2. Verify the API URL in your Flutter app matches: `http://localhost:5000/api`
3. Check CORS settings in `.env` file

### Issue 2: "Database connection failed"
**Cause**: MySQL not running or wrong credentials

**Solution**:
1. Start MySQL server
2. Verify credentials in `.env` file:
   ```
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=your_password
   DB_NAME=nafaj
   DB_PORT=3306
   ```
3. Test connection: `npm run test:db`

### Issue 3: "Table not found"
**Cause**: Migrations not run

**Solution**:
```bash
npm run migrate
```

### Issue 4: "Email already registered"
**Cause**: Trying to register with existing email

**Solution**:
- Use a different email address
- Or delete the existing user from database

### Issue 5: "Invalid phone number format"
**Cause**: Phone number doesn't match Pakistani format

**Solution**:
Use format: `03XXXXXXXXX` (11 digits starting with 03)
Examples:
- ✓ 03001234567
- ✓ 03451234567
- ✗ 3001234567 (missing 0)
- ✗ +923001234567 (has +92)

## Frontend Integration

### Update API Base URL
Make sure your Flutter app uses the correct base URL:

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:5000/api';
  // For Android emulator use: 'http://10.0.2.2:5000/api'
  // For iOS simulator use: 'http://localhost:5000/api'
  // For real device use: 'http://YOUR_COMPUTER_IP:5000/api'
}
```

### Handle Response Format
Update your signup handlers to check the `success` field:

```dart
Future<void> signup(Map<String, dynamic> data) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/user/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    
    final result = jsonDecode(response.body);
    
    if (result['success'] == true) {
      // Save token
      final token = result['data']['token'];
      final userType = result['data']['userType'];
      
      // Navigate to dashboard
      navigateToDashboard(userType);
    } else {
      // Show error
      showError(result['error']);
    }
  } catch (e) {
    showError('Network error: $e');
  }
}
```

## Verification Checklist

- [ ] MySQL server is running
- [ ] Database 'nafaj' exists
- [ ] All tables (users, vendors, drivers) exist
- [ ] Backend server starts without errors
- [ ] Health check endpoint works: `http://localhost:5000/api/health`
- [ ] All three signup endpoints return success
- [ ] Data is saved in database
- [ ] JWT token is returned
- [ ] Frontend can connect to backend

## Files Modified

1. `src/server.js` - Enhanced CORS and middleware
2. `src/middleware/errorHandler.js` - Better error handling
3. `src/config/database.js` - Connection retry logic
4. `src/controllers/AuthController.js` - Standardized responses
5. `src/controllers/VendorAuthController.js` - Standardized responses
6. `src/controllers/DriverAuthController.js` - Standardized responses

## New Files Created

1. `test-db-connection.js` - Database connection tester
2. `test-signup.js` - Signup endpoint tester
3. `start-server.js` - Smart server startup script
4. `SIGNUP_FIX_GUIDE.md` - This guide

## Next Steps

1. Run the tests to verify everything works
2. Update your Flutter app to use the new response format
3. Test the complete flow from signup to dashboard
4. Monitor server logs for any errors

## Support

If you still face issues:
1. Check server logs for detailed error messages
2. Run `npm run test:db` to verify database
3. Run `npm run test:signup` to test endpoints
4. Check the console output for specific error messages
