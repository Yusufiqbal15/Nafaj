# Flutter Signup Integration Guide

## ✅ Backend Status
All signup endpoints are now working correctly and tested!

## API Endpoints

### Base URL
```dart
// For development
const String baseUrl = 'http://localhost:5000/api';

// For Android Emulator
const String baseUrl = 'http://10.0.2.2:5000/api';

// For iOS Simulator
const String baseUrl = 'http://localhost:5000/api';

// For Real Device (replace with your computer's IP)
const String baseUrl = 'http://192.168.1.XXX:5000/api';
```

### Signup Endpoints

1. **User Signup**: `POST /auth/user/register`
2. **Vendor Signup**: `POST /auth/vendor/register`
3. **Driver Signup**: `POST /auth/driver/register`

## Response Format

All endpoints return this format:

### Success Response (201)
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "userId": 1,
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "userType": "user"
  }
}
```

### Error Response (400/500)
```json
{
  "success": false,
  "error": "Email already registered"
}
```

## Flutter Implementation

### 1. Create API Service

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android Emulator
  
  // User Signup
  static Future<Map<String, dynamic>> userSignup({
    required String email,
    required String phone,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/user/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'phone': phone,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        }),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e'
      };
    }
  }
  
  // Vendor Signup
  static Future<Map<String, dynamic>> vendorSignup({
    required String email,
    required String phone,
    required String password,
    required String businessName,
    String? ownerFirstName,
    String? ownerLastName,
    String? businessType,
    String? shopAddress,
    String? city,
    String? ntnNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/vendor/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'phone': phone,
          'password': password,
          'businessName': businessName,
          'ownerFirstName': ownerFirstName,
          'ownerLastName': ownerLastName,
          'businessType': businessType,
          'shopAddress': shopAddress,
          'city': city,
          'ntnNumber': ntnNumber,
        }),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e'
      };
    }
  }
  
  // Driver Signup
  static Future<Map<String, dynamic>> driverSignup({
    required String email,
    required String phone,
    required String password,
    String? firstName,
    String? lastName,
    String? licenseNumber,
    String? vehicleType,
    String? vehiclePlate,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/driver/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'phone': phone,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'licenseNumber': licenseNumber,
          'vehicleType': vehicleType,
          'vehiclePlate': vehiclePlate,
        }),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e'
      };
    }
  }
}
```

### 2. Update Signup Form Handler

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSignupScreen extends StatefulWidget {
  @override
  _UserSignupScreenState createState() => _UserSignupScreenState();
}

class _UserSignupScreenState extends State<UserSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  
  bool _isLoading = false;
  
  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final result = await ApiService.userSignup(
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );
      
      if (result['success'] == true) {
        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', result['data']['token']);
        await prefs.setString('userType', result['data']['userType']);
        await prefs.setInt('userId', result['data']['userId']);
        await prefs.setString('email', result['data']['email']);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to user dashboard
        Navigator.pushReplacementNamed(context, '/user-dashboard');
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Signup failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Signup')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!value.contains('@')) {
                  return 'Invalid email format';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                hintText: '03001234567',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone is required';
                }
                if (!RegExp(r'^03[0-9]{9}$').hasMatch(value)) {
                  return 'Invalid phone format (use 03XXXXXXXXX)';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSignup,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Phone Number Validation

Pakistani phone format: `03XXXXXXXXX` (11 digits)

```dart
String? validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'Phone number is required';
  }
  
  // Remove spaces and dashes
  value = value.replaceAll(RegExp(r'[\s-]'), '');
  
  // Check format: 03XXXXXXXXX
  if (!RegExp(r'^03[0-9]{9}$').hasMatch(value)) {
    return 'Invalid phone format. Use: 03XXXXXXXXX';
  }
  
  return null;
}
```

### 4. Navigation After Signup

```dart
void navigateToDashboard(String userType) {
  switch (userType) {
    case 'user':
      Navigator.pushReplacementNamed(context, '/user-dashboard');
      break;
    case 'vendor':
      Navigator.pushReplacementNamed(context, '/vendor-dashboard');
      break;
    case 'driver':
      Navigator.pushReplacementNamed(context, '/driver-dashboard');
      break;
  }
}
```

## Testing Checklist

- [ ] Backend server is running (`npm start` in backend folder)
- [ ] Update `baseUrl` in Flutter app based on your setup
- [ ] Test user signup form
- [ ] Test vendor signup form
- [ ] Test driver signup form
- [ ] Verify token is saved in SharedPreferences
- [ ] Verify navigation to correct dashboard
- [ ] Test error handling (duplicate email, invalid phone, etc.)
- [ ] Test network error handling (server offline)

## Common Issues

### Issue: "Network Error" or "Connection Refused"

**Solutions:**
1. Make sure backend server is running
2. Check the base URL:
   - Android Emulator: `http://10.0.2.2:5000/api`
   - iOS Simulator: `http://localhost:5000/api`
   - Real Device: `http://YOUR_COMPUTER_IP:5000/api`
3. Check firewall settings
4. For real device, ensure phone and computer are on same WiFi

### Issue: "Invalid phone number format"

**Solution:**
Use Pakistani format: `03XXXXXXXXX`
- ✓ Valid: `03001234567`, `03451234567`
- ✗ Invalid: `3001234567`, `+923001234567`

### Issue: "Email already registered"

**Solution:**
- Use a different email
- Or delete the test user from database

## Required Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

Then run:
```bash
flutter pub get
```

## Next Steps

1. Update your Flutter signup forms to use the new API service
2. Test each signup flow (user, vendor, driver)
3. Implement proper error handling and loading states
4. Add token management for authenticated requests
5. Create dashboard screens for each user type
