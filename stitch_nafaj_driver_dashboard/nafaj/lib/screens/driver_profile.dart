import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final s = AppStrings.direct(isArabic: localeProvider.isArabic);
    final isAr = localeProvider.isArabic;

    const Color primaryColor = Color(0xFFCC5500);
    const Color bgColor = Color(0xFFFFFBF7);
    const Color darkSlate = Color(0xFF0F172A);
    const Color textGrey = Color(0xFF475569);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
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
                            color: primaryColor.withOpacity(0.12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
                        s.myProfile,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: darkSlate,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.12),
                        ),
                      ),
                      child: const Icon(
                        Icons.settings_rounded,
                        color: darkSlate,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Profile Card ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withOpacity(0.08),
                        primaryColor.withOpacity(0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: primaryColor.withOpacity(0.12)),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: primaryColor, width: 3),
                              color: primaryColor.withOpacity(0.1),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Color(0xFFCC5500),
                              size: 50,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Mohamed Ibrahim',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: darkSlate,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: const Color(0xFF10B981),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            s.verifiedDriver,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+249 912 345 678',
                        style: GoogleFonts.inter(fontSize: 13, color: textGrey),
                      ),
                      const SizedBox(height: 20),
                      // Stats
                      Row(
                        children: [
                          _buildProfileStat(
                            s.rating,
                            '4.9 ★',
                            primaryColor,
                            darkSlate,
                            textGrey,
                          ),
                          _buildStatDivider(primaryColor),
                          _buildProfileStat(
                            s.deliveriesCount,
                            '342',
                            darkSlate,
                            darkSlate,
                            textGrey,
                          ),
                          _buildStatDivider(primaryColor),
                          _buildProfileStat(
                            s.member,
                            isAr ? '8 أشهر' : '8 months',
                            textGrey,
                            darkSlate,
                            textGrey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Vehicle Info ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.two_wheeler_rounded,
                              color: primaryColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            s.vehicleInformation,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkSlate,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              s.edit,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        s.vehicleTypeLabel,
                        isAr ? 'دراجة نارية' : 'Motorcycle',
                        textGrey,
                        darkSlate,
                      ),
                      _buildInfoRow(
                        s.model,
                        'Bajaj Boxer 150',
                        textGrey,
                        darkSlate,
                      ),
                      _buildInfoRow(
                        s.plateNumber,
                        'KRT-2847',
                        textGrey,
                        darkSlate,
                      ),
                      _buildInfoRow(
                        s.licenseExpiry,
                        isAr ? 'ديسمبر 2026' : 'Dec 2026',
                        textGrey,
                        darkSlate,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Personal Information ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor.withOpacity(0.06)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.badge_rounded,
                              color: Color(0xFF10B981),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            s.personalInformation,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkSlate,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        s.fullNameLabel,
                        isAr ? 'محمد إبراهيم حسن' : 'Mohamed Ibrahim Hassan',
                        textGrey,
                        darkSlate,
                      ),
                      _buildInfoRow(
                        s.nationalIdLabel,
                        '****7891',
                        textGrey,
                        darkSlate,
                      ),
                      _buildInfoRow(
                        s.cityLabel,
                        isAr ? 'الخرطوم، السودان' : 'Khartoum, Sudan',
                        textGrey,
                        darkSlate,
                      ),
                      _buildInfoRow(
                        s.joinDate,
                        isAr ? '15 يوليو 2025' : 'July 15, 2025',
                        textGrey,
                        darkSlate,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Quick Actions ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.quickActions,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkSlate,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActionTile(
                      Icons.history_rounded,
                      s.deliveryHistory,
                      s.viewAllPastDeliveries,
                      const Color(0xFF10B981),
                      darkSlate,
                      textGrey,
                      () {
                        Navigator.pushNamed(
                          context,
                          '/driver_delivery_history',
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildActionTile(
                      Icons.account_balance_wallet_rounded,
                      s.walletAndPayments,
                      s.checkBalanceSettlements,
                      primaryColor,
                      darkSlate,
                      textGrey,
                      () {
                        Navigator.pushNamed(context, '/driver_wallet');
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildActionTile(
                      Icons.support_agent_rounded,
                      s.supportAction,
                      s.getHelpFromTeam,
                      const Color(0xFF3B82F6),
                      darkSlate,
                      textGrey,
                      () {
                        Navigator.pushNamed(context, '/live_support_chat');
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildActionTile(
                      Icons.description_rounded,
                      s.documents,
                      s.manageDocuments,
                      const Color(0xFF8B5CF6),
                      darkSlate,
                      textGrey,
                      () {},
                    ),
                    const SizedBox(height: 8),
                    _buildActionTile(
                      Icons.logout_rounded,
                      s.logOut,
                      s.signOutAccount,
                      const Color(0xFFEF4444),
                      darkSlate,
                      textGrey,
                      () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/driver_login',
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),

      // ── Bottom Nav ──
      bottomNavigationBar: _buildDriverBottomNav(context, 3, s, isAr),
    ), // Scaffold
    ); // Directionality
  }

  Widget _buildProfileStat(
    String label,
    String value,
    Color valueColor,
    Color darkSlate,
    Color textGrey,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: textGrey)),
        ],
      ),
    );
  }

  Widget _buildStatDivider(Color primaryColor) {
    return Container(
      width: 1,
      height: 36,
      color: primaryColor.withOpacity(0.12),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    Color textGrey,
    Color darkSlate,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: textGrey)),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: darkSlate,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    Color darkSlate,
    Color textGrey,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCC5500).withOpacity(0.06)),
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
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
                      color: darkSlate,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 12, color: textGrey),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: textGrey, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverBottomNav(BuildContext context, int currentIndex, AppStrings s, bool isAr) {
    const Color primaryColor = Color(0xFFCC5500);
    const Color inactiveGrey = Color(0xFF94A3B8);

    final items = [
      {
        'icon': Icons.map_rounded,
        'label': s.navMap,
        'route': '/driver_dashboard_animated_3d',
      },
      {
        'icon': Icons.format_list_bulleted_rounded,
        'label': s.navHistory,
        'route': '/driver_delivery_history',
      },
      {
        'icon': Icons.account_balance_wallet_rounded,
        'label': s.navWallet,
        'route': '/driver_wallet',
      },
      {
        'icon': Icons.person_rounded,
        'label': s.navProfile,
        'route': '/driver_profile',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: primaryColor.withOpacity(0.08))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
            children: List.generate(items.length, (index) {
              final isActive = index == currentIndex;
              return GestureDetector(
                onTap: () {
                  if (!isActive) {
                    Navigator.pushReplacementNamed(
                      context,
                      items[index]['route'] as String,
                    );
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: isActive
                      ? BoxDecoration(
                          color: primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[index]['icon'] as IconData,
                        color: isActive ? primaryColor : inactiveGrey,
                        size: 24,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[index]['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isActive ? primaryColor : inactiveGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
