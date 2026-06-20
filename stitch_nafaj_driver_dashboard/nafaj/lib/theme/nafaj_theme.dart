import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────────────────────────────────
///  N A F A J   D E S I G N   S Y S T E M   v 2
///  One source of truth for colors, gradients, shadows, radii & typography.
/// ─────────────────────────────────────────────────────────────────────────────

class Nc {
  Nc._();

  // ── Brand ────────────────────────────────────────────────────────────────────
  static const Color brand       = Color(0xFFCC5500); // canonical orange
  static const Color brandLight  = Color(0xFFE8640A); // hover / light accent
  static const Color brandVibrant= Color(0xFFFF6B2B); // gradient top
  static const Color brandDeep   = Color(0xFFA33E00); // gradient bottom / pressed
  static const Color brandGlow   = Color(0xFFFF8C4A); // glow / shimmer

  // ── Light-screen surfaces ────────────────────────────────────────────────────
  static const Color bgWarm      = Color(0xFFFFFCF9); // main scaffold
  static const Color bgTinted    = Color(0xFFFFF4EC); // subtle tint
  static const Color surfaceCard = Color(0xFFFFFFFF); // white card
  static const Color surfaceDim  = Color(0xFFFFF0E6); // stat bg / chips
  static const Color borderLight = Color(0xFFEEE4DA); // dividers
  static const Color dividerWarm = Color(0xFFF5EDE6); // row dividers

  // ── Light-screen text ───────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1007);
  static const Color textSecondary = Color(0xFF5C4A3A);
  static const Color textHint      = Color(0xFFA08878);

  // ── Dark-screen surfaces (driver / vendor dark UI) ───────────────────────────
  static const Color darkBg      = Color(0xFF090604);
  static const Color darkSurface = Color(0xFF130D08);
  static const Color darkCard    = Color(0xFF1D1410);
  static const Color darkBorder  = Color(0xFF2E201A);
  static const Color darkRim     = Color(0xFF3D2A20);

  // ── Dark-screen text ─────────────────────────────────────────────────────────
  static const Color textOnDark      = Color(0xFFF5EFEA);
  static const Color textOnDarkMuted = Color(0xFF9E9088);
  static const Color textOnDarkFaint = Color(0xFF4E3E34);

  // ── Semantic ─────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error   = Color(0xFFDC2626);
  static const Color info    = Color(0xFF2563EB);

  // ── Status tints ─────────────────────────────────────────────────────────────
  static Color successTint  = const Color(0xFF16A34A).withOpacity(0.10);
  static Color errorTint    = const Color(0xFFDC2626).withOpacity(0.10);
  static Color warningTint  = const Color(0xFFD97706).withOpacity(0.10);
}

class Ng {
  Ng._();

  // Brand gradients
  static const LinearGradient brand = LinearGradient(
    colors: [Color(0xFFFF6B2B), Color(0xFFA33E00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandVertical = LinearGradient(
    colors: [Color(0xFFE8640A), Color(0xFF982E00)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient header = LinearGradient(
    colors: [Color(0xFFFF6B2B), Color(0xFFBB4400)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  // Dark-screen hero gradient
  static const LinearGradient darkHero = LinearGradient(
    colors: [Color(0xFF1C0E08), Color(0xFF090604)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Subtle warm card gradient (light screens)
  static const LinearGradient warmCard = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFFF8F3)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Orange glass overlay
  static LinearGradient glassOverlay = LinearGradient(
    colors: [
      const Color(0xFFCC5500).withOpacity(0.08),
      const Color(0xFFCC5500).withOpacity(0.0),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class Ns {
  Ns._();

  // Card shadow (light screens)
  static List<BoxShadow> get card => [
    BoxShadow(
      color: const Color(0xFFCC5500).withOpacity(0.07),
      blurRadius: 24,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // Card shadow (dark screens)
  static List<BoxShadow> get darkCard => [
    BoxShadow(
      color: const Color(0xFFCC5500).withOpacity(0.07),
      blurRadius: 32,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.35),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // CTA button shadow
  static List<BoxShadow> get button => [
    BoxShadow(
      color: const Color(0xFFCC5500).withOpacity(0.38),
      blurRadius: 22,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xFFCC5500).withOpacity(0.12),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  // Elevated card (light)
  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: const Color(0xFFCC5500).withOpacity(0.09),
      blurRadius: 36,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ];

  // Status bar / chip glow
  static List<BoxShadow> glowOrange(double intensity) => [
    BoxShadow(
      color: const Color(0xFFCC5500).withOpacity(intensity),
      blurRadius: 40,
      spreadRadius: 4,
    ),
  ];
}

class Nr {
  Nr._();
  static const double xs  = 8.0;
  static const double sm  = 12.0;
  static const double md  = 16.0;
  static const double lg  = 20.0;
  static const double xl  = 24.0;
  static const double xxl = 32.0;

  // Semantic
  static const double input  = 14.0;
  static const double card   = 20.0;
  static const double btn    = 16.0;
  static const double chip   = 20.0;
  static const double modal  = 24.0;
  static const double hero   = 28.0;
}

/// Shared text-field decoration helpers
class NInputDeco {
  NInputDeco._();

  /// Dark-background input decoration (driver / vendor login)
  static InputDecoration dark({
    required String hint,
    required IconData leadIcon,
    Widget? trail,
    bool ltrValue = false,
  }) {
    return InputDecoration(
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(
        color: Nc.textOnDarkFaint,
        fontSize: 14,
      ),
      prefixIcon: Icon(leadIcon, color: Nc.brandGlow.withOpacity(0.65), size: 19),
      suffixIcon: trail,
    );
  }

  /// Light-background input decoration (user login / forms)
  static InputDecoration light({
    required String hint,
    required IconData leadIcon,
    Widget? trail,
  }) {
    return InputDecoration(
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      hintText: hint,
      hintStyle: GoogleFonts.plusJakartaSans(
        color: Nc.textHint,
        fontSize: 14,
      ),
      prefixIcon: Icon(leadIcon, color: Nc.brand.withOpacity(0.60), size: 19),
      suffixIcon: trail,
    );
  }
}

/// Reusable branded CTA button
class NafajButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final double height;
  final IconData? icon;

  const NafajButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.height = 56,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: Ng.brandVertical,
          borderRadius: BorderRadius.circular(Nr.btn),
          boxShadow: Ns.button,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      label,
                      style: GoogleFonts.notoSansArabic(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Glass badge / role chip
class NafajRoleBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const NafajRoleBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(Nr.chip),
        border: Border.all(color: color.withOpacity(0.32), width: 1),
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
}

/// Dark-theme input field
class NafajDarkField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool ltr;
  final TextInputType? keyboard;
  final bool obscure;
  final bool showToggle;
  final VoidCallback? onToggle;

  const NafajDarkField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.ltr = false,
    this.keyboard,
    this.obscure = false,
    this.showToggle = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Nc.darkCard,
        borderRadius: BorderRadius.circular(Nr.input),
        border: Border.all(color: Nc.darkBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        textDirection: ltr ? TextDirection.ltr : null,
        textAlign: ltr ? TextAlign.left : TextAlign.right,
        keyboardType: keyboard,
        cursorColor: Nc.brandVibrant,
        style: GoogleFonts.plusJakartaSans(
          color: Nc.textOnDark,
          fontSize: 15,
        ),
        decoration: NInputDeco.dark(
          hint: hint,
          leadIcon: icon,
          trail: showToggle
              ? IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: Nc.textOnDarkMuted,
                    size: 19,
                  ),
                  onPressed: onToggle,
                )
              : null,
        ),
      ),
    );
  }
}

/// Light-theme input field
class NafajLightField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool ltr;
  final TextInputType? keyboard;
  final bool obscure;
  final bool showToggle;
  final VoidCallback? onToggle;

  const NafajLightField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.ltr = false,
    this.keyboard,
    this.obscure = false,
    this.showToggle = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Nc.bgWarm,
        borderRadius: BorderRadius.circular(Nr.input),
        border: Border.all(color: Nc.borderLight),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCC5500).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        textDirection: ltr ? TextDirection.ltr : null,
        textAlign: ltr ? TextAlign.left : TextAlign.right,
        keyboardType: keyboard,
        cursorColor: Nc.brand,
        style: GoogleFonts.plusJakartaSans(
          color: Nc.textPrimary,
          fontSize: 15,
        ),
        decoration: NInputDeco.light(
          hint: hint,
          leadIcon: icon,
          trail: showToggle
              ? IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    color: Nc.textHint,
                    size: 19,
                  ),
                  onPressed: onToggle,
                )
              : null,
        ),
      ),
    );
  }
}
