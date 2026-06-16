import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'nafaj_marketplace_home.dart' show Shop, Product;
import '../services/cart_service.dart';
import '../constants.dart';

class NafajShopDetailsScreen extends StatefulWidget {
  final Shop shop;

  const NafajShopDetailsScreen({super.key, required this.shop});

  @override
  State<NafajShopDetailsScreen> createState() => _NafajShopDetailsScreenState();
}

class _NafajShopDetailsScreenState extends State<NafajShopDetailsScreen> {
  final CartService _cartService = CartService();

  void _incrementQuantity(Product product) {
    _cartService.addItem(product.toCartProduct());
  }

  void _decrementQuantity(String productId) {
    _cartService.removeItem(productId);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkOrange = Color(0xFFCC5500);
    const Color bgColor = Color(0xFFF4F6F8);
    const Color darkSlate = Color(0xFF0F172A);
    return ListenableBuilder(
      listenable: _cartService,
      builder: (context, _) {
        final bool showCart = _cartService.items.isNotEmpty;

        return Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: primaryDarkOrange,
                    expandedHeight: 200.0,
                    pinned: true,
                    iconTheme: const IconThemeData(color: Colors.white),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            widget.shop.imageUrl,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.8),
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: AppConstants.paddingLarge,
                            right: AppConstants.paddingLarge,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.shop.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryDarkOrange,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        widget.shop.category,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.timer_rounded,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            widget.shop.deliveryTime,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
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
                  ),

                  // Contact Details - Compressed
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingLarge,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.phone_rounded,
                                color: primaryDarkOrange,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.shop.phone,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: darkSlate,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            color: Colors.grey[300],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: primaryDarkOrange,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.shop.distance} away',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: darkSlate,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // Products Grid Header
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'All Products',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: darkSlate,
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // Products Grid - Dense Layout
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        // Using a set of items for display, in a real app these come from a repository
                        final List<Product> shopProducts = [
                          Product(
                            id: 'p1',
                            name: 'Parachute Coconut Oil',
                            price: '185',
                            qantity: '300 ml',
                            imageUrl:
                                'https://images.unsplash.com/photo-1620916297397-a4a5402a3c6c?auto=format&fit=crop&q=80',
                            vendorId: 1,
                          ),
                          Product(
                            id: 'p2',
                            name: 'Maggi Masala Noodles',
                            price: '58',
                            qantity: '300 g',
                            imageUrl:
                                'https://images.unsplash.com/photo-1612929633738-8fe01f72810c?auto=format&fit=crop&q=80',
                            vendorId: 1,
                          ),
                          Product(
                            id: 'p3',
                            name: 'Kurkure Masala Munch',
                            price: '54',
                            qantity: '75 g',
                            imageUrl:
                                'https://images.unsplash.com/photo-1599508704512-2f19efd1e35f?auto=format&fit=crop&q=80',
                            vendorId: 1,
                          ),
                          Product(
                            id: 'p4',
                            name: 'Fresh Red Apples',
                            price: '220',
                            qantity: '1 kg',
                            imageUrl:
                                'https://images.unsplash.com/photo-1560806887-1e4cd0b6fac6?auto=format&fit=crop&q=80',
                            vendorId: 1,
                          ),
                          Product(
                            id: 'p5',
                            name: 'Lays Classic Salted',
                            price: '30',
                            qantity: '50 g',
                            imageUrl:
                                'https://images.unsplash.com/photo-1566478989037-eade3860fb7f?auto=format&fit=crop&q=80',
                            vendorId: 1,
                          ),
                          Product(
                            id: 'p6',
                            name: 'Almarai Fresh Milk',
                            price: '120',
                            qantity: '1 L',
                            imageUrl: 'milk.png',
                            vendorId: 1,
                          ),
                        ];

                        final product = shopProducts[index];
                        final int qty = _cartService.getProductQuantity(
                          product.id,
                        );

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 110,
                                width: double.infinity,
                                color: Colors.white,
                                padding: const EdgeInsets.all(8),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: product.imageUrl.startsWith('http')
                                          ? Image.network(
                                              product.imageUrl,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey,
                                                  ),
                                            )
                                          : Image.asset(
                                              product.imageUrl,
                                              fit: BoxFit.contain,
                                            ),
                                    ),
                                    if (qty > 0)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: primaryDarkOrange,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            'x$qty',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Details
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    8,
                                    10,
                                    10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: darkSlate,
                                              height: 1.2,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            product.qantity,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              color: Colors.grey[500],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${product.price} SDG',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: darkSlate,
                                            ),
                                          ),
                                          qty == 0
                                              ? GestureDetector(
                                                  onTap: () =>
                                                      _incrementQuantity(
                                                        product,
                                                      ),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 14,
                                                          vertical: 6,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            primaryDarkOrange,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                      color: Colors.white,
                                                    ),
                                                    child: Text(
                                                      'ADD',
                                                      style:
                                                          GoogleFonts.plusJakartaSans(
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                primaryDarkOrange,
                                                          ),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  decoration: BoxDecoration(
                                                    color: primaryDarkOrange,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () =>
                                                            _decrementQuantity(
                                                              product.id,
                                                            ),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 6,
                                                                vertical: 4,
                                                              ),
                                                          child: Icon(
                                                            Icons.remove,
                                                            color: Colors.white,
                                                            size: 16,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        '$qty',
                                                        style:
                                                            GoogleFonts.plusJakartaSans(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () =>
                                                            _incrementQuantity(
                                                              product,
                                                            ),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 6,
                                                                vertical: 4,
                                                              ),
                                                          child: Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                            size: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }, childCount: 6),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.only(bottom: showCart ? 120 : 30),
                  ),
                ],
              ),

              // Premium Orange Floating Cart Bottom Bar
              if (showCart)
                Positioned(
                  bottom: 30,
                  left: AppConstants.paddingLarge,
                  right: AppConstants.paddingLarge,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/checkout_screen');
                    },
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: primaryDarkOrange,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: primaryDarkOrange.withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Overlapping Circular Product Icons
                          SizedBox(
                            width:
                                (_cartService.items.length > 3
                                        ? 3
                                        : _cartService.items.length) *
                                    25.0 +
                                35.0,
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: List.generate(
                                _cartService.items.length > 3
                                    ? 3
                                    : _cartService.items.length,
                                (index) {
                                  final item = _cartService.items[index];
                                  return Positioned(
                                    left: index * 25.0,
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: primaryDarkOrange,
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: Image.network(
                                          item.product.imageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ).reversed.toList(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Text and Amount
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'View cart',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                Text(
                                  '${_cartService.totalItems} ITEM${_cartService.totalItems > 1 ? 'S' : ''} • SDG ${_cartService.subtotal.toStringAsFixed(0)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Chevron
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
