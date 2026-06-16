import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import '../config/api_config.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Public getter for dio instance
  static Dio get dio => _dio;

  // Initialize interceptors
  static void initialize() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add token to headers if available
          final token = await _storage.read(key: ApiConfig.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired or invalid - clear storage
            await clearAuthData();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Save authentication data
  static Future<void> saveAuthData({
    required String token,
    required String userType,
    required int userId,
    required String email,
  }) async {
    await _storage.write(key: ApiConfig.tokenKey, value: token);
    await _storage.write(key: ApiConfig.userTypeKey, value: userType);
    await _storage.write(key: ApiConfig.userIdKey, value: userId.toString());
    await _storage.write(key: ApiConfig.emailKey, value: email);
  }

  // Get stored token
  static Future<String?> getToken() async {
    return await _storage.read(key: ApiConfig.tokenKey);
  }

  // Get user type
  static Future<String?> getUserType() async {
    return await _storage.read(key: ApiConfig.userTypeKey);
  }

  // Get user ID
  static Future<int?> getUserId() async {
    final id = await _storage.read(key: ApiConfig.userIdKey);
    return id != null ? int.tryParse(id) : null;
  }

  // Get stored email
  static Future<String?> getEmail() async {
    return await _storage.read(key: ApiConfig.emailKey);
  }

  // Clear authentication data
  static Future<void> clearAuthData() async {
    await _storage.delete(key: ApiConfig.tokenKey);
    await _storage.delete(key: ApiConfig.userTypeKey);
    await _storage.delete(key: ApiConfig.userIdKey);
    await _storage.delete(key: ApiConfig.emailKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ==================== USER AUTH ====================
  
  static Future<Map<String, dynamic>> userRegister({
    required String email,
    required String phone,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.userRegister,
        data: {
          'email': email,
          'phone': phone,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
      );
      
      if (response.statusCode == 201 && response.data['success'] == true) {
        final data = response.data['data'];
        await saveAuthData(
          token: data['token'],
          userType: data['userType'],
          userId: data['userId'],
          email: data['email'],
        );
        return {'success': true, 'data': data, 'message': response.data['message']};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Registration failed'};
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        return {
          'success': false,
          'error': e.response!.data['error'] ?? 'Registration failed'
        };
      }
      return {
        'success': false,
        'error': 'Network error: ${e.message}'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> userLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.userLogin,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        await saveAuthData(
          token: data['token'],
          userType: data['userType'],
          userId: data['userId'],
          email: data['email'],
        );
        return {'success': true, 'data': data, 'message': data['message']};
      }
      return {'success': false, 'error': 'Login failed'};
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        return {
          'success': false,
          'error': e.response!.data['error'] ?? 'Login failed'
        };
      }
      return {
        'success': false,
        'error': 'Network error: ${e.message}'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error: $e'
      };
    }
  }

  // ==================== DRIVER AUTH ====================
  
  static Future<Map<String, dynamic>> driverRegister({
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
      final response = await _dio.post(
        ApiConfig.driverRegister,
        data: {
          'email': email,
          'phone': phone,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'licenseNumber': licenseNumber,
          'vehicleType': vehicleType,
          'vehiclePlate': vehiclePlate,
        },
      );
      
      if (response.statusCode == 201 && response.data['success'] == true) {
        final data = response.data['data'];
        await saveAuthData(
          token: data['token'],
          userType: data['userType'],
          userId: data['driverId'],
          email: data['email'],
        );
        return {'success': true, 'data': data, 'message': response.data['message']};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Registration failed'};
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        return {
          'success': false,
          'error': e.response!.data['error'] ?? 'Registration failed'
        };
      }
      return {
        'success': false,
        'error': 'Network error: ${e.message}'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> driverLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.driverLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await saveAuthData(
          token: data['token'],
          userType: data['userType'],
          userId: data['driverId'],
          email: data['email'],
        );
        return {
          'success': true,
          'data': data,
          'message': data['message'],
          'approvalStatus': data['approvalStatus'] ?? 'approved',
        };
      }
      return {'success': false, 'error': 'Login failed'};
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        return {
          'success': false,
          'error': e.response!.data['error'] ?? 'Login failed'
        };
      }
      return {
        'success': false,
        'error': 'Network error: ${e.message}'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error: $e'
      };
    }
  }

  // ==================== VENDOR AUTH ====================
  
  static Future<Map<String, dynamic>> vendorRegister({
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
      final response = await _dio.post(
        ApiConfig.vendorRegister,
        data: {
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
        },
      );
      
      if (response.statusCode == 201 && response.data['success'] == true) {
        final data = response.data['data'];
        await saveAuthData(
          token: data['token'],
          userType: data['userType'],
          userId: data['vendorId'],
          email: data['email'],
        );
        return {'success': true, 'data': data, 'message': response.data['message']};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Registration failed'};
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        return {
          'success': false,
          'error': e.response!.data['error'] ?? 'Registration failed'
        };
      }
      return {
        'success': false,
        'error': 'Network error: ${e.message}'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error: $e'
      };
    }
  }

  static Future<Map<String, dynamic>> vendorLogin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.vendorLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await saveAuthData(
          token: data['token'],
          userType: data['userType'],
          userId: data['vendorId'],
          email: data['email'],
        );
        return {
          'success': true,
          'data': data,
          'message': data['message'],
          'approvalStatus': data['approvalStatus'] ?? 'approved',
        };
      }
      return {'success': false, 'error': 'Login failed'};
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        return {
          'success': false,
          'error': e.response!.data['error'] ?? 'Login failed'
        };
      }
      return {
        'success': false,
        'error': 'Network error: ${e.message}'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Unexpected error: $e'
      };
    }
  }

  // ==================== APPROVAL STATUS ====================

  static Future<Map<String, dynamic>> checkApprovalStatus() async {
    try {
      final userType = await getUserType();
      String endpoint;
      switch (userType) {
        case 'vendor':
          endpoint = ApiConfig.vendorApprovalStatus;
          break;
        case 'driver':
          endpoint = ApiConfig.driverApprovalStatus;
          break;
        default:
          return {'success': false, 'error': 'Unknown user type'};
      }

      final response = await _dio.get(endpoint);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'approvalStatus': response.data['approvalStatus'],
        };
      }
      return {'success': false, 'error': 'Failed to check status'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Network error'
      };
    } catch (e) {
      return {'success': false, 'error': 'Unexpected error: $e'};
    }
  }

  // ==================== PROFILE ====================
  
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final userType = await getUserType();
      String endpoint;
      
      switch (userType) {
        case 'driver':
          endpoint = ApiConfig.driverProfile;
          break;
        case 'vendor':
          endpoint = ApiConfig.vendorProfile;
          break;
        default:
          endpoint = ApiConfig.userProfile;
      }
      
      final response = await _dio.get(endpoint);
      
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to fetch profile'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Network error occurred'
      };
    }
  }

  // ==================== LOGOUT ====================
  
  static Future<void> logout() async {
    await clearAuthData();
  }

  // ==================== PRODUCTS ====================
  
  // Get all products (public endpoint)
  static Future<Map<String, dynamic>> getAllProducts({
    String? category,
    String? status,
    String? search,
    int? limit,
  }) async {
    try {
      print('=== Getting All Products ===');
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (status != null) queryParams['status'] = status;
      if (search != null) queryParams['search'] = search;
      if (limit != null) queryParams['limit'] = limit.toString();
      
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.products}')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      print('Request URI: $uri');
      
      final response = await _dio.getUri(uri);
      
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        print('Products count: ${response.data['count']}');
        return {'success': true, 'data': response.data['data']};
      }
      return {'success': false, 'error': 'Failed to fetch products'};
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      print('Response: ${e.response?.data}');
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Network error'
      };
    } catch (e) {
      print('Error: $e');
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }
  
  static Future<Map<String, dynamic>> getVendorProducts({
    String? category,
    String? status,
  }) async {
    try {
      print('=== Getting Vendor Products ===');
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (status != null) queryParams['status'] = status;
      
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.vendorProducts}')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      print('Request URI: $uri');
      
      final response = await _dio.getUri(uri);
      
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        print('Products count: ${response.data['count']}');
        print('Products data type: ${response.data['data'].runtimeType}');
        // Return the complete response data (it already has success, count, data)
        return {'success': true, 'data': response.data['data']};
      }
      return {'success': false, 'error': 'Failed to fetch products'};
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      print('Response: ${e.response?.data}');
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Network error'
      };
    } catch (e) {
      print('Error: $e');
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }
  
  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required double price,
    String? description,
    String? category,
    double? discountPrice,
    int? stockQuantity,
    String? unit,
    List<String>? imagePaths, // File paths from image picker (mobile)
    List<Uint8List>? imageBytes, // Image bytes (web)
    List<String>? imageNames, // Image filenames (web)
  }) async {
    try {
      print('=== Creating Product ===');
      print('Name: $name');
      print('Price: $price');
      print('Image paths: $imagePaths');
      print('Image bytes count: ${imageBytes?.length}');
      print('Is Web: $kIsWeb');
      
      // Get token for authentication
      final token = await getToken();
      print('Token available: ${token != null}');
      
      // Create FormData for multipart upload
      final formData = FormData.fromMap({
        'name': name,
        'price': price.toString(),
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        if (discountPrice != null) 'discountPrice': discountPrice.toString(),
        if (stockQuantity != null) 'stockQuantity': stockQuantity.toString(),
        if (unit != null) 'unit': unit,
      });
      
      // Add images to form data
      if (kIsWeb && imageBytes != null && imageBytes.isNotEmpty) {
        // For web, use provided bytes
        for (int i = 0; i < imageBytes.length; i++) {
          final bytes = imageBytes[i];
          final filename = imageNames != null && i < imageNames.length 
              ? imageNames[i] 
              : 'image_$i.jpg';
          
          formData.files.add(MapEntry(
            'images',
            MultipartFile.fromBytes(
              bytes,
              filename: filename,
            ),
          ));
          print('Added web image: $filename (${bytes.length} bytes)');
        }
      } else if (!kIsWeb && imagePaths != null && imagePaths.isNotEmpty) {
        // For mobile, use file paths
        for (int i = 0; i < imagePaths.length; i++) {
          final path = imagePaths[i];
          try {
            formData.files.add(MapEntry(
              'images',
              await MultipartFile.fromFile(
                path,
                filename: path.split('/').last,
              ),
            ));
            print('Added mobile image: ${path.split('/').last}');
          } catch (e) {
            print('Error adding mobile image: $e');
          }
        }
      }
      
      print('Sending request to: ${ApiConfig.products}');
      print('FormData files count: ${formData.files.length}');
      
      final response = await _dio.post(
        ApiConfig.products,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      if (response.statusCode == 201 && response.data['success'] == true) {
        return {'success': true, 'data': response.data};
      }
      return {
        'success': false,
        'error': response.data['error'] ?? 'Failed to create product'
      };
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      print('Response: ${e.response?.data}');
      return {
        'success': false,
        'error': e.response?.data['error'] ?? e.message ?? 'Network error'
      };
    } catch (e) {
      print('Error: $e');
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }
  
  static Future<Map<String, dynamic>> updateProduct({
    required int productId,
    String? name,
    double? price,
    String? description,
    String? category,
    double? discountPrice,
    int? stockQuantity,
    String? unit,
    String? status,
    List<String>? imagePaths, // Changed to accept URLs
  }) async {
    try {
      final data = <String, dynamic>{
        if (name != null) 'name': name,
        if (price != null) 'price': price,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        if (discountPrice != null) 'discountPrice': discountPrice,
        if (stockQuantity != null) 'stockQuantity': stockQuantity,
        if (unit != null) 'unit': unit,
        if (status != null) 'status': status,
        if (imagePaths != null && imagePaths.isNotEmpty) 'images': imagePaths,
      };
      
      final response = await _dio.put(
        '${ApiConfig.products}/$productId',
        data: data,
      );
      
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Product updated successfully'};
      }
      return {'success': false, 'error': 'Failed to update product'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Network error'
      };
    }
  }
  
  static Future<Map<String, dynamic>> deleteProduct(int productId) async {
    try {
      final response = await _dio.delete('${ApiConfig.products}/$productId');
      
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Product deleted successfully'};
      }
      return {'success': false, 'error': 'Failed to delete product'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Network error'
      };
    }
  }
  
  // ==================== ORDERS ====================
  
  static Future<Map<String, dynamic>> getVendorOrders({String? status}) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.vendorOrders}')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      final response = await _dio.getUri(uri);
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {'success': true, 'data': response.data['data']};
      }
      return {'success': false, 'error': 'Failed to fetch orders'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Network error'
      };
    }
  }
  
  static Future<Map<String, dynamic>> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    try {
      final response = await _dio.patch(
        '${ApiConfig.orders}/$orderId/status',
        data: {'status': status},
      );
      
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Order status updated'};
      }
      return {'success': false, 'error': 'Failed to update order'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Network error'
      };
    }
  }
  
  // ==================== PROFILE UPDATE ====================
  
  static Future<Map<String, dynamic>> updateVendorProfile({
    String? ownerFirstName,
    String? ownerLastName,
    String? phone,
    String? businessType,
    String? shopAddress,
    String? city,
  }) async {
    try {
      final response = await _dio.put(
        ApiConfig.vendorProfile,
        data: {
          if (ownerFirstName != null) 'ownerFirstName': ownerFirstName,
          if (ownerLastName != null) 'ownerLastName': ownerLastName,
          if (phone != null) 'phone': phone,
          if (businessType != null) 'businessType': businessType,
          if (shopAddress != null) 'shopAddress': shopAddress,
          if (city != null) 'city': city,
        },
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {'success': true, 'message': response.data['message']};
      }
      return {'success': false, 'error': 'Failed to update profile'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Network error'
      };
    }
  }

  // ==================== VENDORS ====================
  
  static Future<Map<String, dynamic>> getAllVendors({
    String? status,
    String? businessType,
    String? city,
    int? limit,
  }) async {
    try {
      print('=== Getting All Vendors ===');
      
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (businessType != null) queryParams['businessType'] = businessType;
      if (city != null) queryParams['city'] = city;
      if (limit != null) queryParams['limit'] = limit.toString();
      
      // Fix: Remove /api prefix since it's already in ApiConfig.baseUrl
      final uri = Uri.parse('${ApiConfig.baseUrl}/auth/vendors')
          .replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      
      print('Request URI: $uri');
      
      final response = await _dio.getUri(uri);
      
      print('Vendors Response: ${response.data}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {'success': true, 'data': response.data['data']};
      }
      return {'success': false, 'error': 'Failed to fetch vendors'};
    } on DioException catch (e) {
      print('Vendors API Error: ${e.message}');
      print('Response: ${e.response?.data}');
      return {
        'success': false,
        'error': e.response?.data['error'] ?? 'Network error'
      };
    }
  }
}
