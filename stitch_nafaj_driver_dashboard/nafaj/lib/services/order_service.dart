import 'package:dio/dio.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class OrderService {
  // Create order
  static Future<Map<String, dynamic>> createOrder({
    required int vendorId,
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    double? deliveryLatitude,
    double? deliveryLongitude,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      final response = await ApiService.dio.post(
        '/orders',
        data: {
          'vendorId': vendorId,
          'items': items,
          'deliveryAddress': deliveryAddress,
          'deliveryLatitude': deliveryLatitude,
          'deliveryLongitude': deliveryLongitude,
          'paymentMethod': paymentMethod ?? 'cash',
          'notes': notes,
        },
      );

      if (response.statusCode == 201) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to create order'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get user's orders
  static Future<Map<String, dynamic>> getUserOrders({String? status}) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('${ApiConfig.baseUrl}/orders/my-orders')
          .replace(queryParameters: queryParams);

      final response = await ApiService.dio.getUri(uri);

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to fetch orders'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get driver's orders
  static Future<Map<String, dynamic>> getDriverOrders({String? status}) async {
    try {
      print('📡 OrderService: Getting driver orders...');
      print('📡 Base URL: ${ApiConfig.baseUrl}');
      
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('${ApiConfig.baseUrl}/orders/driver/orders')
          .replace(queryParameters: queryParams);

      print('📡 Request URI: $uri');
      
      final response = await ApiService.dio.getUri(uri);

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response data type: ${response.data.runtimeType}');
      
      if (response.statusCode == 200) {
        print('✅ Orders fetched successfully');
        return {'success': true, 'data': response.data};
      }
      
      print('❌ Failed to fetch orders: Status ${response.statusCode}');
      return {'success': false, 'error': 'Failed to fetch orders'};
    } on DioException catch (e) {
      print('❌ DioException caught:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');
      
      String errorMessage = 'Connection error';
      
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout - Please check if backend is running';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server response timeout';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Cannot connect to server at ${ApiConfig.baseUrl}. Make sure backend is running on port 5000';
      } else if (e.response != null) {
        errorMessage = e.response!.data?['error'] ?? e.message ?? 'Network error';
      }
      
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      print('❌ Unexpected error: $e');
      return {'success': false, 'error': 'Unexpected error: $e'};
    }
  }

  // Get order by ID
  static Future<Map<String, dynamic>> getOrder(int id) async {
    try {
      final response = await ApiService.dio.get('/orders/$id');

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Order not found'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Update order status
  // Update order status (Driver - uses driver auth)
  static Future<Map<String, dynamic>> updateOrderStatus(
    int orderId,
    String status,
  ) async {
    try {
      print('📦 Updating order $orderId status to: $status');
      final response = await ApiService.dio.patch(
        '/orders/$orderId/status/driver',
        data: {'status': status},
      );

      if (response.statusCode == 200) {
        print('✅ Status updated successfully');
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to update status'};
    } on DioException catch (e) {
      print('❌ Status update failed: ${e.response?.data?['error']}');
      return {
        'success': false,
        'error': e.response?.data?['error'] ?? 'Network error'
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Vendor confirms a pending order (pending_vendor_confirmation → vendor_confirmed)
  static Future<Map<String, dynamic>> vendorConfirmOrder(int orderId) async {
    try {
      final response = await ApiService.dio.patch('/orders/vendor/orders/$orderId/confirm');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to confirm order'};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data?['error'] ?? 'Network error'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Vendor rejects a pending order (pending_vendor_confirmation → cancelled)
  static Future<Map<String, dynamic>> vendorRejectOrder(int orderId) async {
    try {
      final response = await ApiService.dio.patch('/orders/vendor/orders/$orderId/reject');
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to reject order'};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data?['error'] ?? 'Network error'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Vendor updates order status (confirm, prepare, ready, out_for_delivery)
  static Future<Map<String, dynamic>> vendorUpdateOrderStatus(
    int orderId,
    String status,
  ) async {
    try {
      print('📦 Vendor updating order $orderId to: $status');
      final response = await ApiService.dio.patch(
        '/orders/$orderId/status',
        data: {'status': status},
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to update status'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data?['error'] ?? 'Network error'
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get order for live tracking (user/vendor/driver)
  static Future<Map<String, dynamic>> getOrderTracking(int orderId) async {
    try {
      final response = await ApiService.dio.get('/orders/$orderId/tracking');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {'success': true, 'data': response.data['data']};
      }
      return {'success': false, 'error': 'Failed to fetch tracking'};
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data?['error'] ?? 'Network error'
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Assign driver to order
  static Future<Map<String, dynamic>> assignDriver(
    int orderId,
    int driverId,
  ) async {
    try {
      final response = await ApiService.dio.patch(
        '/orders/$orderId/assign-driver',
        data: {'driverId': driverId},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to assign driver'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Accept order (Driver)
  static Future<Map<String, dynamic>> acceptOrder(int orderId) async {
    try {
      final response = await ApiService.dio.patch(
        '/orders/$orderId/accept',
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to accept order'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Confirm delivery (User)
  static Future<Map<String, dynamic>> confirmDelivery(int orderId) async {
    try {
      print('📦 Confirming delivery for order $orderId');
      final response = await ApiService.dio.patch(
        '/orders/$orderId/confirm-delivery',
      );

      if (response.statusCode == 200) {
        print('✅ Delivery confirmed successfully');
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'error': 'Failed to confirm delivery'};
    } on DioException catch (e) {
      print('❌ Delivery confirmation failed: ${e.response?.data?['error']}');
      return {
        'success': false,
        'error': e.response?.data?['error'] ?? 'Network error'
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get ALL orders from database (for vendor dashboard)
  static Future<Map<String, dynamic>> getAllOrders({String? status}) async {
    try {
      print('📦 Getting ALL orders from database...');

      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('${ApiConfig.baseUrl}/orders/all')
          .replace(queryParameters: queryParams);

      print('📡 Request URI: $uri');

      final response = await ApiService.dio.getUri(uri);

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ All orders fetched: ${response.data['count']}');
        return {'success': true, 'data': response.data};
      }

      return {'success': false, 'error': 'Failed to fetch orders'};
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      String errorMessage = 'Connection error';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout';
      } else if (e.response != null) {
        errorMessage = e.response!.data?['error'] ?? e.message ?? 'Network error';
      }
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      print('❌ Unexpected error: $e');
      return {'success': false, 'error': 'Unexpected error: $e'};
    }
  }

  // Get vendor's orders
  static Future<Map<String, dynamic>> getVendorOrders({String? status}) async {
    try {
      print('📦 Getting vendor orders...');
      
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('${ApiConfig.baseUrl}/orders/vendor/orders')
          .replace(queryParameters: queryParams);

      print('📡 Request URI: $uri');
      
      final response = await ApiService.dio.getUri(uri);

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Vendor orders fetched successfully');
        return {'success': true, 'data': response.data};
      }
      
      print('❌ Failed to fetch vendor orders: Status ${response.statusCode}');
      return {'success': false, 'error': 'Failed to fetch vendor orders'};
    } on DioException catch (e) {
      print('❌ DioException caught:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');
      
      String errorMessage = 'Connection error';
      
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout';
      } else if (e.response != null) {
        errorMessage = e.response!.data?['error'] ?? e.message ?? 'Network error';
      }
      
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      print('❌ Unexpected error: $e');
      return {'success': false, 'error': 'Unexpected error: $e'};
    }
  }

  // Get driver wallet data (balance, transactions, weekly stats)
  static Future<Map<String, dynamic>> getDriverWallet() async {
    try {
      final response = await ApiService.dio.get('/orders/driver/wallet');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {'success': true, 'data': response.data['data']};
      }
      return {'success': false, 'error': 'Failed to fetch wallet'};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data?['error'] ?? 'Network error'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get vendor sales report for a given period: today, week, month, all_time
  static Future<Map<String, dynamic>> getVendorSalesReport(String period) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/orders/vendor/sales-report')
          .replace(queryParameters: {'period': period});
      final response = await ApiService.dio.getUri(uri);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {'success': true, 'data': response.data['data']};
      }
      return {'success': false, 'error': 'Failed to fetch sales report'};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data?['error'] ?? 'Network error'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get vendor dashboard stats
  static Future<Map<String, dynamic>> getVendorStats() async {
    try {
      final response = await ApiService.dio.get('/orders/vendor/stats');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return {'success': true, 'data': response.data['data']};
      }
      return {'success': false, 'error': 'Failed to fetch stats'};
    } on DioException catch (e) {
      return {'success': false, 'error': e.response?.data?['error'] ?? 'Network error'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get vendor's sold products
  static Future<Map<String, dynamic>> getVendorSoldProducts({String? status, int? limit}) async {
    try {
      print('🛍️ Getting vendor sold products...');
      
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (limit != null) queryParams['limit'] = limit.toString();

      final uri = Uri.parse('${ApiConfig.baseUrl}/orders/vendor/sold-products')
          .replace(queryParameters: queryParams);

      print('📡 Request URI: $uri');
      
      final response = await ApiService.dio.getUri(uri);

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ Vendor sold products fetched successfully');
        return {'success': true, 'data': response.data};
      }
      
      print('❌ Failed to fetch vendor sold products: Status ${response.statusCode}');
      return {'success': false, 'error': 'Failed to fetch sold products'};
    } on DioException catch (e) {
      print('❌ DioException caught:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');
      
      String errorMessage = 'Connection error';
      
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout';
      } else if (e.response != null) {
        errorMessage = e.response!.data?['error'] ?? e.message ?? 'Network error';
      }
      
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      print('❌ Unexpected error: $e');
      return {'success': false, 'error': 'Unexpected error: $e'};
    }
  }

  // Create a test order (for debugging)
  static Future<Map<String, dynamic>> createTestOrder() async {
    try {
      print('📦 Creating test order...');
      
      final response = await ApiService.dio.post('/orders/vendor/test-order');

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        print('✅ Test order created successfully');
        return {'success': true, 'data': response.data['data']};
      }
      
      print('❌ Failed to create test order');
      return {'success': false, 'error': response.data['error'] ?? 'Failed to create test order'};
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      return {
        'success': false,
        'error': e.response?.data?['error'] ?? 'Network error: ${e.message}'
      };
    } catch (e) {
      print('❌ Error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
