import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/nafaj_bottom_nav.dart';
import 'nafaj_shop_details_screen.dart';
import 'nafaj_marketplace_home.dart' show Shop, mockShops;
import 'nafaj_marketplace_home.dart' as marketplace;
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../services/api_service.dart';
import '../models/product_model.dart' as prod_model;
import '../config/api_config.dart';

// Product class for display
class Product {
  final String id;
  final String name;
  final String price;
  final String qantity;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.qantity,
    required this.imageUrl,
  });

  // Convert from backend Product model
  factory Product.fromProductModel(prod_model.Product product) {
    // Get image URL - handle both full URLs and relative paths
    String imageUrl = '';
    if (product.images.isNotEmpty) {
      final img = product.images.first;
      if (img.startsWith('http')) {
        imageUrl = img; // Already full URL
      } else if (img.startsWith('/')) {
        imageUrl = 'http://localhost:5000$img'; // Relative path from root
      } else {
        imageUrl = 'http://localhost:5000/$img'; // Relative path without slash
      }
    }
    
    print('Product: ${product.name}, Image URL: $imageUrl');
    
    return Product(
      id: product.id.toString(),
      name: product.name,
      price: product.effectivePrice.toStringAsFixed(0), // Use effective price (discount if available)
      qantity: product.unit ?? 'pcs',
      imageUrl: imageUrl,
    );
  }

  // Convert to CartProduct for cart service
  CartProduct toCartProduct() {
    return CartProduct(
      id: id,
      name: name,
      price: double.tryParse(price) ?? 0.0,
      unit: qantity,
      imageUrl: imageUrl,
      vendorId: 1, // Default vendor ID
    );
  }
}

class NafajHomeExactHeaderMatchScreen extends StatefulWidget {
  const NafajHomeExactHeaderMatchScreen({super.key});

  @override
  State<NafajHomeExactHeaderMatchScreen> createState() =>
      _NafajHomeExactHeaderMatchScreenState();
}

class _NafajHomeExactHeaderMatchScreenState
    extends State<NafajHomeExactHeaderMatchScreen> {
  String selectedCategory = 'Food';
  String userAddress = 'HOME - Khartoum, Riyadh, Street 15';
  final CartService _cartService = CartService();
  
  // Real data from API
  List<Product> _featuredProducts = [];
  List<Map<String, dynamic>> _vendors = [];
  bool _isLoadingProducts = false;
  bool _isLoadingVendors = false;

  @override
  void initState() {
    super.initState();
    _loadFeaturedProducts();
    _loadVendors();
  }

  Future<void> _loadFeaturedProducts() async {
    setState(() => _isLoadingProducts = true);
    
    final result = await ProductService.getAllProducts(limit: 10, status: 'active');
    
    if (result['success'] == true && mounted) {
      final data = result['data'];
      if (data != null) {
        try {
          final products = (data as List)
              .map((json) => prod_model.Product.fromJson(json))
              .map((p) => Product.fromProductModel(p))
              .toList();
          
          setState(() {
            _featuredProducts = products;
            _isLoadingProducts = false;
          });
        } catch (e) {
          print('Error parsing products: $e');
          setState(() => _isLoadingProducts = false);
        }
      } else {
        setState(() => _isLoadingProducts = false);
      }
    } else {
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  Future<void> _loadVendors() async {
    print('=== Loading Vendors ===');
    setState(() => _isLoadingVendors = true);
    
    try {
      // Fetch real vendors from API
      final result = await ApiService.getAllVendors(status: 'active', limit: 10);
      
      print('Vendors API Result: $result');
      
      if (result['success'] == true && mounted) {
        final data = result['data'];
        if (data != null) {
          final vendorsList = List<Map<String, dynamic>>.from(data);
          print('Loaded ${vendorsList.length} vendors');
          
          setState(() {
            _vendors = vendorsList;
            _isLoadingVendors = false;
          });
        } else {
          print('Vendors data is null');
          setState(() => _isLoadingVendors = false);
        }
      } else {
        print('Vendors API failed: ${result['error']}');
        if (mounted) {
          setState(() => _isLoadingVendors = false);
        }
      }
    } catch (e) {
      print('Error loading vendors: $e');
      if (mounted) {
        setState(() => _isLoadingVendors = false);
      }
    }
  }

  void _showAddressDialog() {
    final TextEditingController addressController = TextEditingController(
      text: userAddress,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Address',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: addressController,
          decoration: const InputDecoration(hintText: "Enter your address"),
          style: GoogleFonts.plusJakartaSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userAddress = addressController.text;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC5500),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> categories = [
    {'name': 'Food', 'icon': Icons.restaurant_rounded, 'tag': ''},
    {'name': 'Pharmacy', 'icon': Icons.medication_rounded, 'tag': 'Fast'},
    {'name': 'Jobs', 'icon': Icons.work_rounded, 'tag': ''},
    {'name': 'Classifieds', 'icon': Icons.shopping_bag_rounded, 'tag': ''},
    {'name': 'Grocery', 'icon': Icons.local_grocery_store_rounded, 'tag': ''},
    {'name': 'Courier', 'icon': Icons.local_shipping_rounded, 'tag': ''},
    {'name': 'Services', 'icon': Icons.handyman_rounded, 'tag': ''},
    {'name': 'More', 'icon': Icons.apps_rounded, 'tag': ''},
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkOrange = Color(0xFFCC5500);
    const Color primaryLightOrange = Color(0xFFFF8C00);
    const Color bgColor = Color(0xFFF4F6F8);
    const Color darkSlate = Color(0xFF0F172A);

    // Convert real vendors to Shop objects for display
    List<Shop> displayedShops = _vendors.map((vendor) {
      // Parse rating safely
      double rating = 0.0;
      try {
        if (vendor['rating'] != null) {
          rating = double.parse(vendor['rating'].toString());
        }
      } catch (e) {
        print('Error parsing rating: $e');
      }
      
      // Combine city and shop address for location
      String location = '';
      if (vendor['shopAddress'] != null && vendor['shopAddress'].toString().isNotEmpty) {
        location = vendor['shopAddress'].toString();
        if (vendor['city'] != null && vendor['city'].toString().isNotEmpty) {
          location += ', ${vendor['city']}';
        }
      } else if (vendor['city'] != null) {
        location = vendor['city'].toString();
      }
      
      // Get vendor profile image
      String imageUrl = '';
      if (vendor['profileImage'] != null && vendor['profileImage'].toString().isNotEmpty) {
        final img = vendor['profileImage'].toString();
        if (img.startsWith('http')) {
          imageUrl = img;
        } else if (img.startsWith('/')) {
          imageUrl = 'http://localhost:5000$img';
        } else {
          imageUrl = 'http://localhost:5000/$img';
        }
      }
      
      return Shop(
        id: vendor['id'].toString(),
        name: vendor['businessName'] ?? 'Shop',
        category: vendor['businessType'] ?? 'General',
        imageUrl: imageUrl,
        deliveryTime: '20-30 mins',
        distance: location,
        phone: vendor['phone'] ?? '',
        rating: rating,
        productCount: vendor['totalProducts'] ?? 0,
      );
    }).toList();
    
    print('=== Displaying ${displayedShops.length} shops from ${_vendors.length} vendors ===');

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: primaryDarkOrange,
                expandedHeight: 200.0,
                collapsedHeight: 100.0,
                toolbarHeight: 100.0,
                pinned: true,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryDarkOrange, primaryDarkOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                title: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Nafaj in',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 0.3,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '15 minutes',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Icon(
                                    Icons.flash_on_rounded,
                                    color: const Color(0xFFFFD700),
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            InkWell(
                              onTap: _showAddressDialog,
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      userAddress,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.95),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.25),
                                  Colors.black.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Color(0xFFFFD700),
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '0 SDG',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0.05),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: Colors.grey[400],
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search "power bank"',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  color: Colors.grey[400],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.mic_rounded,
                              color: primaryDarkOrange,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryDarkOrange, primaryLightOrange],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(0, 2, 0, 16),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final cat = categories[index];
                                final isSelected =
                                    selectedCategory == cat['name'];
                                return GestureDetector(
                                  onTap: () {
                                    if (cat['name'] == 'Jobs') {
                                      Navigator.pushNamed(
                                        context,
                                        '/nafaj_job_portal_selection',
                                      );
                                      return;
                                    }
                                    if (cat['name'] == 'Courier') {
                                      Navigator.pushNamed(
                                        context,
                                        '/delivery_portal',
                                      );
                                      return;
                                    }
                                    Navigator.pushNamed(
                                      context,
                                      '/category_products',
                                      arguments: {
                                        'name': cat['name'],
                                        'icon': cat['icon'],
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 70,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Column(
                                      children: [
                                        Stack(
                                          clipBehavior: Clip.none,
                                          alignment: Alignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 12.0,
                                              ),
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                curve: Curves.fastOutSlowIn,
                                                width: 54,
                                                height: 54,
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.white
                                                            .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        isSelected ? 18 : 16,
                                                      ),
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Colors.white
                                                        : Colors.transparent,
                                                    width: 2,
                                                  ),
                                                  boxShadow: isSelected
                                                      ? [
                                                          BoxShadow(
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.3,
                                                                ),
                                                            blurRadius: 12,
                                                            spreadRadius: 2,
                                                          ),
                                                        ]
                                                      : [],
                                                ),
                                                child: Icon(
                                                  cat['icon'],
                                                  color: isSelected
                                                      ? primaryDarkOrange
                                                      : Colors.white,
                                                  size: isSelected ? 28 : 24,
                                                ),
                                              ),
                                            ),
                                            if (cat['tag'].isNotEmpty)
                                              Positioned(
                                                top: 2,
                                                right: -4,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 3,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.redAccent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    border: Border.all(
                                                      color: Colors.white,
                                                      width: 1.5,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        blurRadius: 4,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Text(
                                                    cat['tag'],
                                                    style:
                                                        GoogleFonts.plusJakartaSans(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: Colors.white,
                                                          letterSpacing: 0.5,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          cat['name'],
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: isSelected
                                                ? FontWeight.w800
                                                : FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildPromoBanner(
                                    'Fresh\nVegetables',
                                    'vegetable.jpg',
                                    const Color(0xFFE8F5E9),
                                    () => Navigator.pushNamed(
                                      context,
                                      '/category_products',
                                      arguments: {
                                        'name': 'Grocery',
                                        'icon':
                                            Icons.local_grocery_store_rounded,
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildPromoBanner(
                                    'Pharmacy\nEssentials',
                                    'pharmacy.jpg',
                                    const Color(0xFFE1F5FE),
                                    () => Navigator.pushNamed(
                                      context,
                                      '/category_products',
                                      arguments: {
                                        'name': 'Pharmacy',
                                        'icon': Icons.medication_rounded,
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildPromoBanner(
                                    'Delivery &\nCourier',
                                    'delivery.jpg',
                                    const Color(0xFFFFF3E0),
                                    () => Navigator.pushNamed(
                                      context,
                                      '/delivery_portal',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildPromoBanner(
                                    'Career &\nJobs',
                                    'jobs.jpg',
                                    const Color(0xFFF3E5F5),
                                    () => Navigator.pushNamed(
                                      context,
                                      '/nafaj_job_portal_selection',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Featured Products Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
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
                    SizedBox(
                      height: 195,
                      child: _isLoadingProducts
                          ? Center(
                              child: CircularProgressIndicator(
                                color: primaryDarkOrange,
                              ),
                            )
                          : _featuredProducts.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_basket_outlined,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'No products available',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _featuredProducts.length,
                                  itemBuilder: (context, index) {
                                    return _buildProductCard(
                                      context,
                                      _featuredProducts[index],
                                    );
                                  },
                                ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                      child: Text(
                        selectedCategory == 'Food'
                            ? 'Popular Shops'
                            : 'Shops: $selectedCategory',
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

              // Popular Shops Section
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: _isLoadingVendors
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(
                              color: primaryDarkOrange,
                            ),
                          ),
                        ),
                      )
                    : displayedShops.isEmpty
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.store_outlined,
                                      size: 60,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No shops available',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final shop = displayedShops[index];
                                return _buildShopCard(context, shop, darkSlate);
                              },
                              childCount: displayedShops.length,
                            ),
                          ),
              ),
            ],
          ),

          // Floating Cart Bar
          _buildFloatingCartBar(),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: NafajBottomNav(currentIndex: 0, onTap: (index) {}),
            ),
          ),
        ],
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
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
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
                          print('Image load error for ${product.name}: $error');
                          return Container(
                            height: 110,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryDarkOrange.withOpacity(0.1),
                                  primaryDarkOrange.withOpacity(0.05),
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_bag_rounded,
                                  color: primaryDarkOrange,
                                  size: 35,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'No Image',
                                  style: TextStyle(
                                    color: Colors.grey[600],
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
                              primaryDarkOrange.withOpacity(0.1),
                              primaryDarkOrange.withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_rounded,
                              color: primaryDarkOrange,
                              size: 35,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'No Image',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 6),
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
    // Get business type icon
    IconData getBusinessIcon(String category) {
      switch (category.toLowerCase()) {
        case 'pharmacy':
        case 'retail':
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

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening ${shop.name}'),
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
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop Image/Icon Container
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  // Vendor Image or Gradient Background
                  Positioned.fill(
                    child: shop.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              shop.imageUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFFF8C00).withOpacity(0.15),
                                        const Color(0xFFCC5500).withOpacity(0.25),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      strokeWidth: 2,
                                      color: const Color(0xFFCC5500),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to gradient + icon if image fails
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFFF8C00).withOpacity(0.15),
                                        const Color(0xFFCC5500).withOpacity(0.25),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 15,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        getBusinessIcon(shop.category),
                                        size: 50,
                                        color: const Color(0xFFCC5500),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFFF8C00).withOpacity(0.15),
                                  const Color(0xFFCC5500).withOpacity(0.25),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
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
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 15,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      getBusinessIcon(shop.category),
                                      size: 50,
                                      color: const Color(0xFFCC5500),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  // Business Type Badge
                  if (shop.category.isNotEmpty)
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
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          shop.category.toUpperCase(),
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
                  Text(
                    shop.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkSlate,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Rating and Product Count
                  Row(
                    children: [
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.amber[300]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              shop.rating.toStringAsFixed(1),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 10),
                      
                      // Product Count
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCC5500).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFCC5500).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.inventory_2_rounded,
                              size: 14,
                              color: Color(0xFFCC5500),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${shop.productCount} products',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFCC5500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Location
                  if (shop.distance.isNotEmpty)
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
                            shop.distance,
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
                  if (shop.phone.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_rounded,
                          size: 18,
                          color: Color(0xFFCC5500),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          shop.phone,
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
                  
                  // Delivery Time and Action Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.green[300]!,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: Colors.green[700],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              shop.deliveryTime,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: Colors.green[700],
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
                  color: Colors.black.withOpacity(0.3),
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

  Widget _buildPromoBanner(
    String title,
    String assetPath,
    Color bgColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 100,
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: bgColor),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [bgColor.withOpacity(0.95), bgColor.withOpacity(0.0)],
                  stops: const [0.35, 0.7],
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              top: 16,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E293B),
                  height: 1.1,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
