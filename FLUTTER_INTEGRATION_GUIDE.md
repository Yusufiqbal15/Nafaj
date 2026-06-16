# Flutter App Backend Integration Guide

This guide explains how to integrate the new Node.js/MySQL backend with your Flutter Nafaj application.

## Overview of Changes

The backend has been completely migrated from Firebase to a Node.js Express server with MySQL database.

### Database Credentials
```
Host: localhost
User: root
Password: Yusuf@15
Database: nafaj
Port: 3306
```

## Step 1: Update Flutter Dependencies

Remove Firebase dependencies and add HTTP client (if not already present).

### pubspec.yaml Changes

Remove:
```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.4.4
```

Keep:
```yaml
http: ^1.1.0
provider: ^6.0.0
shared_preferences: ^2.2.0
```

## Step 2: Create API Service

Replace Firebase services with HTTP-based API service.

### Create lib/services/api_service.dart

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer \$token',
    };
  }

  // AUTH ENDPOINTS
  
  static Future<Map<String, dynamic>> register({
    required String email,
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'driver',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('\$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'phone': phone,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setInt('user_id', data['userId']);
        return data;
      } else {
        throw Exception(jsonDecode(response.body)['error']);
      }
    } catch (e) {
      throw Exception('Registration failed: \$e');
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('\$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setInt('user_id', data['userId']);
        return data;
      } else {
        throw Exception(jsonDecode(response.body)['error']);
      }
    } catch (e) {
      throw Exception('Login failed: \$e');
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('\$baseUrl/auth/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get profile');
      }
    } catch (e) {
      throw Exception('Get profile failed: \$e');
    }
  }

  static Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('\$baseUrl/auth/profile'),
        headers: headers,
        body: jsonEncode({
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (phone != null) 'phone': phone,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      throw Exception('Update profile failed: \$e');
    }
  }

  // JOB ENDPOINTS

  static Future<List<dynamic>> getJobs({
    String? status,
    int? categoryId,
  }) async {
    try {
      String url = '\$baseUrl/jobs';
      if (status != null || categoryId != null) {
        url += '?';
        if (status != null) url += 'status=\$status&';
        if (categoryId != null) url += 'categoryId=\$categoryId';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['jobs'] ?? [];
      } else {
        throw Exception('Failed to fetch jobs');
      }
    } catch (e) {
      throw Exception('Get jobs failed: \$e');
    }
  }

  static Future<Map<String, dynamic>> getJobDetails(int jobId) async {
    try {
      final response = await http.get(
        Uri.parse('\$baseUrl/jobs/\$jobId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Job not found');
      }
    } catch (e) {
      throw Exception('Get job details failed: \$e');
    }
  }

  static Future<List<dynamic>> searchJobs(String query) async {
    try {
      final response = await http.get(
        Uri.parse('\$baseUrl/jobs/search?q=\$query'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['jobs'] ?? [];
      } else {
        throw Exception('Search failed');
      }
    } catch (e) {
      throw Exception('Search jobs failed: \$e');
    }
  }

  static Future<Map<String, dynamic>> createJob({
    required String title,
    required String description,
    required double budget,
    int? categoryId,
    String? location,
    String? deadline,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('\$baseUrl/jobs'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'budget': budget,
          if (categoryId != null) 'categoryId': categoryId,
          if (location != null) 'location': location,
          if (deadline != null) 'deadline': deadline,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['error']);
      }
    } catch (e) {
      throw Exception('Create job failed: \$e');
    }
  }

  // CART ENDPOINTS

  static Future<List<dynamic>> getCart() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('\$baseUrl/cart'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['items'] ?? [];
      } else {
        throw Exception('Failed to fetch cart');
      }
    } catch (e) {
      throw Exception('Get cart failed: \$e');
    }
  }

  static Future<void> addToCart({
    required int jobId,
    int quantity = 1,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('\$baseUrl/cart/add'),
        headers: headers,
        body: jsonEncode({
          'jobId': jobId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add to cart');
      }
    } catch (e) {
      throw Exception('Add to cart failed: \$e');
    }
  }

  static Future<void> removeFromCart(int jobId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('\$baseUrl/cart/\$jobId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to remove from cart');
      }
    } catch (e) {
      throw Exception('Remove from cart failed: \$e');
    }
  }

  static Future<void> clearCart() async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('\$baseUrl/cart'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to clear cart');
      }
    } catch (e) {
      throw Exception('Clear cart failed: \$e');
    }
  }
}
```

## Step 3: Update Firebase to Backend in Services

Replace firebase_auth calls with API service.

### Update lib/services/auth_service.dart

```dart
import 'package:provider/provider.dart';
import 'api_service.dart';

class AuthService {
  Future<bool> register({
    required String email,
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      await ApiService.register(
        email: email,
        phone: phone,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      return true;
    } catch (e) {
      print('Registration error: \$e');
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      await ApiService.login(email: email, password: password);
      return true;
    } catch (e) {
      print('Login error: \$e');
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
  }
}
```

### Update lib/services/job_service.dart

```dart
import 'api_service.dart';

class JobService {
  Future<List<dynamic>> getJobs({String? status}) async {
    try {
      return await ApiService.getJobs(status: status);
    } catch (e) {
      print('Get jobs error: \$e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getJobDetails(int jobId) async {
    try {
      return await ApiService.getJobDetails(jobId);
    } catch (e) {
      print('Get job details error: \$e');
      return null;
    }
  }

  Future<bool> createJob({
    required String title,
    required String description,
    required double budget,
    String? location,
  }) async {
    try {
      await ApiService.createJob(
        title: title,
        description: description,
        budget: budget,
        location: location,
      );
      return true;
    } catch (e) {
      print('Create job error: \$e');
      return false;
    }
  }
}
```

### Update lib/services/cart_service.dart

```dart
import 'api_service.dart';

class CartService {
  Future<List<dynamic>> getCart() async {
    try {
      return await ApiService.getCart();
    } catch (e) {
      print('Get cart error: \$e');
      return [];
    }
  }

  Future<bool> addToCart(int jobId) async {
    try {
      await ApiService.addToCart(jobId: jobId);
      return true;
    } catch (e) {
      print('Add to cart error: \$e');
      return false;
    }
  }

  Future<bool> removeFromCart(int jobId) async {
    try {
      await ApiService.removeFromCart(jobId);
      return true;
    } catch (e) {
      print('Remove from cart error: \$e');
      return false;
    }
  }

  Future<bool> clearCart() async {
    try {
      await ApiService.clearCart();
      return true;
    } catch (e) {
      print('Clear cart error: \$e');
      return false;
    }
  }
}
```

## Step 4: Update Environment Configuration

Remove Firebase initialization from main.dart:

### lib/main.dart (changes)

```dart
// Remove these imports:
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// Remove Firebase initialization:
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }

// Replace with:
void main() {
  runApp(const MyApp());
}
```

## Step 5: Testing the Integration

1. Start MySQL server
2. Create database and run migrations
3. Start the Node.js backend:
   ```bash
   cd backend
   npm install
   npm run migrate
   npm run dev
   ```

4. Update the baseUrl in api_service.dart if needed:
   - For development: `http://10.0.2.2:5000/api` (Android emulator)
   - For physical device: `http://192.168.x.x:5000/api` (your computer's IP)

5. Run the Flutter app:
   ```bash
   flutter run
   ```

## Common Issues

### CORS Errors
Make sure the Flutter app's baseUrl matches the CORS_ORIGIN in backend .env

### Connection Refused
- Check if backend is running on port 5000
- Check firewall settings
- For emulator: use `10.0.2.2:5000` instead of `localhost:5000`

### Database Connection Error
- Verify MySQL is running
- Check credentials in .env
- Ensure database exists

## API Response Format

All responses follow this format:

**Success:**
```json
{
  "message": "Success message",
  "data": { ... }
}
```

**Error:**
```json
{
  "error": "Error message"
}
```

## Next Steps

1. Test all authentication flows
2. Implement error handling UI
3. Add loading states
4. Implement pagination for job lists
5. Add push notifications
6. Implement payment integration
