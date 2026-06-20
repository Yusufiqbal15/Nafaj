import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';
import '../theme/nafaj_theme.dart';

class NafajPhoneLoginScreen extends StatefulWidget {
  const NafajPhoneLoginScreen({super.key});
  @override
  State<NafajPhoneLoginScreen> createState() => _NafajPhoneLoginScreenState();
}

class _NafajPhoneLoginScreenState extends State<NafajPhoneLoginScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AnimationController _entryCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _btnPressCtrl;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _btnPressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _floatCtrl.dispose();
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
      final result = await ApiService.userLogin(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (result['success'] == true) {
        Navigator.pushReplacementNamed(
            context, '/nafaj_home_exact_header_match');
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
      backgroundColor: const Color(0xFFCC5500),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final s = AppStrings.direct(isArabic: localeProvider.isArabic);
    final isAr = localeProvider.isArabic;

    final size = MediaQuery.of(context).size;
    final headerHeight = size.height * 0.42;

    final headerAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    );
    final formAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.3, 0.85, curve: Curves.easeOutCubic),
    );
    final btnAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOutBack),
    );
    final floatY =
        Tween<double>(begin: -6.0, end: 6.0).animate(_floatCtrl);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Nc.bgWarm,
        body: Stack(
          children: [
            // Warm orange gradient header with wave
            SizedBox(
              height: headerHeight + 30,
              width: double.infinity,
              child: Stack(
                children: [
                  // Gradient header
                  ClipPath(
                    clipper: _WaveClipper(),
                    child: Container(
                      height: headerHeight + 30,
                      decoration: const BoxDecoration(
                        gradient: Ng.header,
                      ),
                      child: Stack(
                        children: [
                          // Decorative circles in header
                          Positioned(
                            top: -40,
                            left: -40,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.07),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            left: 60,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.06),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 60,
                            right: -20,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.06),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Full screen layout
            SafeArea(
              child: Column(
                children: [
                  // Top action row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.shopping_bag_rounded,
                                  color: Colors.white, size: 13),
                              const SizedBox(width: 5),
                              Text(
                                'نفاج للتسوق',
                                style: GoogleFonts.notoSansArabic(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Hero content in header
                  SizedBox(
                    height: headerHeight - 80,
                    child: FadeTransition(
                      opacity:
                          Tween<double>(begin: 0, end: 1).animate(headerAnim),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.2),
                          end: Offset.zero,
                        ).animate(headerAnim),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Floating icon
                            AnimatedBuilder(
                              animation: floatY,
                              builder: (_, child) => Transform.translate(
                                offset: Offset(0, floatY.value),
                                child: child,
                              ),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.18),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.shopping_bag_rounded,
                                  color: Colors.white,
                                  size: 38,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isAr ? 'مرحباً بك مجدداً!' : 'Welcome Back!',
                              style: GoogleFonts.notoSansArabic(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isAr ? 'أدخل بياناتك للمتابعة' : 'Enter your details to continue',
                              style: GoogleFonts.notoSansArabic(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // White form area
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),

                            // Form card
                            FadeTransition(
                              opacity: Tween<double>(begin: 0, end: 1)
                                  .animate(formAnim),
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.25),
                                  end: Offset.zero,
                                ).animate(formAnim),
                                child: _formCard(),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Login button
                            FadeTransition(
                              opacity: Tween<double>(begin: 0, end: 1)
                                  .animate(btnAnim),
                              child: ScaleTransition(
                                scale: Tween<double>(begin: 0.85, end: 1.0)
                                    .animate(btnAnim),
                                child: _loginButton(),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Footer links
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formCard() {
    final s = AppStrings.direct(isArabic: context.read<LocaleProvider>().isArabic);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: Ng.warmCard,
        borderRadius: BorderRadius.circular(Nr.card),
        border: Border.all(color: Nc.borderLight),
        boxShadow: Ns.elevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(s.emailLabel),
          const SizedBox(height: 10),
          NafajLightField(
            controller: _emailController,
            hint: 'user@example.com',
            icon: Icons.alternate_email_rounded,
            ltr: true,
            keyboard: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _fieldLabel(s.passwordLabel),
              Text(s.forgotPassword,
                style: GoogleFonts.notoSansArabic(
                    color: Nc.brand, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          NafajLightField(
            controller: _passwordController,
            hint: '••••••••',
            icon: Icons.lock_rounded,
            obscure: _obscurePassword,
            showToggle: true,
            onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: GoogleFonts.notoSansArabic(
          color: Nc.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _loginButton() {
    final s = AppStrings.direct(isArabic: context.read<LocaleProvider>().isArabic);
    return GestureDetector(
      onTapDown: (_) => _btnPressCtrl.forward(),
      onTapUp: (_) { _btnPressCtrl.reverse(); if (!_isLoading) _login(); },
      onTapCancel: () => _btnPressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _btnPressCtrl,
        builder: (_, child) => Transform.scale(
          scale: 1.0 - _btnPressCtrl.value * 0.03, child: child),
        child: NafajButton(label: s.loginBtn, icon: Icons.login_rounded, isLoading: _isLoading, height: 58),
      ),
    );
  }

  Widget _footer() {
    final s = AppStrings.direct(isArabic: context.read<LocaleProvider>().isArabic);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(s.noAccount,
                style: GoogleFonts.notoSansArabic(color: Nc.textHint, fontSize: 14)),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/user_sign_up'),
              child: Text(s.createAccount,
                  style: GoogleFonts.notoSansArabic(
                      color: Nc.brand, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_rounded, size: 12, color: Nc.borderLight),
            const SizedBox(width: 5),
            Text(s.secureLogin,
                style: GoogleFonts.notoSansArabic(
                    fontSize: 11, color: Nc.textHint, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 55);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height - 10,
      size.width * 0.5,
      size.height - 42,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 75,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
