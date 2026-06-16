import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File, Platform;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../constants.dart';
import '../services/product_service.dart';
import '../services/api_service.dart';
import '../services/order_service.dart';
import '../models/product_model.dart';
import 'vendor_edit_profile.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen>
    with TickerProviderStateMixin {
  int _currentNavIndex = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  // Real data lists - fetched from API
  List<Product> _products = [];
  List<Map<String, dynamic>> _recentOrders = [];
  List<Map<String, dynamic>> _soldProducts = [];
  Map<String, dynamic>? _vendorProfile;
  Map<String, dynamic>? _vendorStats;

  // Vendor identity (email → ID) derived from backend
  String? _vendorEmail;
  int? _vendorId;

  bool _isLoadingProducts = false;
  bool _isLoadingOrders = false;
  bool _isLoadingProfile = false;
  bool _isLoadingStats = false;
  bool _isLoadingSoldProducts = false;
  int _pendingOrdersCount = 0;
  String _selectedOrderFilter = 'All';
  Timer? _ordersPollingTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0.0, end: 6.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    
    // Load products and orders
    _loadProducts();
    _loadProfile();
    _loadVendorOrders();
    _loadVendorStats();
    _loadSoldProducts();
    _ordersPollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) {
        _loadVendorOrders(silent: true);
        _loadVendorStats(silent: true);
        _loadSoldProducts(silent: true);
      }
    });
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoadingProfile = true);
    
    final result = await ApiService.getProfile();
    
    if (result['success'] == true && mounted) {
      setState(() {
        _vendorProfile = result['data'];
        _isLoadingProfile = false;
      });
    } else {
      if (mounted) {
        setState(() => _isLoadingProfile = false);
      }
    }
  }

  Future<void> _loadVendorStats({bool silent = false}) async {
    if (!silent) setState(() => _isLoadingStats = true);
    final result = await OrderService.getVendorStats();
    if (result['success'] == true && mounted) {
      final data = Map<String, dynamic>.from(result['data'] ?? {});
      // Capture vendor email → ID from stats response
      if (data['vendorEmail'] != null && _vendorEmail == null) {
        _vendorEmail = data['vendorEmail'] as String?;
        _vendorId = data['vendorId'] as int?;
      }
      setState(() {
        _vendorStats = data;
        _isLoadingStats = false;
      });
    } else {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _loadProducts() async {
    print('=== Loading Vendor Products ===');
    setState(() => _isLoadingProducts = true);
    
    // Get ONLY logged-in vendor's products (not all products)
    final result = await ProductService.getVendorProducts();
    
    print('Result: $result');
    
    if (result['success'] == true && mounted) {
      final data = result['data'];
      print('Data received: $data');
      print('Data type: ${data.runtimeType}');
      
      if (data != null) {
        try {
          final productList = (data as List)
              .map((json) {
                print('Parsing product: $json');
                return Product.fromJson(json);
              })
              .toList();
          
          print('Products parsed: ${productList.length}');
          
          setState(() {
            _products = productList;
            _isLoadingProducts = false;
          });
        } catch (e) {
          print('Error parsing products: $e');
          setState(() => _isLoadingProducts = false);
        }
      } else {
        print('Data is null');
        setState(() => _isLoadingProducts = false);
      }
    } else {
      print('Request failed: ${result['error']}');
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  Future<void> _loadVendorOrders({String? status, bool silent = false}) async {
    if (!silent) setState(() => _isLoadingOrders = true);

    print('=== Loading Vendor Orders (status: $status) ===');
    final result = await OrderService.getVendorOrders(status: status);
    
    print('📦 Result: $result');

    if (result['success'] == true && mounted) {
      final data = result['data'];
      print('📦 Data: $data');
      print('📦 Data type: ${data.runtimeType}');

      List<Map<String, dynamic>> orders = [];

      // Handle different response formats
      if (data is List) {
        orders = data.map((o) => Map<String, dynamic>.from(o)).toList();
      } else if (data is Map) {
        // Capture vendor identity (email → ID) returned by backend
        if (data['vendorEmail'] != null) {
          _vendorEmail = data['vendorEmail'] as String?;
          _vendorId = data['vendorId'] as int?;
          print('✅ Vendor identified: email=${_vendorEmail}, id=${_vendorId}');
        }
        if (data['orders'] is List) {
          orders = (data['orders'] as List).map((o) => Map<String, dynamic>.from(o)).toList();
        }
      }

      print('📦 Parsed orders count: ${orders.length}');

      setState(() {
        _recentOrders = orders;
        _pendingOrdersCount = orders.where((o) {
          final s = o['order_status'] ?? o['status'] ?? '';
          return s == 'pending' || s == 'pending_vendor_confirmation';
        }).length;
        _isLoadingOrders = false;
      });
    } else {
      print('❌ Failed to load orders: ${result['error']}');
      if (!silent && mounted) {
        setState(() {
          _recentOrders = [];
          _pendingOrdersCount = 0;
          _isLoadingOrders = false;
        });
      }
    }
  }

  Future<void> _createTestOrder() async {
    print('📦 Creating test order...');
    
    final result = await OrderService.createTestOrder();
    
    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Test order created! Order #${result['data']['orderNumber']}',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        // Reload orders
        await _loadVendorOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['error'] ?? 'Failed to create test order',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    _ordersPollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSoldProducts({bool silent = false}) async {
    if (!silent) setState(() => _isLoadingSoldProducts = true);
    
    print('🛍️ Loading sold products...');
    final result = await OrderService.getVendorSoldProducts(limit: 20);
    
    print('📦 Sold Products Result: $result');
    
    if (result['success'] == true && mounted) {
      final data = result['data'];
      print('📦 Sold Products Data: $data');
      
      List<Map<String, dynamic>> products = [];
      
      // Handle different response formats
      if (data is Map && data['products'] is List) {
        products = (data['products'] as List).map((p) => Map<String, dynamic>.from(p)).toList();
      } else if (data is List) {
        products = data.map((p) => Map<String, dynamic>.from(p)).toList();
      }
      
      print('📦 Parsed sold products count: ${products.length}');
      
      setState(() {
        _soldProducts = products;
        _isLoadingSoldProducts = false;
      });
    } else {
      print('❌ Failed to load sold products: ${result['error']}');
      if (!silent && mounted) {
        setState(() {
          _soldProducts = [];
          _isLoadingSoldProducts = false;
        });
      }
    }
  }

  Future<void> _vendorUpdateOrderStatus(int orderId, String status) async {
    const labels = {
      'confirmed': 'Confirm Order',
      'preparing': 'Start Preparing',
      'ready': 'Mark Ready',
      'out_for_delivery': 'Out for Delivery',
      'cancelled': 'Cancel Order',
    };
    final label = labels[status] ?? status;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text('Mark this order as "$label"?',
            style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC5500),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Confirm',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await OrderService.vendorUpdateOrderStatus(orderId, status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true
                ? 'Order updated: $label'
                : result['error'] ?? 'Failed to update',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: result['success'] == true
              ? const Color(0xFF10B981)
              : const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      if (result['success'] == true) _loadVendorOrders(
        status: _selectedOrderFilter == 'All' ? null : _selectedOrderFilter,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFCC5500);
    const Color bgColor = Color(0xFFFFFBF7);
    const Color darkSlate = Color(0xFF0F172A);
    const Color textGrey = Color(0xFF475569);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: IndexedStack(
          index: _currentNavIndex,
          children: [
            _buildDashboardHome(primaryColor, darkSlate, textGrey, bgColor),
            _buildOrdersTab(primaryColor, darkSlate, textGrey),
            _buildProductsTab(primaryColor, darkSlate, textGrey),
            _buildProfileTab(primaryColor, darkSlate, textGrey),
          ],
        ),
      ),
      // ── FAB ──
      floatingActionButton: _currentNavIndex == 2
          ? FloatingActionButton.extended(
              onPressed: () => _showAddProductSheet(
                context,
                primaryColor,
                darkSlate,
                textGrey,
              ),
              backgroundColor: primaryColor,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                'Add Product',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      // ── Bottom Nav ──
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: primaryColor.withValues(alpha: 0.08)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  0,
                  Icons.dashboard_rounded,
                  'Dashboard',
                  primaryColor,
                  darkSlate,
                ),
                _buildNavItem(
                  1,
                  Icons.receipt_long_rounded,
                  'Orders',
                  primaryColor,
                  darkSlate,
                ),
                _buildNavItem(
                  2,
                  Icons.inventory_2_rounded,
                  'Products',
                  primaryColor,
                  darkSlate,
                ),
                _buildNavItem(
                  3,
                  Icons.person_rounded,
                  'Profile',
                  primaryColor,
                  darkSlate,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // TAB 1: Dashboard Home
  // ═══════════════════════════════════════
  Widget _buildDashboardHome(
    Color primaryColor,
    Color darkSlate,
    Color textGrey,
    Color bgColor,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(AppConstants.paddingLarge, 16, AppConstants.paddingLarge, 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFCC5500), Color(0xFFE67322)],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: Colors.white,
                        padding: const EdgeInsets.all(4),
                        child: Image.asset('logo.png', fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _vendorProfile?['businessName'] ?? 'Business Name',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _vendorProfile?['status'] == 'active' ? 'Store is Open' : 'Store Status',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _currentNavIndex = 1);
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          if (_pendingOrdersCount > 0)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Center(
                                  child: Text(
                                    _pendingOrdersCount > 9 ? '9+' : '$_pendingOrdersCount',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stats Row
                Row(
                  children: [
                    _buildHeaderStat(
                      'Today\'s Sales',
                      _formatSDG(_vendorStats?['todaySales'] ?? 0),
                      Icons.trending_up_rounded,
                    ),
                    const SizedBox(width: 12),
                    _buildHeaderStat(
                      'Orders',
                      '${_vendorStats?['todayOrders'] ?? 0}',
                      Icons.shopping_bag_rounded,
                    ),
                    const SizedBox(width: 12),
                    _buildHeaderStat(
                      'Rating',
                      '${(double.tryParse(_vendorStats?['rating']?.toString() ?? '0') ?? 0.0).toStringAsFixed(1)} ★',
                      Icons.star_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Quick Actions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkSlate,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildQuickAction(
                      'Add Product',
                      Icons.add_box_rounded,
                      primaryColor,
                      darkSlate,
                      () {
                        _showAddProductSheet(
                          context,
                          primaryColor,
                          darkSlate,
                          textGrey,
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildQuickAction(
                      'View Orders',
                      Icons.receipt_long_rounded,
                      const Color(0xFF3B82F6),
                      darkSlate,
                      () {
                        setState(() => _currentNavIndex = 1);
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildQuickAction(
                      'Sales Report',
                      Icons.analytics_rounded,
                      const Color(0xFF10B981),
                      darkSlate,
                      () {
                        Navigator.pushNamed(context, '/vendor_sales_report');
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildQuickAction(
                      'Settings',
                      Icons.settings_rounded,
                      const Color(0xFF8B5CF6),
                      darkSlate,
                      () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Sales Overview Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor.withValues(alpha: 0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sales Overview',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkSlate,
                        ),
                      ),
                      Builder(builder: (_) {
                        final growth = (_vendorStats?['weekGrowth'] as num?)?.toInt() ?? 0;
                        final isPositive = growth >= 0;
                        final growthColor = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: growthColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${isPositive ? '+' : ''}$growth% ${isPositive ? '↑' : '↓'}',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: growthColor),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildSalesMetric('This Week', _formatSDG(_vendorStats?['weekSales'] ?? 0), primaryColor),
                      Container(width: 1, height: 40, color: const Color(0xFFF1F5F9)),
                      _buildSalesMetric('This Month', _formatSDG(_vendorStats?['monthSales'] ?? 0), const Color(0xFF3B82F6)),
                      Container(width: 1, height: 40, color: const Color(0xFFF1F5F9)),
                      _buildSalesMetric('Total', _formatSDG(_vendorStats?['totalSales'] ?? 0), const Color(0xFF10B981)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Mini Bar Chart
                  Builder(builder: (_) {
                    final bars = _getDailyBars();
                    final maxAmt = bars.map((b) => b['amount'] as double).fold(0.0, (a, b) => a > b ? a : b);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: bars.map((b) {
                        final h = maxAmt > 0 ? ((b['amount'] as double) / maxAmt).clamp(0.05, 1.0) : 0.05;
                        return _buildBar(b['day'] as String, h, primaryColor);
                      }).toList(),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Recent Orders
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkSlate,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _currentNavIndex = 1),
                  child: Text(
                    'View All',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_isLoadingOrders && _recentOrders.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator(color: Color(0xFFCC5500))),
            ),
          )
        else if (_recentOrders.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 48, color: textGrey.withOpacity(0.4)),
                    const SizedBox(height: 12),
                    Text('No orders yet', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: darkSlate)),
                    const SizedBox(height: 4),
                    Text('Orders from customers will appear here', style: GoogleFonts.inter(fontSize: 13, color: textGrey)),
                  ],
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final order = _recentOrders[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildOrderCard(order, primaryColor, darkSlate, textGrey),
              );
            }, childCount: _recentOrders.length > 5 ? 5 : _recentOrders.length),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 30)),

        // Sold Products Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.inventory_2_rounded, color: Color(0xFF10B981), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sold Products',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkSlate,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_soldProducts.length} items',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        if (_isLoadingSoldProducts && _soldProducts.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
            ),
          )
        else if (_soldProducts.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 48, color: textGrey.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    Text('No sold products yet', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600, color: darkSlate)),
                    const SizedBox(height: 4),
                    Text('Products you sell will be tracked here', style: GoogleFonts.inter(fontSize: 13, color: textGrey)),
                  ],
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final soldProduct = _soldProducts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: _buildSoldProductCard(soldProduct, primaryColor, darkSlate, textGrey),
              );
            }, childCount: _soldProducts.length > 10 ? 10 : _soldProducts.length),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }

  // ═══════════════════════════════════════
  // TAB 2: Orders
  // ═══════════════════════════════════════
  // TAB 2: ORDERS - Display all orders for vendor's products
  // ═══════════════════════════════════════
  Widget _buildOrdersTab(Color primaryColor, Color darkSlate, Color textGrey) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: primaryColor.withValues(alpha: 0.08)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'All Orders',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkSlate,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_recentOrders.length} orders',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _loadVendorOrders(
                      status: _selectedOrderFilter == 'All' ? null : _selectedOrderFilter,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.refresh_rounded, color: primaryColor, size: 20),
                    ),
                  ),
                ],
              ),
              // Vendor identity chip
              if (_vendorEmail != null || _vendorId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_rounded, size: 12, color: primaryColor),
                        const SizedBox(width: 5),
                        Text(
                          _vendorId != null
                              ? 'Vendor ID: $_vendorId${_vendorEmail != null ? ' • $_vendorEmail' : ''}'
                              : _vendorEmail!,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Order status filters
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', _selectedOrderFilter == 'All', primaryColor, () {
                  setState(() => _selectedOrderFilter = 'All');
                  _loadVendorOrders();
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', _selectedOrderFilter == 'pending', primaryColor, () {
                  setState(() => _selectedOrderFilter = 'pending');
                  _loadVendorOrders(status: 'pending');
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Confirmed', _selectedOrderFilter == 'confirmed', primaryColor, () {
                  setState(() => _selectedOrderFilter = 'confirmed');
                  _loadVendorOrders(status: 'confirmed');
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Preparing', _selectedOrderFilter == 'preparing', primaryColor, () {
                  setState(() => _selectedOrderFilter = 'preparing');
                  _loadVendorOrders(status: 'preparing');
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Ready', _selectedOrderFilter == 'ready', primaryColor, () {
                  setState(() => _selectedOrderFilter = 'ready');
                  _loadVendorOrders(status: 'ready');
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Completed', _selectedOrderFilter == 'delivered', primaryColor, () {
                  setState(() => _selectedOrderFilter = 'delivered');
                  _loadVendorOrders(status: 'delivered');
                }),
              ],
            ),
          ),
        ),
        
        // Orders List
        Expanded(
          child: _isLoadingOrders && _recentOrders.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFCC5500)),
                )
              : _recentOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: textGrey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No orders yet',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: darkSlate,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Orders will appear here',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: textGrey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _createTestOrder,
                            icon: const Icon(Icons.add_box_rounded),
                            label: Text(
                              'Create Test Order',
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _loadVendorOrders(
                        status: _selectedOrderFilter == 'All' ? null : _selectedOrderFilter,
                      ),
                      color: primaryColor,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.all(20),
                        itemCount: _recentOrders.length,
                        itemBuilder: (context, index) {
                          return _buildOrderCard(
                            _recentOrders[index],
                            primaryColor,
                            darkSlate,
                            textGrey,
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // TAB 3: Products
  // ═══════════════════════════════════════
  Widget _buildProductsTab(
    Color primaryColor,
    Color darkSlate,
    Color textGrey,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: 16),
          child: Row(
            children: [
              Text(
                'My Products',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: darkSlate,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_products.length} products',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingProducts
              ? Center(
                  child: CircularProgressIndicator(color: primaryColor),
                )
              : _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: textGrey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products yet',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: darkSlate,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first product to get started',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: textGrey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProducts,
                      color: primaryColor,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.paddingLarge,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          return _buildProductCardFromModel(
                            _products[index],
                            primaryColor,
                            darkSlate,
                            textGrey,
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════
  // TAB 4: Vendor Profile
  // ═══════════════════════════════════════
  Widget _buildProfileTab(Color primaryColor, Color darkSlate, Color textGrey) {
    if (_isLoadingProfile) {
      return Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }

    // Get real profile data or use defaults
    final businessName = _vendorProfile?['businessName'] ?? 'Loading...';
    final businessType = _vendorProfile?['businessType'] ?? 'Business';
    final city = _vendorProfile?['city'] ?? 'Location';
    final rating = _vendorProfile?['rating']?.toString() ?? '0.0';
    final reviewsCount = _vendorProfile?['reviewsCount']?.toString() ?? '0';
    final email = _vendorProfile?['email'] ?? '';
    final phone = _vendorProfile?['phone'] ?? '';
    final ownerFirstName = _vendorProfile?['ownerFirstName'] ?? '';
    final ownerLastName = _vendorProfile?['ownerLastName'] ?? '';
    final ownerFullName = ownerFirstName.isNotEmpty || ownerLastName.isNotEmpty
        ? '$ownerFirstName $ownerLastName'.trim()
        : 'Owner Name';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: 16),
      child: Column(
        children: [
          // Profile Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.08),
                  primaryColor.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: primaryColor.withValues(alpha: 0.12)),
            ),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 2),
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset('logo.png', fit: BoxFit.contain),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  businessName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: darkSlate,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '$businessType • $city',
                  style: GoogleFonts.inter(fontSize: 14, color: textGrey),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$rating ($reviewsCount reviews)',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: darkSlate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Owner info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 16, color: textGrey),
                          const SizedBox(width: 8),
                          Text(
                            'Owner: $ownerFullName',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: darkSlate,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.email_outlined, size: 16, color: textGrey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              email,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: darkSlate,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 16, color: textGrey),
                          const SizedBox(width: 8),
                          Text(
                            phone,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: darkSlate,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Menu items
          _buildProfileMenuItem(
            Icons.edit_rounded,
            'Edit Store Info',
            primaryColor,
            darkSlate,
            () async {
              if (_vendorProfile != null) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VendorEditProfileScreen(
                      currentProfile: _vendorProfile!,
                    ),
                  ),
                );
                // Reload profile if edit was successful
                if (result == true) {
                  _loadProfile();
                }
              }
            },
          ),
          _buildProfileMenuItem(
            Icons.account_balance_wallet_rounded,
            'Payment Settings',
            primaryColor,
            darkSlate,
            () {},
          ),
          _buildProfileMenuItem(
            Icons.local_shipping_rounded,
            'Delivery Settings',
            primaryColor,
            darkSlate,
            () {},
          ),
          _buildProfileMenuItem(
            Icons.analytics_rounded,
            'Analytics & Reports',
            primaryColor,
            darkSlate,
            () {
              Navigator.pushNamed(context, '/vendor_sales_report');
            },
          ),
          _buildProfileMenuItem(
            Icons.support_agent_rounded,
            'Support',
            primaryColor,
            darkSlate,
            () {
              Navigator.pushNamed(context, '/live_support_chat');
            },
          ),
          _buildProfileMenuItem(
            Icons.description_rounded,
            'Documents',
            primaryColor,
            darkSlate,
            () {},
          ),
          const SizedBox(height: 8),
          _buildProfileMenuItem(
            Icons.logout_rounded,
            'Log Out',
            const Color(0xFFEF4444),
            darkSlate,
            () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(
                    'Logout',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to logout?',
                    style: GoogleFonts.inter(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(color: textGrey),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ApiService.clearAuthData();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/vendor_login',
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // Add Product Bottom Sheet
  // ═══════════════════════════════════════
  void _showAddProductSheet(
    BuildContext context,
    Color primaryColor,
    Color darkSlate,
    Color textGrey,
  ) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final categoryController = TextEditingController();
    final discountPriceController = TextEditingController();
    final unitController = TextEditingController(text: 'piece');
    
    // For local images
    List<XFile> selectedImages = [];
    final ImagePicker picker = ImagePicker();
    
    bool isSubmitting = false;

    Future<void> pickImages() async {
      try {
        final List<XFile> images = await picker.pickMultiImage();
        if (images.isNotEmpty && images.length <= 3) {
          selectedImages = images;
        } else if (images.length > 3) {
          selectedImages = images.sublist(0, 3);
        }
      } catch (e) {
        // Handle error
        print('Error picking images: $e');
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add New Product',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: darkSlate,
                          ),
                        ),
                        GestureDetector(
                          onTap: isSubmitting ? null : () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.close_rounded, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Upload Section
                          _buildSheetLabel('Product Images', darkSlate),
                          const SizedBox(height: 8),
                          
                          // Pick from device button
                          GestureDetector(
                            onTap: () async {
                              await pickImages();
                              setModalState(() {}); // Update UI
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.15),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_rounded,
                                    color: primaryColor,
                                    size: 36,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Pick Images from Device',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Text(
                                    'Up to 3 images (PNG, JPG)',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Show selected images
                          if (selectedImages.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              '${selectedImages.length} image(s) selected',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: selectedImages.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: primaryColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: kIsWeb
                                          ? Image.network(
                                              selectedImages[index].path,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return const Icon(Icons.image);
                                              },
                                            )
                                          : Image.file(
                                              File(selectedImages[index].path),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 20),

                          _buildSheetLabel('Product Name *', darkSlate),
                          _buildSheetFieldWithController(
                            'e.g. Chicken Shawarma',
                            primaryColor,
                            darkSlate,
                            nameController,
                          ),
                          const SizedBox(height: 14),

                          _buildSheetLabel('Description', darkSlate),
                          _buildSheetFieldWithController(
                            'Describe your product',
                            primaryColor,
                            darkSlate,
                            descriptionController,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSheetLabel('Price (SDG) *', darkSlate),
                                    _buildSheetFieldWithController(
                                      '1,200',
                                      primaryColor,
                                      darkSlate,
                                      priceController,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSheetLabel('Stock Qty *', darkSlate),
                                    _buildSheetFieldWithController(
                                      '25',
                                      primaryColor,
                                      darkSlate,
                                      stockController,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSheetLabel('Category', darkSlate),
                                    _buildSheetFieldWithController(
                                      'e.g. Food',
                                      primaryColor,
                                      darkSlate,
                                      categoryController,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSheetLabel('Unit', darkSlate),
                                    _buildSheetFieldWithController(
                                      'piece',
                                      primaryColor,
                                      darkSlate,
                                      unitController,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          _buildSheetLabel('Discount Price (optional)', darkSlate),
                          _buildSheetFieldWithController(
                            '1,000',
                            primaryColor,
                            darkSlate,
                            discountPriceController,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 24),

                          // Submit Button
                          GestureDetector(
                            onTap: isSubmitting
                                ? null
                                : () async {
                                    // Validate
                                    if (nameController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please enter product name'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }
                                    
                                    if (priceController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please enter price'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    setModalState(() => isSubmitting = true);

                                    // Prepare image data for upload
                                    List<String>? imagePaths;
                                    List<Uint8List>? imageBytes;
                                    List<String>? imageNames;
                                    
                                    if (selectedImages.isNotEmpty) {
                                      if (kIsWeb) {
                                        // For web, read bytes from XFiles
                                        imageBytes = [];
                                        imageNames = [];
                                        for (final image in selectedImages) {
                                          try {
                                            final bytes = await image.readAsBytes();
                                            imageBytes.add(bytes);
                                            imageNames.add(image.name);
                                            print('Read web image: ${image.name} (${bytes.length} bytes)');
                                          } catch (e) {
                                            print('Error reading image bytes: $e');
                                          }
                                        }
                                      } else {
                                        // For mobile, use file paths
                                        imagePaths = selectedImages.map((img) => img.path).toList();
                                      }
                                    }

                                    // Call API with images
                                    final result = await ProductService.createProduct(
                                      name: nameController.text.trim(),
                                      price: double.tryParse(priceController.text.trim()) ?? 0,
                                      description: descriptionController.text.trim().isNotEmpty
                                          ? descriptionController.text.trim()
                                          : null,
                                      category: categoryController.text.trim().isNotEmpty
                                          ? categoryController.text.trim()
                                          : null,
                                      discountPrice:
                                          discountPriceController.text.trim().isNotEmpty
                                              ? double.tryParse(
                                                  discountPriceController.text.trim())
                                              : null,
                                      stockQuantity:
                                          int.tryParse(stockController.text.trim()) ?? 0,
                                      unit: unitController.text.trim().isNotEmpty
                                          ? unitController.text.trim()
                                          : 'piece',
                                      imagePaths: imagePaths,
                                      imageBytes: imageBytes,
                                      imageNames: imageNames,
                                    );

                                    setModalState(() => isSubmitting = false);

                                    if (result['success'] == true) {
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('Product added successfully!'),
                                            backgroundColor: primaryColor,
                                          ),
                                        );
                                        // Reload products
                                        _loadProducts();
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(result['error'] ?? 'Failed to add product'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                            child: Container(
                              width: double.infinity,
                              height: 54,
                              decoration: BoxDecoration(
                                gradient: isSubmitting
                                    ? LinearGradient(
                                        colors: [
                                          primaryColor.withOpacity(0.5),
                                          primaryColor.withOpacity(0.5),
                                        ],
                                      )
                                    : const LinearGradient(
                                        colors: [Color(0xFFCC5500), Color(0xFFE67322)],
                                      ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: isSubmitting
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: isSubmitting
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Add Product',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════
  // Component Builders
  // ═══════════════════════════════════════
  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    Color primaryColor,
    Color darkSlate,
  ) {
    final isActive = _currentNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentNavIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? primaryColor : const Color(0xFF94A3B8),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? primaryColor : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSDG(dynamic amount) {
    final double v = double.tryParse(amount?.toString() ?? '0') ?? 0;
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M SDG';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K SDG';
    return '${v.toStringAsFixed(0)} SDG';
  }

  List<Map<String, dynamic>> _getDailyBars() {
    final List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final rawList = (_vendorStats?['dailySales'] as List?) ?? [];
    final Map<String, double> byDate = {};
    for (final d in rawList) {
      final dateStr = d['sale_date']?.toString().split('T')[0] ?? '';
      byDate[dateStr] = double.tryParse(d['daily_sales']?.toString() ?? '0') ?? 0;
    }
    final now = DateTime.now();
    final List<Map<String, dynamic>> bars = [];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final ds = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      bars.add({'day': dayNames[date.weekday - 1], 'amount': byDate[ds] ?? 0.0});
    }
    return bars;
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.8), size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    String label,
    IconData icon,
    Color color,
    Color darkSlate,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.12)),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: darkSlate,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesMetric(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double height, Color primaryColor) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 80 * height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [primaryColor, primaryColor.withOpacity(0.5)],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(
    Map<String, dynamic> order,
    Color primaryColor,
    Color darkSlate,
    Color textGrey,
  ) {
    Color statusColor;
    IconData statusIcon;
    bool isOngoing = false;
    final String orderStatus = order['order_status'] ?? order['status'] ?? 'pending';
    
    switch (orderStatus) {
      case 'pending':
      case 'pending_vendor_confirmation':
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.hourglass_top_rounded;
        isOngoing = true;
        break;
      case 'vendor_confirmed':
      case 'confirmed':
        statusColor = const Color(0xFF3B82F6);
        statusIcon = Icons.check_circle_outline_rounded;
        isOngoing = true;
        break;
      case 'preparing':
        statusColor = const Color(0xFF3B82F6);
        statusIcon = Icons.restaurant_rounded;
        isOngoing = true;
        break;
      case 'ready':
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.local_shipping_rounded;
        isOngoing = true;
        break;
      case 'picked_up':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.local_shipping_rounded;
        isOngoing = true;
        break;
      case 'out_for_delivery':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.delivery_dining_rounded;
        isOngoing = true;
        break;
      case 'delivering':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.delivery_dining_rounded;
        isOngoing = true;
        break;
      case 'pending_confirmation':
        statusColor = const Color(0xFF8B5CF6);
        statusIcon = Icons.assignment_turned_in_rounded;
        isOngoing = true;
        break;
      case 'delivered':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'cancelled':
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle_rounded;
    }

    final String orderId = order['order_number'] ?? order['id']?.toString() ?? 'N/A';
    final String _nameRaw = '${order['first_name'] ?? ''} ${order['last_name'] ?? ''}'.trim();
    final String customerName = _nameRaw.isNotEmpty ? _nameRaw : (order['user_email']?.toString() ?? 'Customer');
    final double totalAmount = double.tryParse(order['final_amount']?.toString() ?? order['total_amount']?.toString() ?? '0') ?? 0.0;

    return GestureDetector(
      onTap: () => _showOrderDetailSheet(
        context,
        order,
        primaryColor,
        darkSlate,
        textGrey,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isOngoing
                ? statusColor.withOpacity(0.25)
                : primaryColor.withOpacity(0.06),
            width: isOngoing ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Animated status icon
                isOngoing
                    ? AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnim.value,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: statusColor.withOpacity(0.15),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                statusIcon,
                                color: statusColor,
                                size: 22,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(statusIcon, color: statusColor, size: 22),
                      ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              orderId,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: darkSlate,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Animated status badge
                          isOngoing
                              ? AnimatedBuilder(
                                  animation: _bounceAnim,
                                  builder: (context, child) {
                                    return Transform.translate(
                                        offset: Offset(
                                          0,
                                          -_bounceAnim.value * 0.3,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                statusColor,
                                                statusColor.withOpacity(0.7),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: statusColor.withOpacity(
                                                  0.3,
                                                ),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                orderStatus.toUpperCase().replaceAll('_', ' '),
                                                style: GoogleFonts.inter(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_rounded,
                                          color: statusColor,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'COMPLETED',
                                          style: GoogleFonts.inter(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: statusColor,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          () {
                            final items = order['items'] as List? ?? [];
                            final count = items.length;
                            return '$customerName • $count item${count != 1 ? 's' : ''}';
                          }(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: textGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SDG ${totalAmount.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            Text(
                              () {
                                try {
                                  final dt = DateTime.parse(order['created_at'] ?? '');
                                  return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
                                } catch (_) { return ''; }
                              }(),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: textGrey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Driver Info Row (when assigned)
              if (order['driver_id'] != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delivery_dining_rounded,
                            color: Color(0xFF10B981), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              () {
                                final fn = order['driver_first_name'] ?? '';
                                final ln = order['driver_last_name'] ?? '';
                                return '$fn $ln'.trim().isNotEmpty
                                    ? '$fn $ln'.trim()
                                    : 'Driver Assigned';
                              }(),
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF10B981)),
                            ),
                            Text(
                              order['driver_vehicle_type'] ?? '',
                              style: GoogleFonts.inter(
                                  fontSize: 10, color: textGrey),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle_outline_rounded,
                          color: Color(0xFF10B981), size: 18),
                    ],
                  ),
                ),
              ],
              // Vendor Action Button
              ..._buildVendorActionButton(
                  order['id'] as int? ?? 0,
                  orderStatus,
                  order['driver_id'] != null,
                  primaryColor),
            ],
          ),
        ),
    );
  }

  List<Widget> _buildVendorActionButton(
      int orderId, String status, bool driverAssigned, Color primaryColor) {
    // New order flow: pending_vendor_confirmation → vendor_confirmed
    if (status == 'pending_vendor_confirmation') {
      return [
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _vendorConfirmNewOrder(orderId),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('Confirm Order',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
        ),
      ];
    }

    // vendor_confirmed = waiting for driver
    if (status == 'vendor_confirmed') {
      return [
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text('Awaiting Driver',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF10B981))),
          ),
        ),
      ];
    }

    String? nextStatus;
    String? label;
    Color? color;

    switch (status) {
      case 'pending':
        nextStatus = 'confirmed';
        label = 'Confirm';
        color = const Color(0xFF3B82F6);
        break;
      case 'confirmed':
        nextStatus = 'preparing';
        label = 'Start Preparing';
        color = const Color(0xFF8B5CF6);
        break;
      case 'preparing':
        nextStatus = 'ready';
        label = 'Mark Ready';
        color = const Color(0xFF06B6D4);
        break;
      case 'ready':
        if (driverAssigned) {
          nextStatus = 'out_for_delivery';
          label = 'Out for Delivery';
          color = const Color(0xFF10B981);
        }
        break;
      case 'picked_up':
        nextStatus = 'out_for_delivery';
        label = 'Mark Out for Delivery';
        color = const Color(0xFF10B981);
        break;
    }

    if (nextStatus == null || label == null) return [];

    return [
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _vendorUpdateOrderStatus(orderId, nextStatus!),
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ),
    ];
  }

  Future<void> _vendorConfirmNewOrder(int orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Confirm Order',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text('Mark this order as "Confirm Order"?',
            style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC5500),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Confirm',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await OrderService.vendorConfirmOrder(orderId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true
                ? 'Order confirmed — drivers can now see it'
                : result['error'] ?? 'Failed to confirm order',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: result['success'] == true
              ? const Color(0xFF10B981)
              : const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      if (result['success'] == true) _loadVendorOrders();
    }
  }

  // Build Sold Product Card Widget
  Widget _buildSoldProductCard(
    Map<String, dynamic> soldProduct,
    Color primaryColor,
    Color darkSlate,
    Color textGrey,
  ) {
    final String productName = soldProduct['productName'] ?? 'Product';
    final int quantity = soldProduct['quantity'] ?? 0;
    final double totalPrice = double.tryParse(soldProduct['totalPrice']?.toString() ?? '0') ?? 0.0;
    final String orderNumber = soldProduct['orderNumber'] ?? 'N/A';
    final String orderStatus = soldProduct['orderStatus'] ?? 'pending';
    final String customerName = soldProduct['customerName'] ?? 'Customer';
    final String? productImage = soldProduct['productImage'];
    
    // Status color
    Color statusColor;
    IconData statusIcon;
    switch (orderStatus) {
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case 'confirmed':
      case 'preparing':
        statusColor = const Color(0xFF3B82F6);
        statusIcon = Icons.restaurant_rounded;
        break;
      case 'ready':
      case 'picked_up':
        statusColor = const Color(0xFF8B5CF6);
        statusIcon = Icons.local_shipping_rounded;
        break;
      case 'out_for_delivery':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.delivery_dining_rounded;
        break;
      case 'delivered':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle_rounded;
        break;
      default:
        statusColor = textGrey;
        statusIcon = Icons.info_outline;
    }

    return GestureDetector(
      onTap: () {
        // Show order tracking details
        _showSoldProductTracking(soldProduct, primaryColor, darkSlate, textGrey);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: productImage != null && productImage.isNotEmpty
                  ? Image.network(
                      productImage.startsWith('http')
                          ? productImage
                          : 'http://localhost:5000$productImage',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: primaryColor.withValues(alpha: 0.1),
                          child: Icon(Icons.inventory_2_rounded, color: primaryColor, size: 30),
                        );
                      },
                    )
                  : Container(
                      width: 60,
                      height: 60,
                      color: primaryColor.withValues(alpha: 0.1),
                      child: Icon(Icons.inventory_2_rounded, color: primaryColor, size: 30),
                    ),
            ),
            const SizedBox(width: 12),
            
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: darkSlate,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${quantity}x',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'SDG ${totalPrice.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 11, color: textGrey),
                      const SizedBox(width: 4),
                      Text(
                        orderNumber,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: textGrey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.person_outline_rounded, size: 11, color: textGrey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          customerName,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: textGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Status Badge
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  orderStatus.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSoldProductTracking(
    Map<String, dynamic> soldProduct,
    Color primaryColor,
    Color darkSlate,
    Color textGrey,
  ) {
    final String orderStatus = soldProduct['orderStatus'] ?? 'pending';
    final String orderNumber = soldProduct['orderNumber'] ?? '#N/A';
    final String productName = soldProduct['productName'] ?? 'Product';
    final int quantity = soldProduct['quantity'] ?? 0;
    final double unitPrice = double.tryParse(soldProduct['unitPrice']?.toString() ?? '0') ?? 0.0;
    final double totalPrice = double.tryParse(soldProduct['totalPrice']?.toString() ?? '0') ?? 0.0;
    final String customerName = soldProduct['customerName'] ?? 'Customer';
    final String customerPhone = soldProduct['customerPhone'] ?? 'N/A';
    final String deliveryAddress = soldProduct['deliveryAddress'] ?? 'No address';
    final String? driverName = soldProduct['driverName'];
    final String? driverPhone = soldProduct['driverPhone'];
    
    Color statusColor;
    IconData statusIcon;
    switch (orderStatus) {
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case 'confirmed':
        statusColor = const Color(0xFF3B82F6);
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'preparing':
        statusColor = const Color(0xFF8B5CF6);
        statusIcon = Icons.restaurant_rounded;
        break;
      case 'ready':
        statusColor = const Color(0xFF06B6D4);
        statusIcon = Icons.shopping_bag_rounded;
        break;
      case 'picked_up':
      case 'out_for_delivery':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.delivery_dining_rounded;
        break;
      case 'delivered':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle_rounded;
        break;
      default:
        statusColor = textGrey;
        statusIcon = Icons.info_outline;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sold Product Tracking',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: darkSlate)),
                                const SizedBox(height: 2),
                                Text(orderNumber,
                                    style: GoogleFonts.inter(
                                        fontSize: 13, color: textGrey)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.close_rounded, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Status Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [statusColor, statusColor.withValues(alpha: 0.7)]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: statusColor.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(statusIcon, color: Colors.white, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    orderStatus.toUpperCase().replaceAll('_', ' '),
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    'Order tracking status',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.white.withValues(alpha: 0.85)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Product Details
                      _buildDetailSection(
                        'Product Details',
                        Icons.inventory_2_rounded,
                        primaryColor,
                        darkSlate,
                        [
                          _buildDetailRow('Product Name', productName, darkSlate, textGrey),
                          _buildDetailRow('Quantity', '${quantity}x', darkSlate, textGrey),
                          _buildDetailRow('Unit Price', 'SDG ${unitPrice.toStringAsFixed(0)}', darkSlate, textGrey),
                          const Divider(height: 16),
                          _buildDetailRow('Total Price', 'SDG ${totalPrice.toStringAsFixed(0)}', darkSlate, primaryColor, isBold: true),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Customer Info
                      _buildDetailSection(
                        'Customer Information',
                        Icons.person_outline_rounded,
                        primaryColor,
                        darkSlate,
                        [
                          _buildDetailRow('Name', customerName, darkSlate, textGrey),
                          _buildDetailRow('Phone', customerPhone, darkSlate, textGrey),
                          _buildDetailRow('Address', deliveryAddress, darkSlate, textGrey),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Driver Info
                      if (driverName != null && driverName.isNotEmpty) ...[
                        _buildDetailSection(
                          'Driver Information',
                          Icons.delivery_dining_rounded,
                          const Color(0xFF10B981),
                          darkSlate,
                          [
                            _buildDetailRow('Driver', driverName, darkSlate, textGrey),
                            if (driverPhone != null && driverPhone.isNotEmpty)
                              _buildDetailRow('Phone', driverPhone, darkSlate, textGrey),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Close Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: Text('Close',
                              style: GoogleFonts.inter(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOrderDetailSheet(
    BuildContext context,
    Map<String, dynamic> order,
    Color primaryColor,
    Color darkSlate,
    Color textGrey,
  ) {
    final String orderStatus = order['order_status'] ?? order['status'] ?? 'pending';
    final String orderNumber = order['order_number'] ?? '#N/A';
    final String customerName =
        '${order['first_name'] ?? ''} ${order['last_name'] ?? ''}'.trim();
    final String customerPhone = order['phone'] ?? 'N/A';
    final String deliveryAddress = order['delivery_address'] ?? 'N/A';
    final double totalAmt =
        double.tryParse(order['total_amount']?.toString() ?? '0') ?? 0.0;
    final double deliveryFeeAmt =
        double.tryParse(order['delivery_fee']?.toString() ?? '0') ?? 0.0;
    final double finalAmt =
        double.tryParse(order['final_amount']?.toString() ?? '0') ?? 0.0;
    final List itemsList = order['items'] ?? [];
    final bool driverAssigned = order['driver_id'] != null;
    final String? driverName = order['driver_first_name'] != null
        ? '${order['driver_first_name']} ${order['driver_last_name'] ?? ''}'
            .trim()
        : null;
    final String? driverPhone = order['driver_phone'];
    final String? driverVehicle = order['driver_vehicle_type'];
    final int orderId = order['id'] as int? ?? 0;

    String formattedDate = '';
    try {
      final dt = DateTime.parse(order['created_at'] ?? '');
      formattedDate =
          '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}

    Color statusColor;
    IconData statusIcon;
    switch (orderStatus) {
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.schedule_rounded;
        break;
      case 'confirmed':
        statusColor = const Color(0xFF3B82F6);
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'preparing':
        statusColor = const Color(0xFF8B5CF6);
        statusIcon = Icons.restaurant_rounded;
        break;
      case 'ready':
        statusColor = const Color(0xFF06B6D4);
        statusIcon = Icons.shopping_bag_rounded;
        break;
      case 'picked_up':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.local_shipping_rounded;
        break;
      case 'out_for_delivery':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.delivery_dining_rounded;
        break;
      default:
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle_rounded;
    }

    final bool isCompleted =
        orderStatus == 'delivered' || orderStatus == 'delivering';
    final bool isOutForDelivery = orderStatus == 'out_for_delivery' ||
        orderStatus == 'picked_up' ||
        isCompleted;
    final bool isConfirmedOrBeyond = [
      'confirmed', 'preparing', 'ready', 'picked_up',
      'out_for_delivery', 'delivered', 'delivering'
    ].contains(orderStatus);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order Details',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: darkSlate)),
                              const SizedBox(height: 2),
                              Text(orderNumber,
                                  style: GoogleFonts.inter(
                                      fontSize: 14, color: textGrey)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child:
                                  const Icon(Icons.close_rounded, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Status Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                                statusColor,
                                statusColor.withOpacity(0.7)
                              ]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: statusColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isCompleted
                                  ? Icons.check_circle_rounded
                                  : statusIcon,
                              color: Colors.white,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    orderStatus
                                        .toUpperCase()
                                        .replaceAll('_', ' '),
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    isCompleted
                                        ? 'Order delivered successfully'
                                        : 'Placed: $formattedDate',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.white
                                            .withOpacity(0.85)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Vendor Action Button
                      ..._buildVendorActionButton(
                          orderId, orderStatus, driverAssigned, primaryColor),
                      const SizedBox(height: 16),

                      // Customer Info
                      _buildDetailSection(
                        'Customer',
                        Icons.person_rounded,
                        primaryColor,
                        darkSlate,
                        [
                          _buildDetailRow(
                              'Name',
                              customerName.isNotEmpty
                                  ? customerName
                                  : 'Customer',
                              darkSlate,
                              textGrey),
                          _buildDetailRow('Phone', customerPhone, darkSlate,
                              textGrey),
                          _buildDetailRow('Address', deliveryAddress,
                              darkSlate, textGrey),
                          _buildDetailRow(
                              'Order Time', formattedDate, darkSlate, textGrey),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Items Ordered
                      if (itemsList.isNotEmpty) ...[
                        _buildDetailSection(
                          'Items Ordered',
                          Icons.restaurant_menu_rounded,
                          primaryColor,
                          darkSlate,
                          [
                            ...itemsList.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${item['quantity'] ?? 1}x',
                                            style: GoogleFonts.inter(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: primaryColor),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          item['product_name'] ??
                                              item['name'] ??
                                              'Item',
                                          style: GoogleFonts.inter(
                                              fontSize: 13, color: darkSlate),
                                        ),
                                      ),
                                      Text(
                                        'SDG ${(double.tryParse(item['total_price']?.toString() ?? '0') ?? 0).toStringAsFixed(0)}',
                                        style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Cost Breakdown
                      _buildDetailSection(
                        'Cost Breakdown',
                        Icons.receipt_long_rounded,
                        primaryColor,
                        darkSlate,
                        [
                          _buildDetailRow(
                              'Subtotal',
                              'SDG ${totalAmt.toStringAsFixed(0)}',
                              darkSlate,
                              textGrey),
                          _buildDetailRow(
                              'Delivery Fee',
                              'SDG ${deliveryFeeAmt.toStringAsFixed(0)}',
                              darkSlate,
                              textGrey),
                          const Divider(height: 16),
                          _buildDetailRow(
                              'Total',
                              'SDG ${finalAmt.toStringAsFixed(0)}',
                              darkSlate,
                              primaryColor,
                              isBold: true),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Order Tracking Button (if driver assigned or status is out_for_delivery)
                      if (isOutForDelivery || driverAssigned) ...[
                        const SizedBox(height: 14),
                        _buildTrackOrderButton(order, primaryColor, darkSlate),
                        const SizedBox(height: 14),
                      ],

                      // Driver Info
                      Text('Delivery Driver',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkSlate)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBF7),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: primaryColor.withOpacity(0.12)),
                        ),
                        child: driverAssigned
                            ? Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981)
                                          .withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.delivery_dining_rounded,
                                        color: Color(0xFF10B981),
                                        size: 28),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          driverName ?? 'Driver',
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: darkSlate),
                                        ),
                                        if (driverVehicle != null)
                                          Text(driverVehicle,
                                              style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: textGrey)),
                                        if (driverPhone != null)
                                          Row(children: [
                                            Icon(Icons.phone_rounded,
                                                color: textGrey, size: 13),
                                            const SizedBox(width: 4),
                                            Text(driverPhone,
                                                style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color: textGrey)),
                                          ]),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: textGrey.withOpacity(0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.person_off_rounded,
                                        color: textGrey.withOpacity(0.5),
                                        size: 28),
                                  ),
                                  const SizedBox(width: 14),
                                  Text('No driver assigned yet',
                                      style: GoogleFonts.inter(
                                          fontSize: 14, color: textGrey)),
                                ],
                              ),
                      ),
                      const SizedBox(height: 20),

                      // Track Order Button (when driver assigned and in delivery)
                      if (driverAssigned && ['picked_up', 'out_for_delivery', 'pending_confirmation'].contains(orderStatus))
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(ctx); // Close detail sheet
                                  _showOrderTrackingDialog(order, primaryColor, darkSlate, textGrey);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.location_on_rounded, size: 20),
                                label: Text(
                                  'Track Order Live',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),

                      // Order Timeline
                      Text('Order Timeline',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkSlate)),
                      const SizedBox(height: 12),
                      _buildTimelineStep('Order Placed', formattedDate, true,
                          const Color(0xFF10B981), darkSlate, textGrey),
                      _buildTimelineConnector(const Color(0xFF10B981)),
                      _buildTimelineStep(
                          'Order Confirmed',
                          '',
                          isConfirmedOrBeyond,
                          isConfirmedOrBeyond
                              ? const Color(0xFF3B82F6)
                              : Colors.grey.shade300,
                          darkSlate,
                          textGrey),
                      _buildTimelineConnector(isOutForDelivery || isCompleted
                          ? const Color(0xFF10B981)
                          : Colors.grey.shade300),
                      _buildTimelineStep(
                          'Out for Delivery',
                          '',
                          isOutForDelivery || isCompleted,
                          isOutForDelivery || isCompleted
                              ? const Color(0xFF10B981)
                              : Colors.grey.shade300,
                          darkSlate,
                          textGrey),
                      _buildTimelineConnector(isCompleted
                          ? const Color(0xFF10B981)
                          : Colors.grey.shade300),
                      _buildTimelineStep(
                          'Delivered',
                          '',
                          isCompleted,
                          isCompleted
                              ? const Color(0xFF10B981)
                              : Colors.grey.shade300,
                          darkSlate,
                          textGrey),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(
    String title,
    IconData icon,
    Color accent,
    Color dark,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: dark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Color dark,
    Color valueColor, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    String title,
    String time,
    bool isDone,
    Color color,
    Color dark,
    Color grey,
  ) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: isDone ? color : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            boxShadow: isDone
                ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6)]
                : null,
          ),
          child: isDone
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDone ? dark : grey,
                ),
              ),
              Text(time, style: GoogleFonts.inter(fontSize: 11, color: grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector(Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Container(width: 2, height: 24, color: color.withOpacity(0.4)),
    );
  }

  // Show order tracking dialog with live status
  void _showOrderTrackingDialog(
    Map<String, dynamic> order,
    Color primaryColor,
    Color darkSlate,
    Color textGrey,
  ) {
    final String orderStatus = order['order_status'] ?? order['status'] ?? 'pending';
    final String orderNumber = order['order_number'] ?? '#N/A';
    final bool driverAssigned = order['driver_id'] != null;
    final String? driverName = order['driver_first_name'] != null
        ? '${order['driver_first_name']} ${order['driver_last_name'] ?? ''}'
            .trim()
        : null;
    final String? driverPhone = order['driver_phone'];
    final String? driverVehicle = order['driver_vehicle_type'];
    final String? driverPlate = order['driver_vehicle_plate'];
    final String deliveryAddress = order['delivery_address'] ?? 'N/A';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping_rounded,
                        color: Color(0xFF10B981), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Tracking',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkSlate,
                          ),
                        ),
                        Text(
                          orderNumber,
                          style: GoogleFonts.inter(fontSize: 13, color: textGrey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.grey.withOpacity(0.2)),
              const SizedBox(height: 20),

              // Driver Info
              if (driverAssigned)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF10B981),
                        child: Text(
                          driverName != null && driverName.isNotEmpty
                              ? driverName[0].toUpperCase()
                              : 'D',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driverName ?? 'Driver',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: darkSlate,
                              ),
                            ),
                            if (driverVehicle != null && driverPlate != null)
                              Text(
                                '$driverVehicle • $driverPlate',
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: textGrey),
                              ),
                          ],
                        ),
                      ),
                      if (driverPhone != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.phone,
                              color: Color(0xFF10B981), size: 18),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Order Status Timeline
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Status',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: darkSlate,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildTrackingStep('Order Placed', true, true),
                      _buildTrackingStep('Confirmed', true, true),
                      _buildTrackingStep('Preparing', true, true),
                      _buildTrackingStep('Ready for Pickup', true, true),
                      _buildTrackingStep(
                        'Picked Up',
                        [
                          'picked_up',
                          'out_for_delivery',
                          'pending_confirmation',
                          'delivered'
                        ].contains(orderStatus),
                        [
                          'picked_up',
                          'out_for_delivery',
                          'pending_confirmation',
                          'delivered'
                        ].contains(orderStatus),
                      ),
                      _buildTrackingStep(
                        'Out for Delivery',
                        [
                          'out_for_delivery',
                          'pending_confirmation',
                          'delivered'
                        ].contains(orderStatus),
                        [
                          'out_for_delivery',
                          'pending_confirmation',
                          'delivered'
                        ].contains(orderStatus),
                      ),
                      _buildTrackingStep(
                        'Delivered',
                        orderStatus == 'delivered',
                        false,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Customer Address
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: Color(0xFFCC5500), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        deliveryAddress,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: textGrey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingStep(String label, bool completed, bool showLine) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: completed
                    ? const Color(0xFF10B981)
                    : Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: completed ? const Color(0xFF10B981) : Colors.grey,
                  width: 2,
                ),
              ),
              child: completed
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (showLine)
              Container(
                width: 2,
                height: 30,
                color: completed
                    ? const Color(0xFF10B981)
                    : Colors.grey.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: completed ? FontWeight.w600 : FontWeight.normal,
              color: completed
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF94A3B8),
            ),
          ),
        ),
      ],
    );
  }

  // Build Track Order Button Widget
  Widget _buildTrackOrderButton(
    Map<String, dynamic> order,
    Color primaryColor,
    Color darkSlate,
  ) {
    return GestureDetector(
      onTap: () => _showOrderTrackingDialog(
        order,
        primaryColor,
        darkSlate,
        const Color(0xFF475569),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF10B981),
              const Color(0xFF059669),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              'Track Order Live',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    Map<String, dynamic> product,
    Color primaryColor,
    Color darkSlate,
    Color textGrey,
  ) {
    final isOutOfStock = product['status'] == 'out_of_stock';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOutOfStock
              ? const Color(0xFFEF4444).withOpacity(0.15)
              : primaryColor.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isOutOfStock
                  ? const Color(0xFFFEE2E2)
                  : primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              product['image'],
              color: isOutOfStock ? const Color(0xFFEF4444) : primaryColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product['name'],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: darkSlate,
                        ),
                      ),
                    ),
                    PopupMenuButton(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: textGrey,
                        size: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  product['price'],
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.shopping_bag_rounded, size: 14, color: textGrey),
                    const SizedBox(width: 4),
                    Text(
                      '${product['sales']} sold',
                      style: GoogleFonts.inter(fontSize: 12, color: textGrey),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.inventory_2_rounded,
                      size: 14,
                      color: isOutOfStock ? const Color(0xFFEF4444) : textGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOutOfStock
                          ? 'Out of stock'
                          : '${product['stock']} in stock',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isOutOfStock
                            ? FontWeight.bold
                            : FontWeight.w400,
                        color: isOutOfStock
                            ? const Color(0xFFEF4444)
                            : textGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive, Color primaryColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? primaryColor : primaryColor.withOpacity(0.12),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(
    IconData icon,
    String label,
    Color color,
    Color darkSlate,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: darkSlate,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFFCBD5E1),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetLabel(String label, Color darkSlate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: darkSlate,
        ),
      ),
    );
  }

  Widget _buildSheetField(
    String hint,
    Color primaryColor,
    Color darkSlate, {
    int maxLines = 1,
  }) {
    return TextField(
      maxLines: maxLines,
      style: GoogleFonts.inter(fontSize: 14, color: darkSlate),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: const Color(0xFFADB5BD)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: primaryColor.withOpacity(0.5),
            width: 2,
          ),
        ),
      ),
    );
  }

  // New method with controller support
  Widget _buildSheetFieldWithController(
    String hint,
    Color primaryColor,
    Color darkSlate,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14, color: darkSlate),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: const Color(0xFFADB5BD)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: primaryColor.withOpacity(0.5),
            width: 2,
          ),
        ),
      ),
    );
  }

  // Product card from Product model
  Widget _buildProductCardFromModel(
    Product product,
    Color primaryColor,
    Color darkSlate,
    Color textGrey,
  ) {
    final isOutOfStock = !product.isInStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOutOfStock
              ? const Color(0xFFEF4444).withOpacity(0.15)
              : primaryColor.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isOutOfStock
                  ? const Color(0xFFFEE2E2)
                  : primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: product.images.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      product.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.restaurant_rounded,
                        color: isOutOfStock
                            ? const Color(0xFFEF4444)
                            : primaryColor,
                        size: 26,
                      ),
                    ),
                  )
                : Icon(
                    Icons.restaurant_rounded,
                    color: isOutOfStock
                        ? const Color(0xFFEF4444)
                        : primaryColor,
                    size: 26,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: darkSlate,
                        ),
                      ),
                    ),
                    PopupMenuButton(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: textGrey,
                        size: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'delete') {
                          final result = await ProductService.deleteProduct(product.id);
                          if (result['success'] == true && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Product deleted successfully'),
                                backgroundColor: primaryColor,
                              ),
                            );
                            _loadProducts();
                          }
                        }
                      },
                    ),
                  ],
                ),
                Text(
                  product.displayPrice,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.shopping_bag_rounded, size: 14, color: textGrey),
                    const SizedBox(width: 4),
                    Text(
                      '${product.totalSales} sold',
                      style: GoogleFonts.inter(fontSize: 12, color: textGrey),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.inventory_2_rounded,
                      size: 14,
                      color: isOutOfStock ? const Color(0xFFEF4444) : textGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOutOfStock
                          ? 'Out of stock'
                          : '${product.stockQuantity} in stock',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight:
                            isOutOfStock ? FontWeight.bold : FontWeight.w400,
                        color: isOutOfStock
                            ? const Color(0xFFEF4444)
                            : textGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
