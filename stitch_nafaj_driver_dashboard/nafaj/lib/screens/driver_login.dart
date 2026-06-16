import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});
  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen>
    with TickerProviderStateMixin {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AnimationController _entryCtrl;
  late final AnimationController _bgCtrl;
  late final AnimationController _iconCtrl;
  late final AnimationController _btnPressCtrl;
  
  late AppStrings s;
  late bool isAr;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _btnPressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _bgCtrl.dispose();
    _iconCtrl.dispose();
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
      final result = await ApiService.driverLogin(
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
            arguments: {'userType': 'driver'},
          );
        } else if (approvalStatus == 'rejected') {
          _snack('Your account has been rejected. Please contact Nafaj support.');
        } else {
          Navigator.pushReplacementNamed(context, '/driver_dashboard_animated_3d');
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
      backgroundColor: const Color(0xFF1A2540),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final localeProvider = context.watch<LocaleProvider>();
    s = AppStrings.direct(isArabic: localeProvider.isArabic);
    isAr = localeProvider.isArabic;

    final headerAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    );
    final formAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
    );
    final btnAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOutBack),
    );
    final iconScale =
        Tween<double>(begin: 0.94, end: 1.06).animate(_iconCtrl);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF060A12),
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: _bgCtrl,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _DriverBgPainter(_bgCtrl.value),
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
                        _glassIconBtn(
                          Icons.arrow_forward_rounded,
                          () => Navigator.pop(context),
                        ),
                        _roleBadge(
                          s.driverPortal,
                          Icons.local_shipping_rounded,
                          const Color(0xFFFF7A00),
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
                          const SizedBox(height: 36),

                          // Animated hero icon
                          FadeTransition(
                            opacity: Tween<double>(begin: 0, end: 1)
                                .animate(headerAnim),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, -0.35),
                                end: Offset.zero,
                              ).animate(headerAnim),
                              child: AnimatedBuilder(
                                animation: iconScale,
                                builder: (_, child) => Transform.scale(
                                    scale: iconScale.value, child: child),
                                child: _driverIconHero(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 26),

                          // Title
                          FadeTransition(
                            opacity: Tween<double>(begin: 0, end: 1)
                                .animate(headerAnim),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.25),
                                end: Offset.zero,
                              ).animate(headerAnim),
                              child: Column(
                                children: [
                                  Text(
                                    s.driverWelcome,
                                    style: GoogleFonts.notoSansArabic(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    s.driverSubtitle,
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

                          const SizedBox(height: 36),

                          // Form card
                          FadeTransition(
                            opacity: Tween<double>(begin: 0, end: 1)
                                .animate(formAnim),
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(formAnim),
                              child: _formCard(),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Login button
                          FadeTransition(
                            opacity: Tween<double>(begin: 0, end: 1)
                                .animate(btnAnim),
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.8, end: 1.0)
                                  .animate(btnAnim),
                              child: _loginButton(),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Footer
                          FadeTransition(
                            opacity: Tween<double>(begin: 0, end: 1)
                                .animate(btnAnim),
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

  Widget _driverIconHero() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 124,
          height: 124,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFF7A00).withOpacity(0.12),
              width: 1.5,
            ),
          ),
        ),
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFF7A00).withOpacity(0.22),
              width: 1.5,
            ),
          ),
        ),
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              const Color(0xFFCC5500).withOpacity(0.28),
              const Color(0xFFCC5500).withOpacity(0.07),
            ]),
            border: Border.all(
              color: const Color(0xFFFF7A00).withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFCC5500).withOpacity(0.38),
                blurRadius: 34,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.local_shipping_rounded,
            color: Color(0xFFFF7A00),
            size: 40,
          ),
        ),
      ],
    );
  }

  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.09)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCC5500).withOpacity(0.05),
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
            hint: 'driver@example.com',
            icon: Icons.alternate_email_rounded,
            ltr: true,
            keyboard: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          _fieldLabel(s.passwordLabel),
          const SizedBox(height: 10),
          _darkPassField(),
          const SizedBox(height: 14),
          Align(
            alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
            child: Text(
              s.forgotPassword,
              style: GoogleFonts.notoSansArabic(
                color: const Color(0xFFFF7A00),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(right: 2),
        child: Text(
          text,
          style: GoogleFonts.notoSansArabic(
            color: Colors.white60,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  Widget _darkTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool ltr = false,
    TextInputType? keyboard,
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
          prefixIcon: Icon(
            icon,
            color: const Color(0xFFFF7A00).withOpacity(0.65),
            size: 19,
          ),
        ),
      ),
    );
  }

  Widget _darkPassField() {
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
          prefixIcon: Icon(
            Icons.lock_rounded,
            color: const Color(0xFFFF7A00).withOpacity(0.65),
            size: 19,
          ),
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
              colors: [Color(0xFFFF6B00), Color(0xFFBB4400)],
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFCC5500).withOpacity(0.5),
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
                      const Icon(Icons.login_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        s.loginAsDriver,
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              s.noDriverAccount,
              style: GoogleFonts.notoSansArabic(
                  color: Colors.white38, fontSize: 14),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/driver_sign_up'),
              child: Text(
                s.createDriverAccount,
                style: GoogleFonts.notoSansArabic(
                  color: const Color(0xFFFF7A00),
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
              s.secureLogin,
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

class _DriverBgPainter extends CustomPainter {
  final double t;
  _DriverBgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF060A12), Color(0xFF0C1422)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Animated orange orb – top right
    final ox = size.width * (0.88 + 0.07 * math.sin(t * math.pi));
    final oy = size.height * (0.1 + 0.04 * math.cos(t * math.pi));
    canvas.drawCircle(
      Offset(ox, oy),
      size.width * 0.55,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFCC5500).withOpacity(0.18),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(
            center: Offset(ox, oy), radius: size.width * 0.55)),
    );

    // Animated blue orb – bottom left
    final bx = size.width * (0.08 - 0.04 * math.sin(t * math.pi));
    final by = size.height * (0.82 + 0.04 * math.cos(t * math.pi));
    canvas.drawCircle(
      Offset(bx, by),
      size.width * 0.5,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFF0A3060).withOpacity(0.22),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(
            center: Offset(bx, by), radius: size.width * 0.5)),
    );

    // Subtle grid
    final grid = Paint()
      ..color = Colors.white.withOpacity(0.022)
      ..strokeWidth = 0.5;
    for (int i = 0; i <= 10; i++) {
      final x = size.width * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (int i = 0; i <= 18; i++) {
      final y = size.height * i / 18;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // Diagonal accent lines
    final accent = Paint()
      ..color = const Color(0xFFFF7A00).withOpacity(0.04)
      ..strokeWidth = 1;
    for (int i = -4; i <= 14; i++) {
      final startX = size.width * i / 8;
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + size.height * 0.38, size.height),
        accent,
      );
    }
  }

  @override
  bool shouldRepaint(_DriverBgPainter old) => old.t != t;
}
