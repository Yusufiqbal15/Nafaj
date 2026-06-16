import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

class VendorShopTypeScreen extends StatefulWidget {
  const VendorShopTypeScreen({super.key});

  @override
  State<VendorShopTypeScreen> createState() => _VendorShopTypeScreenState();
}

class _VendorShopTypeScreenState extends State<VendorShopTypeScreen> {
  int _selectedType = -1;
  final Set<int> _selectedProducts = {};

  final List<Map<String, dynamic>> _shopTypes = [
    {
      'icon': Icons.restaurant_rounded,
      'label': 'Restaurant',
      'desc': 'Food & beverages',
    },
    {
      'icon': Icons.local_grocery_store_rounded,
      'label': 'Grocery',
      'desc': 'Daily essentials',
    },
    {
      'icon': Icons.local_pharmacy_rounded,
      'label': 'Pharmacy',
      'desc': 'Medicine & health',
    },
    {
      'icon': Icons.shopping_bag_rounded,
      'label': 'Fashion',
      'desc': 'Clothes & accessories',
    },
    {
      'icon': Icons.devices_rounded,
      'label': 'Electronics',
      'desc': 'Gadgets & devices',
    },
    {
      'icon': Icons.home_rounded,
      'label': 'Home & Living',
      'desc': 'Furniture & decor',
    },
    {'icon': Icons.spa_rounded, 'label': 'Beauty', 'desc': 'Cosmetics & care'},
    {
      'icon': Icons.more_horiz_rounded,
      'label': 'Other',
      'desc': 'Custom category',
    },
  ];

  final List<String> _productCategories = [
    'Fast Food',
    'Traditional Food',
    'Beverages',
    'Desserts',
    'Fresh Produce',
    'Packaged Food',
    'Dairy Products',
    'Bakery',
    'Medicines',
    'Health Supplements',
    'Men\'s Wear',
    'Women\'s Wear',
    'Kids Items',
    'Mobile Phones',
    'Laptops',
    'Home Appliances',
    'Cleaning Products',
    'Personal Care',
    'Organic Products',
    'Snacks',
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFCC5500);
    const Color bgColor = Color(0xFFFFFBF7);
    const Color darkSlate = Color(0xFF0F172A);
    const Color textGrey = Color(0xFF475569);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.15),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: darkSlate,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Shop Setup',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkSlate,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Shop type header
                    Text(
                      'What type of shop\ndo you have?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: darkSlate,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select the category that best describes your business',
                      style: GoogleFonts.inter(fontSize: 14, color: textGrey),
                    ),
                    const SizedBox(height: 24),

                    // Shop type grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.45,
                          ),
                      itemCount: _shopTypes.length,
                      itemBuilder: (context, index) {
                        final type = _shopTypes[index];
                        final isSelected = _selectedType == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedType = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : primaryColor.withValues(alpha: 0.1),
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: primaryColor.withValues(alpha: 0.2),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : primaryColor.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    type['icon'],
                                    color: isSelected
                                        ? Colors.white
                                        : primaryColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  type['label'],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : darkSlate,
                                  ),
                                ),
                                Text(
                                  type['desc'],
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Product categories
                    Text(
                      'What products do you sell?',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkSlate,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select all that apply',
                      style: GoogleFonts.inter(fontSize: 13, color: textGrey),
                    ),
                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_productCategories.length, (
                        index,
                      ) {
                        final isChipSelected = _selectedProducts.contains(
                          index,
                        );
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isChipSelected) {
                                _selectedProducts.remove(index);
                              } else {
                                _selectedProducts.add(index);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isChipSelected
                                  ? primaryColor
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isChipSelected
                                    ? primaryColor
                                    : primaryColor.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isChipSelected) ...[
                                  const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  _productCategories[index],
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isChipSelected
                                        ? Colors.white
                                        : darkSlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 30),

                    // Shop Description
                    Text(
                      'Describe your shop',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkSlate,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        maxLines: 4,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: darkSlate,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Tell customers what makes your shop special...',
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xFFADB5BD),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: primaryColor.withValues(alpha: 0.12),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: primaryColor.withValues(alpha: 0.12),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: primaryColor.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Upload Shop Logo
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.15),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.add_a_photo_rounded,
                              color: primaryColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Upload Shop Logo',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkSlate,
                            ),
                          ),
                          Text(
                            'PNG or JPG, max 5MB',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // ── Bottom Button ──
            Container(
              padding: const EdgeInsets.fromLTRB(AppConstants.paddingLarge, 12, AppConstants.paddingLarge, 20),
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
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/vendor_dashboard');
                },
                child: Container(
                  height: 54,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFCC5500), Color(0xFFE67322)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Go to Dashboard',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.dashboard_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
