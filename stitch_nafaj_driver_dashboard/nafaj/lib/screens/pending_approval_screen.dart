import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class PendingApprovalScreen extends StatefulWidget {
  final String userType; // 'vendor' or 'driver'

  const PendingApprovalScreen({super.key, required this.userType});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _rotateCtrl;
  late final AnimationController _bgCtrl;

  bool _isChecking = false;
  String _statusMessage = 'Your account is under review';
  Timer? _autoCheckTimer;

  static const Color primaryColor = Color(0xFFCC5500);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // Auto-check every 30 seconds
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkStatus(silent: true);
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    _bgCtrl.dispose();
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus({bool silent = false}) async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    try {
      final result = await ApiService.checkApprovalStatus();

      if (!mounted) return;

      if (result['success'] == true) {
        final status = result['approvalStatus'] as String? ?? 'pending';

        if (status == 'approved') {
          final dashboard = widget.userType == 'vendor'
              ? '/vendor_dashboard'
              : '/driver_dashboard_animated_3d';
          Navigator.pushNamedAndRemoveUntil(
              context, dashboard, (route) => false);
          return;
        }

        if (status == 'rejected') {
          setState(() {
            _statusMessage = 'Your account has been rejected.\nPlease contact nafaj support.';
          });
          if (!silent) _showSnack('Account rejected. Contact support for assistance.');
        } else {
          if (!silent) _showSnack('Still pending. We\'ll notify you once approved.');
        }
      } else {
        if (!silent) _showSnack(result['error'] ?? 'Could not check status');
      }
    } catch (_) {
      if (!silent && mounted) _showSnack('Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF1A1F35),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (!mounted) return;
    final loginRoute =
        widget.userType == 'vendor' ? '/vendor_login' : '/driver_login';
    Navigator.pushNamedAndRemoveUntil(context, loginRoute, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isVendor = widget.userType == 'vendor';
    final accentColor = isVendor ? const Color(0xFFFFAA00) : primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFF06080F),
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _PendingBgPainter(_bgCtrl.value, accentColor),
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
                      _buildRoleBadge(isVendor, accentColor),
                      GestureDetector(
                        onTap: _logout,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Text(
                            'Log out',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white54,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          const SizedBox(height: 48),

                          // Animated hourglass icon
                          _buildHourglassIcon(accentColor),

                          const SizedBox(height: 40),

                          // Title
                          Text(
                            'Pending Approval',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Text(
                            _statusMessage,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              color: Colors.white54,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Info card
                          _buildInfoCard(accentColor),

                          const SizedBox(height: 32),

                          // Check status button
                          _buildCheckButton(accentColor),

                          const SizedBox(height: 20),

                          // Status steps
                          _buildStatusSteps(accentColor),

                          const SizedBox(height: 40),
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
    );
  }

  Widget _buildRoleBadge(bool isVendor, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVendor ? Icons.storefront_rounded : Icons.local_shipping_rounded,
            color: accentColor,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            isVendor ? 'Vendor Portal' : 'Driver Portal',
            style: GoogleFonts.plusJakartaSans(
              color: accentColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourglassIcon(Color accentColor) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseCtrl, _rotateCtrl]),
      builder: (_, __) {
        final pulse = 0.93 + 0.07 * _pulseCtrl.value;
        return Transform.scale(
          scale: pulse,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer spinning ring
              Transform.rotate(
                angle: _rotateCtrl.value * 2 * math.pi,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              // Counter-spinning ring
              Transform.rotate(
                angle: -_rotateCtrl.value * 2 * math.pi * 0.6,
                child: Container(
                  width: 116,
                  height: 116,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              // Core circle
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    accentColor.withOpacity(0.25),
                    accentColor.withOpacity(0.05),
                  ]),
                  border: Border.all(
                    color: accentColor.withOpacity(0.55),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.hourglass_top_rounded,
                  color: accentColor,
                  size: 42,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          _infoRow(
            Icons.check_circle_outline_rounded,
            'Registration submitted',
            'Your details have been saved',
            const Color(0xFF22C55E),
          ),
          const SizedBox(height: 16),
          _infoRow(
            Icons.manage_accounts_rounded,
            'Admin review in progress',
            'Nafaj team is verifying your information',
            accentColor,
          ),
          const SizedBox(height: 16),
          _infoRow(
            Icons.rocket_launch_rounded,
            'Access granted after approval',
            'You\'ll be redirected automatically',
            Colors.white38,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
      IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.87),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckButton(Color accentColor) {
    return GestureDetector(
      onTap: _isChecking ? null : () => _checkStatus(),
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentColor, accentColor.withOpacity(0.75)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: _isChecking
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.refresh_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Check Approval Status',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatusSteps(Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: accentColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Status is checked automatically every 30 seconds. Tap the button above to check immediately.',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white38,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingBgPainter extends CustomPainter {
  final double t;
  final Color accent;

  _PendingBgPainter(this.t, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF06080F), Color(0xFF0C0F1A)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Accent orb top-right
    final ax = size.width * (0.85 + 0.08 * math.sin(t * math.pi));
    final ay = size.height * (0.1 + 0.04 * math.cos(t * math.pi));
    canvas.drawCircle(
      Offset(ax, ay),
      size.width * 0.5,
      Paint()
        ..shader = RadialGradient(colors: [
          accent.withOpacity(0.14),
          Colors.transparent,
        ]).createShader(
            Rect.fromCircle(center: Offset(ax, ay), radius: size.width * 0.5)),
    );

    // Dark blue orb bottom-left
    final bx = size.width * (0.1 + 0.05 * math.cos(t * math.pi));
    final by = size.height * (0.8 + 0.04 * math.sin(t * math.pi));
    canvas.drawCircle(
      Offset(bx, by),
      size.width * 0.45,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFF0A1F50).withOpacity(0.2),
          Colors.transparent,
        ]).createShader(
            Rect.fromCircle(center: Offset(bx, by), radius: size.width * 0.45)),
    );

    // Grid
    final grid = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 0.5;
    for (int i = 0; i <= 10; i++) {
      canvas.drawLine(
          Offset(size.width * i / 10, 0), Offset(size.width * i / 10, size.height), grid);
    }
    for (int i = 0; i <= 20; i++) {
      canvas.drawLine(
          Offset(0, size.height * i / 20), Offset(size.width, size.height * i / 20), grid);
    }
  }

  @override
  bool shouldRepaint(_PendingBgPainter old) => old.t != t;
}
