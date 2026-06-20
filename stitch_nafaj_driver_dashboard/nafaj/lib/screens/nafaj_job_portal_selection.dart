import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/nafaj_bottom_nav.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';
import '../theme/nafaj_theme.dart';

class NafajJobPortalSelectionScreen extends StatelessWidget {
  const NafajJobPortalSelectionScreen({super.key});

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
            _HeroAppBar(isAr: isAr, s: s),
            SliverToBoxAdapter(child: _StatsRow(isAr: isAr)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 6),
                child: Text(
                  isAr ? 'اختر دورك' : 'CHOOSE YOUR ROLE',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 1.8,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _RoleCard(
                  title: s.iAmJobSeeker,
                  description: s.jobSeekerDesc,
                  icon: Icons.manage_search_rounded,
                  gradientColors: const [Color(0xFF1D4ED8), Color(0xFF1E40AF)],
                  accentColor: const Color(0xFF2563EB),
                  badgeText: isAr ? '٢٤٠٠+ وظيفة' : '2,400+ Jobs',
                  features: isAr
                      ? ['تصفح الوظائف', 'تقديم سريع', 'تتبع الطلبات']
                      : ['Browse Jobs', 'Quick Apply', 'Track Applications'],
                  onTap: () => Navigator.pushNamed(context, '/job_seeker_categories'),
                  isAr: isAr,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _RoleCard(
                  title: s.iAmEmployer,
                  description: s.employerDesc,
                  icon: Icons.business_center_rounded,
                  gradientColors: [Nc.brandVibrant, Nc.brandDeep],
                  accentColor: Nc.brand,
                  badgeText: isAr ? 'نشر مجاني' : 'Post Free',
                  features: isAr
                      ? ['نشر الوظائف', 'إدارة المتقدمين', 'تقارير المواهب']
                      : ['Post Jobs', 'Manage Applicants', 'Talent Reports'],
                  onTap: () => Navigator.pushNamed(context, '/job_creator_my_listings'),
                  isAr: isAr,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      s.needHelp,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    Text(
                      s.contactSupport,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Nc.brand,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
        bottomNavigationBar: NafajBottomNav(currentIndex: 3, onTap: (index) {}),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Hero SliverAppBar
// ─────────────────────────────────────────────────────────────────
class _HeroAppBar extends StatelessWidget {
  final bool isAr;
  final AppStrings s;
  const _HeroAppBar({required this.isAr, required this.s});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 230,
      pinned: true,
      backgroundColor: Nc.darkBg,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Icon(
              isAr ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: Ng.darkHero),
          child: Stack(
            children: [
              Positioned(
                right: -50, top: -50,
                child: Container(
                  width: 230, height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Nc.brand.withOpacity(0.07),
                  ),
                ),
              ),
              Positioned(
                left: -30, bottom: 20,
                child: Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Nc.brand.withOpacity(0.04),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: Ng.brand,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: Ns.button,
                        ),
                        child: const Icon(
                          Icons.work_history_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        s.welcomeToNafajJobs,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        s.jobsPortalSubtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Nc.textOnDarkMuted,
                          height: 1.5,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Stats Row
// ─────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final bool isAr;
  const _StatsRow({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Nc.surfaceCard,
        borderRadius: BorderRadius.circular(Nr.card),
        boxShadow: Ns.card,
      ),
      child: Row(
        children: [
          _StatItem(
            value: '2,400+',
            label: isAr ? 'وظيفة متاحة' : 'Jobs Available',
            color: const Color(0xFF2563EB),
          ),
          _divider(),
          _StatItem(
            value: '380+',
            label: isAr ? 'صاحب عمل' : 'Employers',
            color: Nc.brand,
          ),
          _divider(),
          _StatItem(
            value: '150+',
            label: isAr ? 'وظيفة اليوم' : 'Posted Today',
            color: Nc.success,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36,
        color: Nc.borderLight,
      );
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatItem({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Nc.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Role Selection Card
// ─────────────────────────────────────────────────────────────────
class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final Color accentColor;
  final String badgeText;
  final List<String> features;
  final VoidCallback onTap;
  final bool isAr;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.accentColor,
    required this.badgeText,
    required this.features,
    required this.onTap,
    required this.isAr,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Nc.surfaceCard,
          borderRadius: BorderRadius.circular(Nr.xl),
          boxShadow: Ns.elevated,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient header band
            Container(
              height: 115,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circle
                  Positioned(
                    right: isAr ? null : -24,
                    left: isAr ? -24 : null,
                    bottom: -28,
                    child: Container(
                      width: 130, height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    right: isAr ? null : 50,
                    left: isAr ? 50 : null,
                    top: -30,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon container
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.22),
                            ),
                          ),
                          child: Icon(icon, color: Colors.white, size: 28),
                        ),
                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.28),
                            ),
                          ),
                          child: Text(
                            badgeText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Card body
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Nc.textPrimary,
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradientColors),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          isAr
                              ? Icons.arrow_back_ios_new_rounded
                              : Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Nc.textSecondary,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Feature chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: features
                        .map(
                          (f) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11, vertical: 6),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(Nr.chip),
                              border: Border.all(
                                color: accentColor.withOpacity(0.18),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: accentColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  f,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
