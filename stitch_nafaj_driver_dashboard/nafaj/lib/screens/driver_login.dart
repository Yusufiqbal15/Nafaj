import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';
import '../theme/nafaj_theme.dart';

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
      _snack(s.fillEmailPassword);
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
          _snack(s.accountRejected);
        } else {
          Navigator.pushReplacementNamed(context, '/driver_dashboard_animated_3d');
        }
      } else {
        _snack(result['error'] ?? s.loginFailed);
      }
    } catch (_) {
      if (mounted) _snack(s.connectionError);
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
        backgroundColor: Nc.darkBg,
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
          color: Nc.darkCard,
          borderRadius: BorderRadius.circular(Nr.sm),
          border: Border.all(color: Nc.darkBorder),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0,2)),
          ],
        ),
        child: Icon(icon, color: Nc.textOnDarkMuted, size: 20),
      ),
    );
  }

  Widget _roleBadge(String label, IconData icon, Color color) {
    return NafajRoleBadge(label: label, icon: icon, color: color);
  }

  Widget _driverIconHero() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring
        Container(
          width: 132,
          height: 132,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Nc.brand.withOpacity(0.09), width: 1),
          ),
        ),
        // Middle ring
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Nc.brand.withOpacity(0.18), width: 1),
          ),
        ),
        // Core
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              Nc.brand.withOpacity(0.32),
              Nc.brand.withOpacity(0.06),
            ]),
            border: Border.all(color: Nc.brandVibrant.withOpacity(0.55), width: 1.5),
            boxShadow: Ns.glowOrange(0.42),
          ),
          child: Icon(Icons.local_shipping_rounded, color: Nc.brandGlow, size: 40),
        ),
      ],
    );
  }

  Widget _formCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Nc.darkSurface,
        borderRadius: BorderRadius.circular(Nr.card),
        border: Border.all(color: Nc.darkBorder),
        boxShadow: Ns.darkCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(s.emailLabel),
          const SizedBox(height: 10),
          NafajDarkField(
            controller: _emailController,
            hint: 'driver@example.com',
            icon: Icons.alternate_email_rounded,
            ltr: true,
            keyboard: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          _fieldLabel(s.passwordLabel),
          const SizedBox(height: 10),
          NafajDarkField(
            controller: _passwordController,
            hint: '••••••••',
            icon: Icons.lock_rounded,
            obscure: _obscurePassword,
            showToggle: true,
            onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
            child: Text(
              s.forgotPassword,
              style: GoogleFonts.notoSansArabic(
                color: Nc.brandVibrant,
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
        padding: const EdgeInsets.only(bottom: 1),
        child: Text(
          text,
          style: GoogleFonts.notoSansArabic(
            color: Nc.textOnDarkMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      );

  Widget _loginButton() {
    return GestureDetector(
      onTapDown: (_) => _btnPressCtrl.forward(),
      onTapUp: (_) { _btnPressCtrl.reverse(); if (!_isLoading) _login(); },
      onTapCancel: () => _btnPressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _btnPressCtrl,
        builder: (_, child) => Transform.scale(
          scale: 1.0 - _btnPressCtrl.value * 0.03, child: child),
        child: NafajButton(
          label: s.loginAsDriver,
          icon: Icons.login_rounded,
          isLoading: _isLoading,
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
            Text(s.noDriverAccount,
                style: GoogleFonts.notoSansArabic(color: Nc.textOnDarkFaint, fontSize: 14)),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/driver_sign_up'),
              child: Text(
                s.createDriverAccount,
                style: GoogleFonts.notoSansArabic(
                  color: Nc.brandVibrant, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_rounded, size: 12, color: Nc.textOnDarkFaint),
            const SizedBox(width: 5),
            Text(s.secureLogin,
                style: GoogleFonts.notoSansArabic(
                    fontSize: 11, color: Nc.textOnDarkFaint)),
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
    // Warm-dark base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF0C0806), const Color(0xFF090604)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Animated brand orb – top right
    final ox = size.width * (0.88 + 0.07 * math.sin(t * math.pi));
    final oy = size.height * (0.1 + 0.04 * math.cos(t * math.pi));
    canvas.drawCircle(
      Offset(ox, oy),
      size.width * 0.55,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFCC5500).withOpacity(0.20),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(center: Offset(ox, oy), radius: size.width * 0.55)),
    );

    // Warm amber orb – bottom left
    final bx = size.width * (0.08 - 0.04 * math.sin(t * math.pi));
    final by = size.height * (0.82 + 0.04 * math.cos(t * math.pi));
    canvas.drawCircle(
      Offset(bx, by),
      size.width * 0.5,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFF6B2A00).withOpacity(0.18),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(center: Offset(bx, by), radius: size.width * 0.5)),
    );

    // Subtle warm grid
    final grid = Paint()
      ..color = const Color(0xFFFF6B2B).withOpacity(0.028)
      ..strokeWidth = 0.5;
    for (int i = 0; i <= 10; i++) {
      canvas.drawLine(Offset(size.width * i / 10, 0), Offset(size.width * i / 10, size.height), grid);
    }
    for (int i = 0; i <= 18; i++) {
      canvas.drawLine(Offset(0, size.height * i / 18), Offset(size.width, size.height * i / 18), grid);
    }

    // Diagonal brand lines
    final accent = Paint()
      ..color = const Color(0xFFCC5500).withOpacity(0.045)
      ..strokeWidth = 1;
    for (int i = -4; i <= 14; i++) {
      final startX = size.width * i / 8;
      canvas.drawLine(Offset(startX, 0), Offset(startX + size.height * 0.38, size.height), accent);
    }
  }

  @override
  bool shouldRepaint(_DriverBgPainter old) => old.t != t;
}
