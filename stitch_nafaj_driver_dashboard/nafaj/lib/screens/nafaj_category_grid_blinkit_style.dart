import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/nafaj_bottom_nav.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';

class NafajCategoryGridBlinkitStyleScreen extends StatelessWidget {
  const NafajCategoryGridBlinkitStyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFCC5500);
    final locale = Provider.of<LocaleProvider>(context);
    final s = AppStrings.direct(isArabic: locale.isArabic);

    return Directionality(
      textDirection: locale.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 48, 16, 32),
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.deliveringToLabel,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.7),
                                    letterSpacing: 1,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      locale.isArabic
                                          ? 'الخرطوم، حي الرياض'
                                          : 'Khartoum, Al Riyadh District',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.expand_more_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.speed_rounded,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      s.minutesDelivery,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _iconBtn(Icons.account_balance_wallet_rounded),
                                const SizedBox(width: 12),
                                _iconBtn(Icons.person_rounded),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: s.searchFreshMeatHint,
                                    hintStyle: GoogleFonts.inter(
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.grey[300],
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              const Icon(
                                Icons.mic_rounded,
                                color: primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Grocery & Kitchen Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              s.groceryAndKitchen,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.dailyEssentialsSubtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Grocery Grid
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 8,
                          mainAxisExtent: 130,
                        ),
                    delegate: SliverChildListDelegate([
                      _buildCategoryItem(
                        context,
                        s.catVegetablesFruits,
                        Colors.green[50]!,
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAlJw2BoxvJaENbYJOgdCvcH3vk-EoGjmc3rNJzRQf2TsgSN2Zfg9q0210zJvYP64AsDuyRGSPmFCAjXBZSVDU_6juGxnR_xcY7591zEX7qY32u3OiMNaMxBrIlACy5NUmd_UOueJLP_dKA1jUttM9_RfcpbhzzpfTfKSavpb0ifRfnWP54X3PiMpjvqKRM8iWVx5xEEsNgwzXe1DBhGR1QRxeKPCNHNKXVqq0a_fE-81bLpYMCCJ_sEVOrhyccT0mzGvTyZqbWdng',
                        Icons.grass_rounded,
                      ),
                      _buildCategoryItem(
                        context,
                        s.catRiceDal,
                        Colors.orange[50]!,
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCpDBhLjlx01xgiY-T2JevtdjpphUQSvWcgKEdU_P4T80nJh854zjauqr1ThDic9fwBaye25gZ8XBDye1-n6akWlF81rRgaTmK1-wH6w1FaD2iGaewT-rSYHcS9mnLUVERuM1KLrs-Wn6Q1CNqyLZmgTYWzimMk6uDDa7c-dfsvWa-PyntrteQgf11QCYVtkRUhbqbRXWgY-c5yJ2nksbCZsfLvVhLBmT7b388B5Weowpyg45UCzugUD_QCMWnCrueUggJrKeSCfNc',
                        Icons.rice_bowl_rounded,
                      ),
                      _buildCategoryItem(
                        context,
                        s.catOilGhee,
                        Colors.amber[50]!,
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDFWdGc-_6CSZ7RT0P0qykwDklH1RW5DZFZkFIR1eV-GrQdGRh_Te73xzzWqemjpMcz4XECzEWOOee8Hzr0wI36HxCNKg6SJqKWjFZJjJb5kSR_wcJwb_c_VWut5HoEgFyIAOV1fNCcDfTV7FqOdUL501U7uY9LrNTD5L2drfOwH9Qi5q1kIlt0ipyATDcJHVG05hOmaZAmpzOYiDLcgXJWogbwik8zmXIN811JHX2anZQsFTzne130j5TJ0TH5hNu6rXyVUPQmB-8',
                        Icons.water_drop_rounded,
                      ),
                      _buildCategoryItem(
                        context,
                        s.catDairyEggs,
                        Colors.blue[50]!,
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuC58S3rxjVlxDL7Le3Y2URkpHtLazRAgX0xdaMsGGnb6iT9h75h_HM2xOI8yDC7RU5-dfdBXBOAspljV0-KQR7ch0OVVzbPGMXSsbW_FZzqyCMCHDOJMywKzxiH-zmVO7ge_20rnQZDYTauzp_t-6GZ_y_p57R9h9PogiYsW3awF4hI-joFPsFjlA5MBrLFWYWt7kyDflJ8936N5-ymCjfSXr_WTINBmG1WwcaDVnSQdzziIIAn3hSda2VMhSrmb4q4dYLZ1HidoOM',
                        Icons.egg_rounded,
                      ),
                      _buildCategoryItem(
                        context,
                        s.catBakeryBiscuits,
                        Colors.pink[50]!,
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCK13kUiuqAoFADLK6RLVYpsj_ZuPc0KPt4tOcPulprAF0_aE-TJc4lcu9LOpj-bfwukcRI_Akwb_5vaBYI65waQx1PwJ74lon1p4-9bv1sIcEag1DPQ4r_zeaXDBalMqNAgelyzpedsdQVM_leqpfGPirpn5nuKkWi7yQFJ3FlAWnAba35EmG7wNinQ3AqMo1ej4AnsCf9VKNz4otQkcuAQcW_T4-Bm-vKb2k8U0gCMepk0uYOTa0KRxAARPW3TmtHSC-KkxXlI20',
                        Icons.bakery_dining_rounded,
                      ),
                      _buildCategoryItem(
                        context,
                        s.catSnacksMunchies,
                        Colors.yellow[50]!,
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDelqSy4EkDv9ZTZ3llumQknxvr6kf8-9m3rD-XX6C5ECPDXltG5KjkkJIaeFR8eSNlZJV0BspTj8dX2KeoNIsi5BXWAkTvAr4r5pW8rz7B8Fbl8W1DYY5d8rXStPCvXFJkcjXBLt_bwNVDBxfSl6h-KF1ZMskEqvSWByAYVxyIIdY6pPILuAb2op-6xh_IV4y-k_NUaRdvxoma7fFw_jCv66A3RDOo2P9xbmnFdFUmY_OpA-9FGeH2l_hpkP3jUodCl_l1O-U2sds',
                        Icons.lunch_dining_rounded,
                      ),
                      _buildCategoryItem(
                        context,
                        s.catChickenMeat,
                        Colors.red[50]!,
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuArpIo1WGzgR4mW72Gr0cGRD4RNnKnuyJy2_cA7eKhIyiDEDwvYx3uPSMbNrAWr3QRXmrsdetuCx2j8RvFTaBZAvq_buNi9mhty54tZmhZFWPo7U0DVMOoLT0HdMfq5OVOByePz1Gl02jPQn3Ye4omEYoB3VjJ-i1Ub7UEFD0dCrL-TEuIRVHxx3NMDZdKlXo0BJpdS7xgWHZXqEDC62-EEGyI1oPAsPvwtGLP13QcmWlOcUnaPfyOKJH7HP0nOv7eLoKhWXLxeEz8',
                        Icons.set_meal_rounded,
                      ),
                      _buildCategoryItem(
                        context,
                        s.catKitchenware,
                        Colors.indigo[50]!,
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBP-ODKr6i6LoOjhb4_N8EAkobg9xwPGqD_b0Oza_igJtQpVbUgG6S7cdTxsBVKPwDfI0NhbVpDykz5q4RUpH-R0gETg6Y_kCg_6o-9cnGX2r_odNGKDw4_De58PEMybrPFloE6sSLKyAPkb7xBZqpOGgFAeQLQ_6C3EYIQD1xJ68NWaLthheQ_D44kbZKUl6U5LgT1shRb7GaZRoUyn2CxJbOnT-nzWkzk9bEjG9-YSM95IwKNjeAa_bVu66AO1Gqr0n81VSb9n7k',
                        Icons.kitchen_rounded,
                      ),
                    ]),
                  ),
                ),

                // Snacks & Drinks Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              s.snacksAndDrinks,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.sudaneseFavoritesSubtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Promo Cards
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildPromoCard(
                          context,
                          s.promoSudaneseCoffee,
                          [
                            const Color(0xFFCC5500),
                            const Color(0xFFE67E22),
                          ],
                          Icons.local_cafe_rounded,
                          primaryColor,
                          s,
                        ),
                        const SizedBox(width: 12),
                        _buildPromoCard(
                          context,
                          s.promoHibiscusJuices,
                          [Colors.indigo[500]!, Colors.purple[600]!],
                          Icons.liquor_rounded,
                          Colors.indigo[600]!,
                          s,
                        ),
                        const SizedBox(width: 12),
                        _buildPromoCard(
                          context,
                          s.promoQuickOrderSend,
                          [Colors.teal[500]!, Colors.green[600]!],
                          Icons.local_shipping_rounded,
                          Colors.teal[600]!,
                          s,
                          routeName: '/quick_order_package_details',
                        ),
                      ],
                    ),
                  ),
                ),

                // Snacks Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 8,
                          mainAxisExtent: 130,
                        ),
                    delegate: SliverChildListDelegate([
                      _buildCategoryItem(
                        context,
                        s.catChipsNamkeen,
                        Colors.grey[50]!,
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuCZgQ-DBjfLtONTxHcrnO55VWKQPp2M4yfJrTK3l7oY7W74qZfIDBk-zBa9RvbZDXqijFvS2jj8t0j3Uz1vBB0uLuOttPnfl0Yxk2CUZbJZqHVAw139-Td7RVjkBYCTgJcRMPX-YsN4H5jeg_hDsoEN1vctBwDLwvl6VcgNO0A-CqnnTdFkTyt0GH8wenwliR3ooQ_Zo4eq8KlQT7Tp4V3j5o3XMWBZjyooEvczc9Q8gqSl2BOabS6jHF-X4Q_AzmMuH6ENN4nvX84',
                        Icons.fastfood_rounded,
                      ),
                      _buildCategoryItem(
                        context,
                        s.catSweetsChocolates,
                        Colors.grey[50]!,
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDCPc6r5-SzzFX3luwYjElU_iAK60fL2sfLVU-nitLXW3xPj2h6ewlN0-MOQ5pqOOp0usHqlyI55MTQLK3zmHqkDDxZnWBUjC8TcoqAeARYida7rTDKHcyoqKTRbPuuklD54pxsNzeVF56mrpoCpDjrVal33ECMCMEMkC1zrlmEixXVdGsNM-rP0RJHJ2Xit5KeDEL1enQuV2tW1inuBx-jTcktdR1HHoOK1c4A2nVKGKQPJfmr5A4EQUA4KQatScxzkf0ymOLYhUk',
                        Icons.cake_rounded,
                      ),
                      _buildCategoryItem(
                        context,
                        s.catDrinksJuices,
                        Colors.grey[50]!,
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDWpyOKh88LDuDX-KttAfb3PBF8hMSh9EmoR9UiqpBQbmnp2qbTgmBOsYCBPqlTzFGt_PYYOX1juNg77RkLKwCbqvNRac-lsxrZFV4J-DNayu9rvNXc8OGo4YuQYexv2ejaJDavuieMyX-QUrgSXJ-Z0HL8EnA2NZK9piqrzhFYd7KtKIKc2eLJvefJI7Dl3TUUrdnocJDpRPCiYZUoWlOigt1mtlMKL0FXlS_suBB9QQm0diaI6nQMAKSJKFAHTjW0jlfR1RMYc5o',
                        Icons.local_drink_rounded,
                      ),
                      _buildCategoryItem(
                        context,
                        s.catTeaCoffee,
                        Colors.grey[50]!,
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAHDpFkz2-4rFwM7owBWOIjGxi3xIvu7Z-sk1SCnai39jQsAQb4zMN6zTUMrlpRCqGUAWbnf1UUmzgfuJx5izG1r-fyZTp9TIHlCXpbuvzy1kXuO-jURKxNGbCDjFwt90a7rN_BBJG-D_lV7NP2IJdlvN1IyoTuMckNL5VihyMnJkhERNoX8ZCjxDjIlMMijGsx3dCJ8m6ON1qmVgtaFSGGOlplT1RFWojhl5Qlc29QccWtw0U_iQ_t94LcuraVRjJxUkrT7F0DI8g',
                        Icons.coffee_rounded,
                      ),
                    ]),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),

            // Floating Cart Button
            Positioned(
              bottom: 96,
              right: 24,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/checkout_screen'),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Center(
                        child: Icon(
                          Icons.shopping_bag_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryColor, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '0',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: NafajBottomNav(
          currentIndex: 2,
          onTap: (index) {},
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String title,
    Color bgColor,
    String imgUrl,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/category_products',
        arguments: {'name': title, 'icon': icon},
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imgUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Icon(icon, size: 40, color: const Color(0xFFCC5500)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(
    BuildContext context,
    String title,
    List<Color> gradients,
    IconData icon,
    Color textColor,
    AppStrings s, {
    String? routeName,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        routeName ?? '/product_feed_orange_header',
      ),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradients,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Icon(icon, size: 60, color: Colors.white.withOpacity(0.3)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    s.exploreNow,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
