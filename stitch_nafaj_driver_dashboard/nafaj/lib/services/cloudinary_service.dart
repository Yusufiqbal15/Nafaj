import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CloudinaryService {
  // Cloudinary configuration
  static const String cloudName = 'YOUR_CLOUD_NAME'; // Replace with your cloud name
  static const String uploadPreset = 'YOUR_UPLOAD_PRESET'; // Replace with your upload preset
  static const String apiKey = 'YOUR_API_KEY'; // Optional: for signed uploads
  
  static final Dio _dio = Dio();
  
  /// Upload image to Cloudinary
  /// For web: uses Uint8List bytes
  /// For mobile: uses file path
  static Future<String?> uploadImage({
    Uint8List? imageBytes,
    String? imagePath,
    String? fileName,
  }) async {
    try {
      final uploadUrl = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
      
      FormData formData;
      
      if (kIsWeb && imageBytes != null) {
        // Web upload using bytes
        print('Uploading image from web (bytes)');
        formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(
            imageBytes,
            filename: fileName ?? 'image.jpg',
          ),
          'upload_preset': uploadPreset,
        });
      } else if (imagePath != null) {
        // Mobile upload using file path
        print('Uploading image from mobile (file path)');
        formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            imagePath,
            filename: fileName ?? imagePath.split('/').last,
          ),
          'upload_preset': uploadPreset,
        });
      } else {
        throw Exception('No image data provided');
      }
      
      print('Uploading to Cloudinary...');
      final response = await _dio.post(uploadUrl, data: formData);
      
      if (response.statusCode == 200) {
        final secureUrl = response.data['secure_url'] as String;
        print('Upload successful: $secureUrl');
        return secureUrl;
      }
      
      print('Upload failed with status: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }
  
  /// Upload multiple images to Cloudinary
  static Future<List<String>> uploadMultipleImages({
    List<Uint8List>? imageBytesLis,
    List<String>? imagePaths,
    List<String>? fileNames,
  }) async {
    final uploadedUrls = <String>[];
    
    if (kIsWeb && imageBytesLis != null) {
      // Web: upload bytes
      for (int i = 0; i < imageBytesLis.length; i++) {
        final url = await uploadImage(
          imageBytes: imageBytesLis[i],
          fileName: fileNames != null && i < fileNames.length 
              ? fileNames[i] 
              : 'image_$i.jpg',
        );
        if (url != null) {
          uploadedUrls.add(url);
        }
      }
    } else if (imagePaths != null) {
      // Mobile: upload file paths
      for (int i = 0; i < imagePaths.length; i++) {
        final url = await uploadImage(
          imagePath: imagePaths[i],
          fileName: fileNames != null && i < fileNames.length 
              ? fileNames[i] 
              : null,
        );
        if (url != null) {
          uploadedUrls.add(url);
        }
      }
    }
    
    return uploadedUrls;
  }
  
  /// Delete image from Cloudinary (requires public_id)
  static Future<bool> deleteImage(String publicId) async {
    try {
      // Note: This requires API secret which should be done from backend
      // Frontend deletion is not recommended for security
      print('Image deletion should be handled by backend');
      return false;
    } catch (e) {
      print('Delete error: $e');
      return false;
    }
  }
}
