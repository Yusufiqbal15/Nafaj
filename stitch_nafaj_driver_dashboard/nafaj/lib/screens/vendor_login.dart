import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';

class VendorLoginScreen extends StatefulWidget {
  const VendorLoginScreen({super.key});
  @override
  State<VendorLoginScreen> createState() => _VendorLoginScreenState();
}

class _VendorLoginScreenState extends State<VendorLoginScreen>
    with TickerProviderStateMixin {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AnimationController _entryCtrl;
  late final AnimationController _bgCtrl;
  late final AnimationController _ringCtrl;
  late final AnimationController _btnPressCtrl;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _btnPressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _bgCtrl.dispose();
    _ringCtrl.dispose();
    _btnPressCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _snack('الرجاء إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.vendorLogin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (result['success'] == true) {
        final approvalStatus = result['approvalStatus'] as String? ?? 'approved';
        if (approvalStatus == 'pending') {
          Navigator.pushReplacementNamed(
            context,
            '/pending_approval',
            arguments: {'userType': 'vendor'},
          );
        } else if (approvalStatus == 'rejected') {
          _snack('Your account has been rejected. Please contact Nafaj support.');
        } else {
          Navigator.pushReplacementNamed(context, '/vendor_dashboard');
        }
      } else {
        _snack(result['error'] ?? 'فشل تسجيل الدخول');
      }
    } catch (_) {
      if (mounted) _snack('خطأ في الاتصال، يرجى المحاولة مرة أخرى');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, textDirection: TextDirection.rtl),
      backgroundColor: const Color(0xFF1A1F35),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final localeProvider = context.watch<LocaleProvider>();
    final s = AppStrings.direct(isArabic: localeProvider.isArabic);
    final isAr = localeProvider.isArabic;

    final topAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
    );
    final midAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
    );
    final bottomAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutBack),
    );

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF08091A),
        body: Stack(
          children: [
            // Animated background
            AnimatedBuilder(
              animation: _bgCtrl,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _VendorBgPainter(_bgCtrl.value),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FadeTransition(
                          opacity:
                              Tween<double>(begin: 0, end: 1).animate(topAnim),
                          child: _glassIconBtn(
                            Icons.arrow_forward_rounded,
                            () => Navigator.pop(context),
                          ),
                        ),
                        FadeTransition(
                          opacity:
                              Tween<double>(begin: 0, end: 1).animate(topAnim),
                          child: _roleBadge(
                            s.vendorPortal,
                            Icons.storefront_rounded,
                            const Color(0xFFFFAA00),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 32),

                          // Animated store icon with spinning ring
                          FadeTransition(
                            opacity: Tween<double>(begin: 0, end: 1)
                                .animate(topAnim),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.3),
                                end: Offset.zero,
                              ).animate(topAnim),
                              child: _vendorIconHero(),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Title & subtitle
                          FadeTransition(
                            opacity: Tween<double>(begin: 0, end: 1)
                                .animate(topAnim),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.2),
                                end: Offset.zero,
                              ).animate(topAnim),
                              child: Column(
                                children: [
                                  Text(
                                    s.vendorWelcome,
                                    style: GoogleFonts.notoSansArabic(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    s.vendorSubtitle,
                                    style: GoogleFonts.notoSansArabic(
                                      fontSize: 14,
                                      color: Colors.white54,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Stats row
                          FadeTransition(
                            opacity: Tween<double>(begin: 0, end: 1)
                                .animate(midAnim),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.2),
                                end: Offset.zero,
                              ).animate(midAnim),
                              child: _statsRow(),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Form card
                          FadeTransition(
                            opacity: Tween<double>(begin: 0, end: 1)
                                .animate(midAnim),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.28),
                                end: Offset.zero,
                              ).animate(midAnim),
                              child: _formCard(),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Login button
                          FadeTransition(
                            opacity: Tween<double>(begin: 0, end: 1)
                                .animate(bottomAnim),
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.82, end: 1.0)
                                  .animate(bottomAnim),
                              child: _loginButton(),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Footer
                          FadeTransition(
                            opacity: Tween<double>(begin: 0, end: 1)
                                .animate(bottomAnim),
                            child: _footer(),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassIconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }

  Widget _roleBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.notoSansArabic(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vendorIconHero() {
    return AnimatedBuilder(
      animation: _ringCtrl,
      builder: (_, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Spinning dashed ring
            Transform.rotate(
              angle: _ringCtrl.value * 2 * math.pi,
              child: Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFFAA00).withOpacity(0.18),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            // Static ring
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFAA00).withOpacity(0.28),
                  width: 1.5,
                ),
              ),
            ),
            // Icon core
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2A1A00), Color(0xFF1A0E00)],
                ),
                border: Border.all(
                  color: const Color(0xFFFFAA00).withOpacity(0.45),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFCC7700).withOpacity(0.35),
                    blurRadius: 30,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: Color(0xFFFFAA00),
                size: 38,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statsRow() {
    final s = AppStrings.direct(
        isArabic: context.read<LocaleProvider>().isArabic);
    return Row(
      children: [
        _statChip(Icons.receipt_long_rounded, s.manageOrders, const Color(0xFFFFAA00)),
        const SizedBox(width: 12),
        _statChip(Icons.bar_chart_rounded, s.salesReport, const Color(0xFF00C896)),
        const SizedBox(width: 12),
        _statChip(Icons.inventory_2_rounded, s.products, const Color(0xFF5B8DEF)),
      ],
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.notoSansArabic(
                color: color.withOpacity(0.85),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _formCard() {
    final s = AppStrings.direct(
        isArabic: context.read<LocaleProvider>().isArabic);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFAA00).withOpacity(0.04),
            blurRadius: 40,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(s.emailLabel),
          const SizedBox(height: 10),
          _darkTextField(
            controller: _emailController,
            hint: 'vendor@example.com',
            icon: Icons.alternate_email_rounded,
            ltr: true,
            keyboard: TextInputType.emailAddress,
            accentColor: const Color(0xFFFFAA00),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _fieldLabel(s.passwordLabel),
              Text(
                s.forgotPassword,
                style: GoogleFonts.notoSansArabic(
                  color: const Color(0xFFFFAA00),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _darkPassField(accentColor: const Color(0xFFFFAA00)),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: GoogleFonts.notoSansArabic(
          color: Colors.white60,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      );

  Widget _darkTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool ltr = false,
    TextInputType? keyboard,
    required Color accentColor,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        textDirection: ltr ? TextDirection.ltr : null,
        textAlign: ltr ? TextAlign.left : TextAlign.right,
        keyboardType: keyboard,
        cursorColor: Colors.white,
        style: GoogleFonts.plusJakartaSans(color: Colors.black, fontSize: 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintText: hint,
          hintStyle:
              GoogleFonts.plusJakartaSans(color: Colors.white24, fontSize: 14),
          prefixIcon: Icon(icon, color: accentColor.withOpacity(0.65), size: 19),
        ),
      ),
    );
  }

  Widget _darkPassField({required Color accentColor}) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        cursorColor: Colors.white,
        style: GoogleFonts.plusJakartaSans(color: Colors.black, fontSize: 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintText: '••••••••',
          hintStyle: GoogleFonts.plusJakartaSans(
            color: Colors.white24,
            fontSize: 20,
            letterSpacing: 2,
          ),
          prefixIcon: Icon(Icons.lock_rounded,
              color: accentColor.withOpacity(0.65), size: 19),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: Colors.white38,
              size: 19,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }

  Widget _loginButton() {
    final s = AppStrings.direct(
        isArabic: context.read<LocaleProvider>().isArabic);
    return GestureDetector(
      onTapDown: (_) => _btnPressCtrl.forward(),
      onTapUp: (_) {
        _btnPressCtrl.reverse();
        if (!_isLoading) _login();
      },
      onTapCancel: () => _btnPressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _btnPressCtrl,
        builder: (_, child) => Transform.scale(
          scale: 1.0 - _btnPressCtrl.value * 0.03,
          child: child,
        ),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFAA00), Color(0xFFCC7700)],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFCC8800).withOpacity(0.5),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.storefront_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        s.loginAsVendor,
                        style: GoogleFonts.notoSansArabic(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _footer() {
    final s = AppStrings.direct(
        isArabic: context.read<LocaleProvider>().isArabic);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              s.noVendorAccount,
              style: GoogleFonts.notoSansArabic(
                  color: Colors.white38, fontSize: 14),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/vendor_sign_up'),
              child: Text(
                s.createVendorAccount,
                style: GoogleFonts.notoSansArabic(
                  color: const Color(0xFFFFAA00),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_rounded,
                size: 13, color: Colors.white.withOpacity(0.25)),
            const SizedBox(width: 6),
            Text(
              s.vendorPlatform,
              style: GoogleFonts.notoSansArabic(
                fontSize: 11,
                color: Colors.white.withOpacity(0.25),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VendorBgPainter extends CustomPainter {
  final double t;
  _VendorBgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // Deep dark base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF08091A), Color(0xFF100C20)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Amber/gold orb – top left
    final ax = size.width * (0.12 + 0.06 * math.cos(t * math.pi));
    final ay = size.height * (0.12 + 0.04 * math.sin(t * math.pi));
    canvas.drawCircle(
      Offset(ax, ay),
      size.width * 0.5,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFCC8800).withOpacity(0.16),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(
            center: Offset(ax, ay), radius: size.width * 0.5)),
    );

    // Purple orb – bottom right
    final px = size.width * (0.9 + 0.05 * math.sin(t * math.pi));
    final py = size.height * (0.78 + 0.05 * math.cos(t * math.pi));
    canvas.drawCircle(
      Offset(px, py),
      size.width * 0.55,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFF4A1A80).withOpacity(0.18),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(
            center: Offset(px, py), radius: size.width * 0.55)),
    );

    // Subtle grid
    final grid = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 0.5;
    for (int i = 0; i <= 10; i++) {
      final x = size.width * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (int i = 0; i <= 20; i++) {
      final y = size.height * i / 20;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  @override
  bool shouldRepaint(_VendorBgPainter old) => old.t != t;
}
