import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants.dart' hide AppStrings;
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';

class NafajWelcomeProfessionalScreen extends StatefulWidget {
  const NafajWelcomeProfessionalScreen({super.key});

  @override
  State<NafajWelcomeProfessionalScreen> createState() =>
      _NafajWelcomeProfessionalScreenState();
}

class _NafajWelcomeProfessionalScreenState
    extends State<NafajWelcomeProfessionalScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final AnimationController _glowCtrl;
  late final AnimationController _arrowCtrl;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _arrowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _glowCtrl.dispose();
    _arrowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final s = AppStrings.direct(isArabic: localeProvider.isArabic);
    final isAr = localeProvider.isArabic;

    // Entry animation intervals
    final topFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    final titleAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
    );
    final subtitleAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.35, 0.8, curve: Curves.easeOutCubic),
    );
    final btnAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.5, 0.95, curve: Curves.easeOutBack),
    );
    final bottomAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
    );
    final arrowShift =
        Tween<double>(begin: 0, end: 6).animate(_arrowCtrl);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // ── Hero background image ──────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.72,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('premium_truck.png', fit: BoxFit.cover),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.15),
                          Colors.black.withOpacity(0.75),
                          Colors.black,
                        ],
                        stops: const [0.0, 0.45, 0.78, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Animated orange glow at bottom ─────────────────────
            AnimatedBuilder(
              animation: _glowCtrl,
              builder: (_, __) {
                final h = MediaQuery.of(context).size.height;
                return Positioned(
                  bottom: h * 0.18,
                  left: -60,
                  right: -60,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF7A00).withOpacity(
                            0.08 + 0.06 * math.sin(_glowCtrl.value * math.pi),
                          ),
                          blurRadius: 80,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // ── Main content ────────────────────────────────────────
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar: Brand + Language Toggle
                    FadeTransition(
                      opacity: Tween<double>(begin: 0, end: 1).animate(topFade),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Brand chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.14)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFFF7A00),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'NAFAJ',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Language toggle
                            _LanguageToggle(provider: localeProvider),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 11),

                    // Pagination dots
                    FadeTransition(
                      opacity:
                          Tween<double>(begin: 0, end: 1).animate(titleAnim),
                      child: Row(
                        children: [
                          _dot(false),
                          const SizedBox(width: 6),
                          _dot(false),
                          const SizedBox(width: 6),
                          _dot(true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Hero title
                    FadeTransition(
                      opacity:
                          Tween<double>(begin: 0, end: 1).animate(titleAnim),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.25),
                          end: Offset.zero,
                        ).animate(titleAnim),
                        child: Text(
                          s.heroTitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: isAr ? 34 : 38,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Subtitle
                    FadeTransition(
                      opacity: Tween<double>(begin: 0, end: 1)
                          .animate(subtitleAnim),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(subtitleAnim),
                        child: Text(
                          s.heroSubtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.65),
                            height: 1.55,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Get Started button
                    FadeTransition(
                      opacity:
                          Tween<double>(begin: 0, end: 1).animate(btnAnim),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.88, end: 1.0)
                            .animate(btnAnim),
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, '/nafaj_phone_login_screen'),
                          child: Container(
                            width: double.infinity,
                            height: 72,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161616),
                              borderRadius: BorderRadius.circular(36),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.1)),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF7A00)
                                      .withOpacity(0.2),
                                  blurRadius: 28,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Icon bubble
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFF8C00),
                                        Color(0xFFCC5500)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.inventory_2_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  s.getStarted,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                // Animated arrows
                                AnimatedBuilder(
                                  animation: arrowShift,
                                  builder: (_, __) => Transform.translate(
                                    offset: Offset(
                                        isAr ? -arrowShift.value : arrowShift.value,
                                        0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isAr
                                              ? Icons.arrow_back_ios
                                              : Icons.arrow_forward_ios,
                                          size: 14,
                                          color:
                                              Colors.white.withOpacity(0.3),
                                        ),
                                        Icon(
                                          isAr
                                              ? Icons.arrow_back_ios
                                              : Icons.arrow_forward_ios,
                                          size: 14,
                                          color:
                                              Colors.white.withOpacity(0.6),
                                        ),
                                        Icon(
                                          isAr
                                              ? Icons.arrow_back_ios
                                              : Icons.arrow_forward_ios,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Promo text
                    FadeTransition(
                      opacity: Tween<double>(begin: 0, end: 1)
                          .animate(bottomAnim),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85),
                            ),
                            children: [
                              TextSpan(text: s.promoPrefix),
                              TextSpan(
                                text: 'NAFAJ50',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFF7A00),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Bottom role panel
                    FadeTransition(
                      opacity: Tween<double>(begin: 0, end: 1)
                          .animate(bottomAnim),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(bottomAnim),
                        child: Container(
                          padding:
                              const EdgeInsets.fromLTRB(18, 22, 18, 18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1220),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(32),
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.06),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Role cards row
                              Row(
                                children: [
                                  Expanded(
                                    child: _RoleCard(
                                      icon: Icons.moped_rounded,
                                      label: s.driver,
                                      accentColor:
                                          const Color(0xFFFF7A00),
                                      onTap: () => Navigator.pushNamed(
                                          context, '/driver_login'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _RoleCard(
                                      icon: Icons.storefront_rounded,
                                      label: s.vendor,
                                      accentColor:
                                          const Color(0xFFFFAA00),
                                      onTap: () => Navigator.pushNamed(
                                          context, '/vendor_login'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _RoleCard(
                                      icon: Icons.login_rounded,
                                      label: s.login,
                                      accentColor:
                                          const Color(0xFF5B9EFF),
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        '/nafaj_phone_login_screen',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Footer links
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  _footerLink(s.faqs),
                                  _footerDivider(),
                                  _footerLink(s.support),
                                  _footerDivider(),
                                  _footerLink(s.aboutUs),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 22 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFFF7A00)
            : Colors.white.withOpacity(0.35),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _footerLink(String text) => Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: Colors.white.withOpacity(0.38),
          fontWeight: FontWeight.w600,
        ),
      );

  Widget _footerDivider() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        height: 12,
        width: 1,
        color: Colors.white.withOpacity(0.1),
      );
}

// ── Language Toggle ──────────────────────────────────────────────────────────

class _LanguageToggle extends StatelessWidget {
  final LocaleProvider provider;
  const _LanguageToggle({required this.provider});

  @override
  Widget build(BuildContext context) {
    final isAr = provider.isArabic;

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangBtn(
            label: 'ENG',
            active: !isAr,
            onTap: () => provider.setEnglish(),
          ),
          _LangBtn(
            label: 'SUD',
            active: isAr,
            onTap: () => provider.setArabic(),
          ),
        ],
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _LangBtn({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFF7A00) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF7A00).withOpacity(0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : Colors.white.withOpacity(0.45),
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

// ── Role Card ────────────────────────────────────────────────────────────────

class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (_, child) => Transform.scale(
          scale: 1.0 - _pressCtrl.value * 0.05,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: widget.accentColor.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.accentColor.withOpacity(0.22),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.accentColor.withOpacity(0.12),
                ),
                child: Icon(widget.icon,
                    color: widget.accentColor, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
