import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/nafaj_bottom_nav.dart';
import 'nafaj_shop_details_screen.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../services/api_service.dart';
import '../constants.dart';

class Shop {
  final String id;
  final String name;
  final String category;
  final String imageUrl;
  final String deliveryTime;
  final String distance;
  final String phone;
  final double rating;
  final int productCount;

  Shop({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.deliveryTime,
    required this.distance,
    required this.phone,
    this.rating = 0.0,
    this.productCount = 0,
  });
}

class Product {
  final String id;
  final String name;
  final String price;
  final String qantity;
  final String imageUrl;
  final int vendorId;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.qantity,
    required this.imageUrl,
    required this.vendorId,
  });

  // Convert to CartProduct for cart service
  CartProduct toCartProduct() {
    return CartProduct(
      id: id,
      name: name,
      price: double.tryParse(price) ?? 0.0,
      unit: qantity,
      imageUrl: imageUrl,
      vendorId: vendorId,
    );
  }
}

// Mock Data
final List<Shop> mockShops = [
  Shop(
    id: 's1',
    name: 'Al-Saha Pharmacy',
    category: 'Pharmacy',
    imageUrl:
        'https://images.unsplash.com/photo-1586015555751-63bb77f4322a?auto=format&fit=crop&q=80',
    deliveryTime: '15 mins',
    distance: '1.5 km',
    phone: '+249 111 222 333',
  ),
  Shop(
    id: 's2',
    name: 'Fresh Market Grocery',
    category: 'Grocery',
    imageUrl:
        'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80',
    deliveryTime: '20 mins',
    distance: '2.1 km',
    phone: '+249 987 654 321',
  ),
  Shop(
    id: 's3',
    name: 'Nile View Grill',
    category: 'Food',
    imageUrl:
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&q=80',
    deliveryTime: '35 mins',
    distance: '4.2 km',
    phone: '+249 123 456 789',
  ),
  Shop(
    id: 's4',
    name: 'Swift Courier Services',
    category: 'Courier',
    imageUrl:
        'https://images.unsplash.com/photo-1620456184519-74e2d36abfbe?auto=format&fit=crop&q=80',
    deliveryTime: '10 mins',
    distance: '0.8 km',
    phone: '+249 444 555 666',
  ),
  Shop(
    id: 's5',
    name: 'Home Fix Maintenance',
    category: 'Services',
    imageUrl:
        'https://images.unsplash.com/photo-1581578731548-c64695cc6952?auto=format&fit=crop&q=80',
    deliveryTime: '60 mins',
    distance: '5.0 km',
    phone: '+249 777 888 999',
  ),
  Shop(
    id: 's6',
    name: 'Tech Haven Electronics',
    category: 'Classifieds',
    imageUrl:
        'https://images.unsplash.com/photo-1531297172864-cf22ea8064eb?auto=format&fit=crop&q=80',
    deliveryTime: '45 mins',
    distance: '6.2 km',
    phone: '+249 000 111 222',
  ),
];

// Product Mock Data
final List<Product> mockProducts = [
  Product(
    id: 'p1',
    name: 'Fresh Milk',
    price: '450',
    qantity: '1L',
    imageUrl: 'milk.png',
    vendorId: 1,
  ),
  Product(
    id: 'p2',
    name: 'Farm Eggs',
    price: '800',
    qantity: '12 pcs',
    imageUrl: 'eggs.png',
    vendorId: 1,
  ),
  Product(
    id: 'p3',
    name: 'Fresh Bread',
    price: '200',
    qantity: '600g',
    imageUrl:
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&q=80',
    vendorId: 1,
  ),
  Product(
    id: 'p4',
    name: 'Arabica Coffee',
    price: '2500',
    qantity: '250g',
    imageUrl:
        'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?auto=format&fit=crop&q=80',
    vendorId: 1,
  ),
  Product(
    id: 'p5',
    name: 'Sudanese Dates',
    price: '1200',
    qantity: '500g',
    imageUrl:
        'https://images.unsplash.com/photo-1594132049079-052a65d669ad?auto=format&fit=crop&q=80',
    vendorId: 1,
  ),
  Product(
    id: 'p6',
    name: 'Local Honey',
    price: '3000',
    qantity: '250g',
    imageUrl:
        'https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&q=80',
    vendorId: 1,
  ),
];

class NafajMarketplaceHomeScreen extends StatefulWidget {
  const NafajMarketplaceHomeScreen({super.key});

  @override
  State<NafajMarketplaceHomeScreen> createState() =>
      _NafajMarketplaceHomeScreenState();
}

class _NafajMarketplaceHomeScreenState
    extends State<NafajMarketplaceHomeScreen> {
  String selectedCategory = 'All';
  final CartService _cartService = CartService();
  
  // State variables for real data
  bool _isLoadingProducts = true;
  bool _isLoadingVendors = true;
  List<dynamic> _realProducts = [];
  List<dynamic> _realVendors = [];
  String? _productsError;
  String? _vendorsError;

  final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.apps_rounded, 'tag': ''},
    {'name': 'Summer', 'icon': Icons.wb_sunny_rounded, 'tag': 'New'},
    {'name': 'Electronics', 'icon': Icons.headphones_rounded, 'tag': ''},
    {
      'name': 'Beauty',
      'icon': Icons.face_retouching_natural_rounded,
      'tag': '',
    },
    {'name': 'Decor', 'icon': Icons.chair_rounded, 'tag': ''},
    {'name': 'Kids', 'icon': Icons.child_care_rounded, 'tag': ''},
  ];

  @override
  void initState() {
    super.initState();
    _loadRealData();
  }

  Future<void> _loadRealData() async {
    // Load products
    _loadProducts();
    
    // Load vendors
    _loadVendors();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _productsError = null;
    });

    try {
      final result = await ProductService.getAllProducts(
        status: 'active',
        limit: 10,
      );

      if (result['success'] == true) {
        setState(() {
          _realProducts = result['data'] ?? [];
          _isLoadingProducts = false;
        });
      } else {
        setState(() {
          _productsError = result['error'] ?? 'Failed to load products';
          _isLoadingProducts = false;
        });
      }
    } catch (e) {
      setState(() {
        _productsError = 'Error: $e';
        _isLoadingProducts = false;
      });
    }
  }

  Future<void> _loadVendors() async {
    setState(() {
      _isLoadingVendors = true;
      _vendorsError = null;
    });

    try {
      final result = await ApiService.getAllVendors(
        status: 'active',
        limit: 10,
      );

      if (result['success'] == true) {
        setState(() {
          _realVendors = result['data'] ?? [];
          _isLoadingVendors = false;
        });
      } else {
        setState(() {
          _vendorsError = result['error'] ?? 'Failed to load vendors';
          _isLoadingVendors = false;
        });
      }
    } catch (e) {
      setState(() {
        _vendorsError = 'Error: $e';
        _isLoadingVendors = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkOrange = Color(0xFFCC5500);
    const Color primaryLightOrange = Color(0xFFFF8C00);
    const Color bgColor = Color(0xFFF4F6F8);
    const Color darkSlate = Color(0xFF0F172A);

    // Use real vendors instead of mock shops
    List<dynamic> displayedVendors = _realVendors;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                backgroundColor: primaryDarkOrange,
                expandedHeight: 140.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryDarkOrange, primaryLightOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                title: _buildHeaderTitle(),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: _buildSearchBar(),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoriesSection(
                      primaryDarkOrange,
                      primaryLightOrange,
                    ),

                    // Featured Products Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppConstants.paddingLarge, 24, AppConstants.paddingLarge, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Featured for You',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkSlate,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'See all',
                              style: GoogleFonts.plusJakartaSans(
                                color: primaryDarkOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Products List or Loading
                    _isLoadingProducts
                        ? const SizedBox(
                            height: 230,
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : _productsError != null
                            ? Container(
                                height: 230,
                                padding: const EdgeInsets.all(AppConstants.paddingLarge),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                                      const SizedBox(height: 8),
                                      Text(
                                        _productsError!,
                                        style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _loadProducts,
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : _realProducts.isEmpty
                                ? Container(
                                    height: 230,
                                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                                    child: Center(
                                      child: Text(
                                        'No products available',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    height: 230,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                                      itemCount: _realProducts.length,
                                      itemBuilder: (context, index) {
                                        final product = _realProducts[index];
                                        return _buildRealProductCard(context, product);
                                      },
                                    ),
                                  ),

                    // Popular Shops Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppConstants.paddingLarge, 24, AppConstants.paddingLarge, 16),
                      child: Text(
                        'Popular Shops',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkSlate,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Shops List Grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppConstants.paddingLarge, 0, AppConstants.paddingLarge, 120),
                sliver: _isLoadingVendors
                    ? const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      )
                    : _vendorsError != null
                        ? SliverToBoxAdapter(
                            child: Container(
                              height: 200,
                              padding: const EdgeInsets.all(AppConstants.paddingLarge),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                                    const SizedBox(height: 8),
                                    Text(
                                      _vendorsError!,
                                      style: GoogleFonts.plusJakartaSans(color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _loadVendors,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : displayedVendors.isEmpty
                            ? SliverToBoxAdapter(
                                child: Container(
                                  height: 200,
                                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                                  child: Center(
                                    child: Text(
                                      'No shops available',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final vendor = displayedVendors[index];
                                    return _buildRealVendorCard(context, vendor, darkSlate);
                                  },
                                  childCount: displayedVendors.length,
                                ),
                              ),
              ),
            ],
          ),

          // Floating Cart Bar
          _buildFloatingCartBar(),

          // Bottom Nav
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: NafajBottomNav(currentIndex: 0, onTap: (index) {}),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nafaj in',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              Row(
                children: [
                  Text(
                    '15 mins',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.flash_on_rounded,
                    color: Colors.yellow,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.amber,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person_rounded, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppConstants.paddingLarge, 0, AppConstants.paddingLarge, 12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search "fresh milk"',
            prefixIcon: const Icon(Icons.search_rounded),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(
    Color primaryDarkOrange,
    Color primaryLightOrange,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryLightOrange, const Color(0xFFFFA022)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory == cat['name'];
                return _buildCategoryItem(cat, isSelected, primaryDarkOrange);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    Map<String, dynamic> cat,
    bool isSelected,
    Color primaryDarkOrange,
  ) {
    return GestureDetector(
      onTap: () => setState(() => selectedCategory = cat['name']),
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                cat['icon'],
                color: isSelected ? primaryDarkOrange : Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cat['name'],
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return ListenableBuilder(
      listenable: _cartService,
      builder: (context, _) {
        final int quantity = _cartService.getProductQuantity(product.id);
        const primaryDarkOrange = Color(0xFFCC5500);

        return Container(
          width: 140,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: product.imageUrl.startsWith('http')
                    ? Image.network(
                        product.imageUrl,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 110,
                          color: Colors.grey[100],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Image.asset(
                        product.imageUrl,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                    ),
                    Text(
                      product.qantity,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SDG ${product.price}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: primaryDarkOrange,
                          ),
                        ),
                        if (quantity == 0)
                          _buildAddButton(product, primaryDarkOrange)
                        else
                          _buildQuantityControls(
                            product,
                            quantity,
                            primaryDarkOrange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddButton(Product product, Color color) {
    return GestureDetector(
      onTap: () => _cartService.addItem(product.toCartProduct()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'ADD',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityControls(Product product, int quantity, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _qBtn(Icons.remove, () => _cartService.removeItem(product.id)),
          Text(
            '$quantity',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          _qBtn(Icons.add, () => _cartService.addItem(product.toCartProduct())),
        ],
      ),
    );
  }

  Widget _qBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }

  Widget _buildShopCard(BuildContext context, Shop shop, Color darkSlate) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NafajShopDetailsScreen(shop: shop),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                shop.imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkSlate,
                        ),
                      ),
                      Text(
                        shop.deliveryTime,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingCartBar() {
    return ListenableBuilder(
      listenable: _cartService,
      builder: (context, _) {
        if (_cartService.items.isEmpty) return const SizedBox.shrink();
        const primaryDarkOrange = Color(0xFFCC5500);

        return Positioned(
          bottom: 85,
          left: 16,
          right: 16,
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: primaryDarkOrange,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_cartService.totalItems} Items',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'SDG ${_cartService.subtotal.toStringAsFixed(0)}',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/checkout_screen'),
                  icon: const Icon(
                    Icons.shopping_cart_checkout_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    'PROCEED',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build real product card from database
  Widget _buildRealProductCard(BuildContext context, dynamic product) {
    final productId = product['id']?.toString() ?? '';
    final productName = product['name'] ?? 'Unnamed Product';
    
    // Use discount_price if available, otherwise use price (same as backend logic)
    final discountPrice = product['discount_price'];
    final regularPrice = product['price'];
    final productPrice = (discountPrice != null && discountPrice.toString() != '0' && discountPrice.toString().isNotEmpty)
        ? discountPrice.toString()
        : (regularPrice?.toString() ?? '0');
    
    final productUnit = product['unit'] ?? '';
    final vendorId = product['vendor_id'] ?? 1;
    
    // Parse price to double for cart
    final priceDouble = double.tryParse(productPrice) ?? 0.0;
    
    // Parse images properly - handle both array and string
    String imageUrl = '';
    final imagesField = product['images'];
    
    print('Product: $productName, Images field: $imagesField, Type: ${imagesField.runtimeType}');
    
    if (imagesField != null) {
      if (imagesField is List && imagesField.isNotEmpty) {
        imageUrl = imagesField[0].toString();
      } else if (imagesField is String && imagesField.isNotEmpty) {
        // Try to parse as JSON array
        try {
          final List<dynamic> parsedImages = json.decode(imagesField);
          if (parsedImages.isNotEmpty) {
            imageUrl = parsedImages[0].toString();
          }
        } catch (e) {
          // If parsing fails, use as direct URL
          imageUrl = imagesField;
        }
      }
    }
    
    print('Final imageUrl: $imageUrl');

    // Create Product object for display (with String price)
    final displayProduct = Product(
      id: productId,
      name: productName,
      price: productPrice,
      qantity: productUnit,
      imageUrl: imageUrl,
      vendorId: vendorId,
    );

    // We'll create CartProduct when adding to cart

    return ListenableBuilder(
      listenable: _cartService,
      builder: (context, _) {
        final int quantity = _cartService.getProductQuantity(productId);
        const primaryDarkOrange = Color(0xFFCC5500);

        return Container(
          width: 140,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 110,
                            color: Colors.grey[100],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: primaryDarkOrange,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('Image load error: $error for URL: $imageUrl');
                          return Container(
                            height: 110,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey[200]!,
                                  Colors.grey[100]!,
                                ],
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 35,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'No Image',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 110,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryDarkOrange.withValues(alpha: 0.1),
                              primaryDarkOrange.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_rounded,
                              color: Color(0xFFCC5500),
                              size: 40,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'No Image',
                              style: TextStyle(
                                color: Color(0xFFCC5500),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      productUnit,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SDG $productPrice',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: primaryDarkOrange,
                          ),
                        ),
                        if (quantity == 0)
                          _buildAddButton(displayProduct, primaryDarkOrange)
                        else
                          _buildQuantityControls(
                            displayProduct,
                            quantity,
                            primaryDarkOrange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Build real vendor card from database
  Widget _buildRealVendorCard(BuildContext context, dynamic vendor, Color darkSlate) {
    final businessName = vendor['businessName'] ?? 'Unnamed Shop';
    final businessType = vendor['businessType'] ?? 'General';
    final city = vendor['city'] ?? '';
    final shopAddress = vendor['shopAddress'] ?? '';
    final phone = vendor['phone'] ?? '';
    final rating = double.tryParse(vendor['rating']?.toString() ?? '0') ?? 0.0;
    final totalProducts = vendor['totalProducts'] ?? 0;
    
    // Create location string
    String location = '';
    if (shopAddress.isNotEmpty && city.isNotEmpty) {
      location = '$shopAddress, $city';
    } else if (shopAddress.isNotEmpty) {
      location = shopAddress;
    } else if (city.isNotEmpty) {
      location = city;
    } else {
      location = 'Location not specified';
    }
    
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening $businessName'),
            duration: const Duration(seconds: 1),
            backgroundColor: const Color(0xFFCC5500),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Image/Icon Container with Gradient
            Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF8C00).withValues(alpha: 0.15),
                    const Color(0xFFCC5500).withValues(alpha: 0.25),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.05,
                      child: Icon(
                        Icons.store,
                        size: 200,
                        color: const Color(0xFFCC5500),
                      ),
                    ),
                  ),
                  // Main icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _getBusinessIcon(businessType),
                        size: 50,
                        color: const Color(0xFFCC5500),
                      ),
                    ),
                  ),
                  // Business Type Badge
                  if (businessType.isNotEmpty)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          businessType.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFCC5500),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Shop Details Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop Name
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          businessName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkSlate,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Rating and Reviews
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < rating.floor()
                              ? Icons.star
                              : (index < rating && rating % 1 != 0)
                                  ? Icons.star_half
                                  : Icons.star_border,
                          size: 16,
                          color: Colors.amber[700],
                        );
                      }),
                      const SizedBox(width: 6),
                      Text(
                        rating.toStringAsFixed(1),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      if (vendor['reviewsCount'] != null && vendor['reviewsCount'] > 0) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(${vendor['reviewsCount']})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  
                  // Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: Color(0xFFCC5500),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Phone Number
                  if (phone.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_rounded,
                          size: 18,
                          color: Color(0xFFCC5500),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          phone,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 14),
                  
                  // Products Count and Action Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCC5500).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFCC5500).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.inventory_2_rounded,
                              size: 16,
                              color: Color(0xFFCC5500),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$totalProducts ${totalProducts == 1 ? 'item' : 'items'}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: const Color(0xFFCC5500),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCC5500),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          size: 20,
                          color: Colors.white,
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
    );
  }

  IconData _getBusinessIcon(String businessType) {
    switch (businessType.toLowerCase()) {
      case 'pharmacy':
        return Icons.local_pharmacy;
      case 'grocery':
        return Icons.local_grocery_store;
      case 'food':
      case 'restaurant':
        return Icons.restaurant;
      case 'electronics':
        return Icons.devices;
      case 'courier':
        return Icons.local_shipping;
      default:
        return Icons.store;
    }
  }
}
