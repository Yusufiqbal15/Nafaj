class ApiConfig {
  // Backend API Base URL
  // Railway Production URL
  static const String baseUrl = 'https://nafaj-production.up.railway.app/api';

  // Use this for Chrome Web / Development
  // static const String baseUrl = 'http://127.0.0.1:5000/api';

  // Use this for Android Emulator
  // static const String baseUrl = 'http://10.0.2.2:5000/api';

  // Use this for iOS Simulator
  // static const String baseUrl = 'http://localhost:5000/api';

  // Use this for Real Device (replace with your computer's IP)
  // static const String baseUrl = 'http://192.168.1.XXX:5000/api';

  // Base URL for images
  static const String imageBaseUrl = 'https://nafaj-production.up.railway.app';
  
  // Auth Endpoints
  static const String userRegister = '/auth/user/register';
  static const String userLogin = '/auth/user/login';
  static const String userProfile = '/auth/user/profile';
  
  static const String driverRegister = '/auth/driver/register';
  static const String driverLogin = '/auth/driver/login';
  static const String driverProfile = '/auth/driver/profile';
  static const String driverApprovalStatus = '/auth/driver/approval-status';

  static const String vendorRegister = '/auth/vendor/register';
  static const String vendorLogin = '/auth/vendor/login';
  static const String vendorProfile = '/auth/vendor/profile';
  static const String vendorApprovalStatus = '/auth/vendor/approval-status';
  
  // Product Endpoints
  static const String products = '/products';
  static const String vendorProducts = '/products/vendor/my-products';
  static const String uploadImages = '/products/upload-images';
  
  // Order Endpoints
  static const String orders = '/orders';
  static const String vendorOrders = '/orders/vendor';
  static const String userOrders = '/orders/user';
  
  // Jobs Endpoints
  static const String jobs = '/jobs';
  
  // Cart Endpoints
  static const String cart = '/cart';
  
  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userTypeKey = 'user_type';
  static const String userIdKey = 'user_id';
  static const String emailKey = 'user_email';
}
