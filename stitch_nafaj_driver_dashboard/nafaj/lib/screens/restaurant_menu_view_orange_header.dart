import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/nafaj_bottom_nav.dart';

class RestaurantMenuViewOrangeHeaderScreen extends StatelessWidget {
  const RestaurantMenuViewOrangeHeaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFCC5500);
    const Color bgColor = Color(0xFFF6F8F7);
    const Color darkSlate = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Sticky Header navigation
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  minHeight: 100,
                  maxHeight: 120,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildHeaderBtn(Icons.arrow_back_rounded, context),
                        Image.asset('logo.png', height: 44),
                        _buildHeaderBtn(Icons.search_rounded, null),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Rated Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Top Rated in Sudan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: darkSlate,
                            ),
                          ),
                          Text(
                            'See All',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 240,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildTopRatedCard(
                            name: 'Al-Housh Restaurant',
                            rating: '4.8',
                            desc: 'Authentic Sudanese Flavors',
                            time: '25-35 min',
                            distance: '1.2 km',
                            imageUrl:
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuA_whSrpd56Joxmk8K0YOm0oz1c1CGMeWKfSs6TbtmqomDbgKKPQF3cjzAuGBS-G1u6RL5y_FSDUcpSMIdYxkLO-Cs1bHs4Srb_-IrSzosqhqBca8l0uzV7Ab_bU76VabYXKx0sQafjxw3r1gucG0sdXrL_i2Z3wOC1mPM3hu2aH6w_c3GOF8toMDgCBgOnCcq0iMb8ukP0w0rBWXqtFrDpUrj6MXGHhd2PumfqQ1R9WPzkokxDwA_kxcDaLHVW1CH7qzJFx7wi3-4',
                            primaryColor: primaryColor,
                          ),
                          const SizedBox(width: 16),
                          _buildTopRatedCard(
                            name: 'Oasis Cafe',
                            rating: '4.5',
                            desc: 'Coffee & Quick Bites',
                            time: '15-25 min',
                            distance: '0.8 km',
                            imageUrl:
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuAwTWEsB--nOUJr2HxQXcYx3lrR-kJq9oW1WbcE3Ho-eEBBPnDkWzgU27hqLcE-VS4zMdWw2clweUN-Dgh1QofgLxut3t5JPGgZLjAxXqcsgMGEloGusZC-hr_E84D2LZJ-TinW7p5xZ07F4-iK9Uwj8pz_Ex3dRq6P665UVcyWRUeTZg50_Z8-irx7Ylwr6HCptpAagsGN-EG6bYRB_srL39DyIW4qwpEsPBA2y7vHpVdHP2ap8wASYYgCb5BZKForEctxrd6suMo',
                            primaryColor: primaryColor,
                          ),
                        ],
                      ),
                    ),

                    // Specific Restaurant Menu Banner
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        height: 192,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuCMudVF58wcyAQPtLvECKGfoSimUD4qH0KDssk56I8oUS4tzIV0x7CrV9e--PO1pyb0nS7yj6brHu2dXq0-nmufOd7yodxvh6nj-Ei_xRaHu45-tKbnYhaFX-_YSg2HzI3-KSeZukQ7VEkvvkyBjYIxvP1XEgI547S9E7onz86P12YFaYKL7MSsIj9W8EkYrlNAsJKPHtmmeOPvY6vsJ14Mo5G0l7k0nKBHmEbik74Z2oJEsfQmE06zLNBlEI0a9gGPfAeDkdZ3sR0',
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sudanese Flavors',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Open until 11:00 PM • Khartoum Central',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Sticky Tabs
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  minHeight: 60,
                  maxHeight: 60,
                  child: Container(
                    color: bgColor,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildTab('Appetizers', true, primaryColor),
                        const SizedBox(width: 8),
                        _buildTab('Main Course', false, primaryColor),
                        const SizedBox(width: 8),
                        _buildTab('Drinks', false, primaryColor),
                        const SizedBox(width: 8),
                        _buildTab('Desserts', false, primaryColor),
                      ],
                    ),
                  ),
                ),
              ),

              // Menu Items List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 160),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildMenuItem(
                      title: 'Sudanese Falafel (Ta\'miya)',
                      desc:
                          'Traditional spiced chickpea patties served with tahini sauce and fresh bread.',
                      price: '1,200',
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBhcXouYc0jxB8bFwYj34ITZnj4Z-y1n3F4n1QmAzT7Zb7SGzgfhsdcMfbf_1osF94i6JRJppclQsN-XpqGscMT8p3whFmX3-uyPGW6jsDYm0P1ncq-NvCpL0uJ1CPdSSH5146nFAlIQW6hF083LxjjPl2-zx3tLzBZVkGVKV4hyMP8x7zk9U2_VQyeFELz6mYNcUcanvdb2a25ZOVudVmC_IKPsXEQrrIhaG20LfKuy29DtVVnoqV00AbCbxUA0pemD15Nkxd-j4o',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      title: 'Ful Medames',
                      desc:
                          'Slow-cooked fava beans with olive oil, cumin, and garnished with chopped parsley.',
                      price: '1,800',
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBwQEVy_lY6-fxVBGxuRmskrIbfsvggLeFiM0v18yXBWgCO383-_HYpHSk0_JxjoFrk5bY_kClPW9bBExfPUxQiQIePe5i02vAfgOqoMicFlsqhfg2D6hjJhrXABD6t3hMJz8CYxeiJB1gjD2giy-_7PxQFpTRUxBZEZsgEZERvqy2MjdC8d_5Y6-xQrBmIQRWd3-LF7QAhqwjYZ7NZlBNUA77DsrqqlmhI5veKen1762ACGQ-IeY_NxvfyV5sQ_NQ34gyYvnUvUgg',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      title: 'Sambousek Platter',
                      desc:
                          'Mixed pastry triangles filled with minced meat and local cheese.',
                      price: '2,500',
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuB3UAz81CIw0O1Tx06WG-chk4Tg_xSzTqU8l0qg-WnKNufu8D-wj6DXVhzeA-U6Ip1HEu0Tw9pXmpBm6pJ_cwcBuCAdAWSgmuPpRTFBAglFr6OtR3-NA7jWXALvL0LCE3zhaNil1vSSeohm1SFdVGLWe9qr8VrQlC5NzIvOXDPALySfOZOJCCkcKi1SCBMAsRxRboXJREyg77Edq2t7y23Kpm-bTWXvw64FalgEvOXQJnsprBhoC46gHTpiL7xAnY1y6kPncKWY2Q4',
                      primaryColor: primaryColor,
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // Floating Cart Button
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: primaryColor.withOpacity(0.6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '2 Items',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'View Cart',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '3,000 SDG',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Nav Bar
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

  Widget _buildHeaderBtn(IconData icon, BuildContext? context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: () {
          if (context != null) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Widget _buildTopRatedCard({
    required String name,
    required String rating,
    required String desc,
    required String time,
    required String distance,
    required String imageUrl,
    required Color primaryColor,
  }) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(imageUrl, height: 120, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            rating,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      distance,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF94A3B8),
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

  Widget _buildTab(String label, bool isSelected, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      // alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isSelected ? null : Border.all(color: Colors.grey[200]!),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String desc,
    required String price,
    required String imageUrl,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$price SDG',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
