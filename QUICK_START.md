# Quick Start Guide - Signup Fix

## ✅ Status: All Fixed and Working!

## Start Backend Server

```bash
cd backend
npm start
```

Server will automatically:
- Check database connection
- Create database if needed
- Run migrations if needed
- Start on port 5000

## Test Everything

### Test Database Connection
```bash
cd backend
npm run test:db
```

### Test All Signup Endpoints
```bash
cd backend
npm run test:signup
```

## API Endpoints (All Working ✅)

### Base URL
```
http://localhost:5000/api
```

### Endpoints
1. **User Signup**: `POST /api/auth/user/register`
2. **Vendor Signup**: `POST /api/auth/vendor/register`
3. **Driver Signup**: `POST /api/auth/driver/register`

## Flutter Integration

### Update Base URL in Your Flutter App

```dart
// For Android Emulator
const String baseUrl = 'http://10.0.2.2:5000/api';

// For iOS Simulator
const String baseUrl = 'http://localhost:5000/api';

// For Real Device (replace with your computer's IP)
const String baseUrl = 'http://192.168.1.XXX:5000/api';
```

### Example Signup Request

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> userSignup() async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:5000/api/auth/user/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': 'user@example.com',
      'phone': '03001234567',
      'password': 'Test@123',
      'firstName': 'John',
      'lastName': 'Doe',
    }),
  );
  
  final result = jsonDecode(response.body);
  
  if (result['success'] == true) {
    // Save token
    String token = result['data']['token'];
    String userType = result['data']['userType'];
    
    // Navigate to dashboard
    print('Signup successful! Token: $token');
  } else {
    // Show error
    print('Error: ${result['error']}');
  }
}
```

## Response Format

### Success (201)
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "userType": "user"
  }
}
```

### Error (400/500)
```json
{
  "success": false,
  "error": "Email already registered"
}
```

## Phone Number Format

Use Pakistani format: `03XXXXXXXXX`

✅ Valid:
- `03001234567`
- `03451234567`

❌ Invalid:
- `3001234567` (missing 0)
- `+923001234567` (has +92)

## Test with cURL

### User Signup
```bash
curl -X POST http://localhost:5000/api/auth/user/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@example.com\",\"phone\":\"03001234567\",\"password\":\"Test@123\",\"firstName\":\"Test\",\"lastName\":\"User\"}"
```

### Vendor Signup
```bash
curl -X POST http://localhost:5000/api/auth/vendor/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"vendor@example.com\",\"phone\":\"03001234568\",\"password\":\"Test@123\",\"businessName\":\"Test Shop\"}"
```

### Driver Signup
```bash
curl -X POST http://localhost:5000/api/auth/driver/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"driver@example.com\",\"phone\":\"03001234569\",\"password\":\"Test@123\",\"firstName\":\"Test\",\"lastName\":\"Driver\"}"
```

## Troubleshooting

### Backend not starting?
```bash
# Check if port 5000 is in use
netstat -ano | findstr :5000

# Kill the process (replace PID)
taskkill /F /PID <PID>

# Start again
npm start
```

### Database connection failed?
1. Make sure MySQL is running
2. Check credentials in `backend/.env`
3. Test connection: `npm run test:db`

### Tables missing?
```bash
cd backend
npm run migrate
```

## Documentation

- **Complete Fix Guide**: `backend/SIGNUP_FIX_GUIDE.md`
- **Flutter Integration**: `FLUTTER_SIGNUP_INTEGRATION.md`
- **Summary**: `SIGNUP_FIX_SUMMARY.md`

## Current Status

✅ Backend server: **RUNNING** on port 5000
✅ Database: **CONNECTED**
✅ All endpoints: **TESTED & WORKING**

Ready to test your Flutter signup forms!
