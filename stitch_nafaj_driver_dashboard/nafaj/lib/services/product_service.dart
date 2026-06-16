import 'dart:typed_data';
import 'api_service.dart';

class ProductService {
  // Get all products
  static Future<Map<String, dynamic>> getAllProducts({
    String? category,
    String? status,
    String? search,
    int? limit,
  }) async {
    try {
      return await ApiService.getAllProducts(
        category: category,
        status: status,
        search: search,
        limit: limit,
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get single product
  static Future<Map<String, dynamic>> getProduct(int id) async {
    try {
      // This endpoint is not in ApiService yet, returning placeholder
      return {'success': false, 'error': 'Method not implemented yet'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Create product (Vendor only)
  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required double price,
    String? description,
    String? category,
    double? discountPrice,
    int? stockQuantity,
    String? unit,
    List<String>? imagePaths, // For mobile
    List<Uint8List>? imageBytes, // For web
    List<String>? imageNames, // For web
  }) async {
    try {
      return await ApiService.createProduct(
        name: name,
        price: price,
        description: description,
        category: category,
        discountPrice: discountPrice,
        stockQuantity: stockQuantity,
        unit: unit,
        imagePaths: imagePaths,
        imageBytes: imageBytes,
        imageNames: imageNames,
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get vendor's products
  static Future<Map<String, dynamic>> getVendorProducts({
    String? category,
    String? status,
  }) async {
    try {
      return await ApiService.getVendorProducts(
        category: category,
        status: status,
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Update product
  static Future<Map<String, dynamic>> updateProduct(
    int id, {
    String? name,
    String? description,
    String? category,
    double? price,
    double? discountPrice,
    int? stockQuantity,
    String? unit,
    List<String>? images,
    String? status,
    bool? isFeatured,
  }) async {
    try {
      return await ApiService.updateProduct(
        productId: id,
        name: name,
        description: description,
        category: category,
        price: price,
        discountPrice: discountPrice,
        stockQuantity: stockQuantity,
        unit: unit,
        status: status,
        imagePaths: images,
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Delete product
  static Future<Map<String, dynamic>> deleteProduct(int id) async {
    try {
      return await ApiService.deleteProduct(id);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Update stock
  static Future<Map<String, dynamic>> updateStock(int id, int quantity) async {
    try {
      // This would require a new API endpoint or use update
      return await ApiService.updateProduct(
        productId: id,
        stockQuantity: quantity,
      );
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
