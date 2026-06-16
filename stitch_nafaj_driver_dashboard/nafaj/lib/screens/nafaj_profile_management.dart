import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/nafaj_bottom_nav.dart';
import '../constants.dart';

class NafajProfileManagementScreen extends StatelessWidget {
  const NafajProfileManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFCC5500);
    const Color darkSlate = Color(0xFF0F172A);
    const Color bgColor = Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // Hero Header
          SliverAppBar(
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: darkSlate,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Decorative background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [darkSlate, Color(0xFF1E293B)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Profile Content
                  SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  image: const DecorationImage(
                                    image: NetworkImage(
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDpRbB1CJ4MUc1BEubKPL5pI5hkSHKCc9nGAaRA3Day_pWtdhsm75mxo4xpXrypzNrywL2nG6zIMar_Jo427N8DuEJ90R1YjcE0IJ2KODxS3o-MBV04YsVPHrG4qLcNUvTVRzWlqUX33TBqU3U5A3hUEYRrc5TW94EA4XvJSuxZVkZUI-luNTJjjilgYx5uYj9sUF1ab3j3SUU8A8LI6FbaLke_bbcVsBHZSNAwpL_vWqe1XWKdUVLU4MaKWu6b2NTRE7hJMXD-KQM',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Ahmed Ibrahim',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  color: primaryColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'PLATINUM MEMBER',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: primaryColor,
                                    letterSpacing: 1,
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
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                child: Column(
                  children: [
                    // Wallet Card
                    _buildWalletCard(context, primaryColor, darkSlate),

                    const SizedBox(height: 24),

                    // Stats Grid
                    Row(
                      children: [
                        _buildStatBox(
                          'Orders',
                          '24',
                          Icons.receipt_long_rounded,
                          Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _buildStatBox(
                          'Jobs',
                          '08',
                          Icons.work_rounded,
                          Colors.purple,
                        ),
                        const SizedBox(width: 12),
                        _buildStatBox(
                          'Points',
                          '1.2k',
                          Icons.stars_rounded,
                          Colors.amber,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Navigation Groups
                    _buildGroupHeader('Personal Management'),
                    _buildMenuItem(
                      Icons.person_outline_rounded,
                      'Personal Information',
                      'Edit name, phone, email',
                    ),
                    _buildMenuItem(
                      Icons.location_on_outlined,
                      'Saved Addresses',
                      'Home, Office, Other locations',
                    ),
                    _buildMenuItem(
                      Icons.notifications_none_rounded,
                      'Notifications',
                      'Updates, Promos, Alerts',
                    ),

                    const SizedBox(height: 24),

                    _buildGroupHeader('Financial'),
                    _buildMenuItem(
                      Icons.account_balance_wallet_outlined,
                      'Nafaj Wallet',
                      'Balance: SDG 25,500',
                    ),
                    _buildMenuItem(
                      Icons.payment_rounded,
                      'Payment Methods',
                      'Cards, Bankak, Vouchers',
                    ),

                    const SizedBox(height: 24),

                    _buildGroupHeader('Security & More'),
                    _buildMenuItem(
                      Icons.security_rounded,
                      'Security Settings',
                      'Password, Biometrics',
                    ),
                    _buildMenuItem(
                      Icons.help_outline_rounded,
                      'Help & Support',
                      'FAQs, Contact us, Terms',
                    ),
                    _buildMenuItem(
                      Icons.info_outline_rounded,
                      'About Nafaj',
                      'Version 2.4.0',
                    ),

                    const SizedBox(height: 32),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: TextButton.icon(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/nafaj_phone_login_screen',
                        ),
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.redAccent,
                        ),
                        label: Text(
                          'LOGOUT ACCOUNT',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.redAccent.withValues(alpha: 0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NafajBottomNav(currentIndex: 4, onTap: (index) {}),
    );
  }

  Widget _buildWalletCard(
    BuildContext context,
    Color primaryColor,
    Color darkSlate,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                    'Available Balance',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SDG 25,500',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: darkSlate,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/nafaj_wallet_top_up_options'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Top Up via Bankak',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF94A3B8),
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF475569), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
        ],
      ),
    );
  }
}
