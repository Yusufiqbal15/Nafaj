import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/nafaj_bottom_nav.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';
import '../services/api_service.dart';
import '../theme/nafaj_theme.dart';

class NafajProfileManagementScreen extends StatefulWidget {
  const NafajProfileManagementScreen({super.key});

  @override
  State<NafajProfileManagementScreen> createState() =>
      _NafajProfileManagementScreenState();
}

class _NafajProfileManagementScreenState
    extends State<NafajProfileManagementScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ApiService.getProfile();
    if (!mounted) return;
    if (result['success'] == true) {
      final raw = result['data'];
      setState(() {
        _profile = raw is Map ? Map<String, dynamic>.from(raw) : null;
        _loading = false;
      });
    } else {
      setState(() {
        _error = result['error']?.toString();
        _loading = false;
      });
    }
  }

  // ── Derived display values ──────────────────────────────────────
  String get _displayName {
    if (_profile == null) return '—';
    final first = (_profile!['firstName'] ?? '').toString().trim();
    final last = (_profile!['lastName'] ?? '').toString().trim();
    final full = [first, last].where((p) => p.isNotEmpty).join(' ');
    if (full.isNotEmpty) return full;
    return (_profile!['name'] ?? '—').toString();
  }

  String get _initials {
    final name = _displayName;
    if (name == '—') return '?';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  String get _email => (_profile?['email'] ?? '').toString();
  String get _phone => (_profile?['phone'] ?? '').toString();

  String get _walletBalance {
    final bal = _profile?['walletBalance'] ?? _profile?['balance'];
    if (bal == null) return '—';
    final num = double.tryParse(bal.toString());
    if (num == null) return '—';
    return 'SDG ${num.toStringAsFixed(0)}';
  }

  String _statVal(String key) =>
      _profile?[key]?.toString() ?? '—';

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final s = AppStrings.direct(isArabic: locale.isArabic);
    final isAr = locale.isArabic;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Nc.bgWarm,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Hero SliverAppBar ──────────────────────────────────
            SliverAppBar(
              expandedHeight: 290,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: Nc.darkBg,
              elevation: 0,
              title: AnimatedOpacity(
                opacity: _loading ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _displayName,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeroBackground(isAr),
              ),
            ),

            // ── Body ───────────────────────────────────────────────
            if (_loading)
              SliverFillRemaining(child: _buildLoading())
            else if (_error != null)
              SliverFillRemaining(child: _buildError(s))
            else
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -32),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Wallet card
                        _WalletCard(
                          balance: _walletBalance,
                          s: s,
                          onTopUp: () => Navigator.pushNamed(
                            context, '/nafaj_wallet_top_up_options'),
                        ),
                        const SizedBox(height: 16),

                        // Stats
                        Row(
                          children: [
                            _StatBox(
                              label: s.profileOrders,
                              value: _statVal('ordersCount'),
                              icon: Icons.receipt_long_rounded,
                              color: const Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 10),
                            _StatBox(
                              label: s.profileJobs,
                              value: _statVal('jobsCount'),
                              icon: Icons.work_rounded,
                              color: const Color(0xFF7C3AED),
                            ),
                            const SizedBox(width: 10),
                            _StatBox(
                              label: s.profilePoints,
                              value: _statVal('points'),
                              icon: Icons.stars_rounded,
                              color: Nc.warning,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // ── Personal section ──
                        _SectionHeader(title: s.personalManagement),
                        _InfoTile(
                          icon: Icons.person_outline_rounded,
                          title: s.personalInformationMenu,
                          value: _displayName,
                          branded: true,
                        ),
                        _InfoTile(
                          icon: Icons.email_outlined,
                          title: isAr ? 'البريد الإلكتروني' : 'Email',
                          value: _email.isNotEmpty
                              ? _email
                              : (isAr ? 'غير محدد' : 'Not set'),
                          ltr: true,
                          branded: true,
                        ),
                        _InfoTile(
                          icon: Icons.phone_outlined,
                          title: s.phoneNumber,
                          value: _phone.isNotEmpty
                              ? _phone
                              : (isAr ? 'غير محدد' : 'Not set'),
                          ltr: true,
                          branded: true,
                        ),
                        _MenuItem(
                          icon: Icons.location_on_outlined,
                          title: s.savedAddresses,
                          subtitle: s.savedAddressesSubtitle,
                        ),
                        _MenuItem(
                          icon: Icons.notifications_none_rounded,
                          title: s.notificationsMenu,
                          subtitle: s.notificationsSubtitle,
                        ),
                        const SizedBox(height: 24),

                        // ── Financial section ──
                        _SectionHeader(title: s.financialSection),
                        _MenuItem(
                          icon: Icons.account_balance_wallet_outlined,
                          title: s.nafajWalletMenu,
                          subtitle: _walletBalance != '—'
                              ? _walletBalance
                              : s.walletBalanceLabel,
                        ),
                        _MenuItem(
                          icon: Icons.payment_rounded,
                          title: s.paymentMethods,
                          subtitle: s.paymentMethodsSubtitle,
                        ),
                        const SizedBox(height: 24),

                        // ── Security & More ──
                        _SectionHeader(title: s.securityAndMore),
                        _MenuItem(
                          icon: Icons.security_rounded,
                          title: s.securitySettings,
                          subtitle: s.securitySubtitle,
                        ),
                        _MenuItem(
                          icon: Icons.help_outline_rounded,
                          title: s.helpAndSupport,
                          subtitle: s.helpSubtitle,
                        ),
                        _LanguageToggle(locale: locale, s: s, isAr: isAr),
                        _MenuItem(
                          icon: Icons.info_outline_rounded,
                          title: s.aboutNafaj,
                          subtitle: s.appVersion,
                        ),
                        const SizedBox(height: 32),

                        // ── Logout ──
                        _LogoutButton(s: s),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: NafajBottomNav(currentIndex: 4, onTap: (index) {}),
      ),
    );
  }

  // ── Hero background ──────────────────────────────────────────────
  Widget _buildHeroBackground(bool isAr) {
    return Container(
      decoration: const BoxDecoration(gradient: Ng.darkHero),
      child: Stack(
        children: [
          Positioned(
            right: -60, top: -60,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Nc.brand.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            left: -30, bottom: 10,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Nc.brand.withOpacity(0.04),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: Ng.brand,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Nc.brand.withOpacity(0.40),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: _loading
                            ? const Center(
                                child: SizedBox(
                                  width: 26, height: 26,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  _initials,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 2, right: 2,
                        child: Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            color: Nc.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _loading ? '...' : _displayName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  if (!_loading && _email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _email,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Nc.textOnDarkMuted,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                  const SizedBox(height: 14),
                  // Member badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: Ng.brand,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Nc.brand.withOpacity(0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAr ? 'عضو نشط' : 'ACTIVE MEMBER',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.8,
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
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: SizedBox(
        width: 40, height: 40,
        child: CircularProgressIndicator(
          color: Nc.brand,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildError(AppStrings s) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Nc.errorTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Nc.error,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _error ?? s.error,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Nc.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            NafajButton(
              label: s.tryAgain,
              icon: Icons.refresh_rounded,
              onTap: _loadProfile,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Wallet Card
// ─────────────────────────────────────────────────────────────────
class _WalletCard extends StatelessWidget {
  final String balance;
  final AppStrings s;
  final VoidCallback onTopUp;
  const _WalletCard({
    required this.balance,
    required this.s,
    required this.onTopUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: Ng.brand,
        borderRadius: BorderRadius.circular(Nr.xl),
        boxShadow: Ns.button,
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
                    s.availableBalanceLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.80),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    balance,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.22),
                  ),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onTopUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Nc.brand,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Nr.btn),
                ),
              ),
              child: Text(
                s.topUpBankak,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Nc.brand,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Stats Box
// ─────────────────────────────────────────────────────────────────
class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Nc.surfaceCard,
          borderRadius: BorderRadius.circular(Nr.lg),
          boxShadow: Ns.card,
          border: Border.all(color: Nc.borderLight),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Nc.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Nc.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Section Header
// ─────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF94A3B8),
            letterSpacing: 1.6,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Info Tile — shows real user data prominently
// ─────────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool ltr;
  final bool branded;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    this.ltr = false,
    this.branded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Nc.surfaceCard,
        borderRadius: BorderRadius.circular(Nr.card),
        boxShadow: Ns.card,
        border: Border.all(color: Nc.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: branded ? Ng.brand : null,
              color: branded ? null : Nc.surfaceDim,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Nc.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  textDirection: ltr ? TextDirection.ltr : null,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Nc.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Nc.borderLight,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Menu Item — navigation rows
// ─────────────────────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Nc.surfaceCard,
        borderRadius: BorderRadius.circular(Nr.card),
        border: Border.all(color: Nc.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Nc.surfaceDim,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Nc.textSecondary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Nc.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Nc.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFCBD5E1),
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Language Toggle
// ─────────────────────────────────────────────────────────────────
class _LanguageToggle extends StatelessWidget {
  final LocaleProvider locale;
  final AppStrings s;
  final bool isAr;

  const _LanguageToggle({
    required this.locale,
    required this.s,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => isAr ? locale.setEnglish() : locale.setArabic(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Nc.surfaceCard,
          borderRadius: BorderRadius.circular(Nr.card),
          border: Border.all(color: Nc.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: Ng.brand,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  isAr ? 'EN' : 'ع',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.changeLanguageLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Nc.textPrimary,
                    ),
                  ),
                  Text(
                    s.currentLanguageLabel,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Nc.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFCBD5E1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Logout Button
// ─────────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final AppStrings s;
  const _LogoutButton({required this.s});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: () async {
          await ApiService.logout();
          if (context.mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/nafaj_phone_login_screen',
            );
          }
        },
        icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
        label: Text(
          s.logoutAccount,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Nc.error,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Nr.btn),
          ),
        ),
      ),
    );
  }
}
