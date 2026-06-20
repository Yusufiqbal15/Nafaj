import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/nafaj_bottom_nav.dart';
import '../models/job_model.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';
import '../theme/nafaj_theme.dart';

class JobDetailsContactInfoScreen extends StatelessWidget {
  final Job job;
  const JobDetailsContactInfoScreen({super.key, required this.job});

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
            // ── Hero SliverAppBar ────────────────────────────────
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: Nc.darkBg,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Icon(
                      isAr
                          ? Icons.arrow_forward_rounded
                          : Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: const Icon(
                      Icons.share_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
              title: Text(
                s.jobDetailsTitle,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: _HeroBackground(job: job, isAr: isAr),
              ),
            ),

            // ── Content ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Job info card
                      _JobInfoCard(job: job, isAr: isAr, s: s),
                      const SizedBox(height: 16),

                      // Description card
                      _DescriptionCard(job: job, isAr: isAr, s: s),
                      const SizedBox(height: 16),

                      // Contact card
                      _ContactCard(
                          job: job, isAr: isAr, s: s, context: context),
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // ── Apply Now FAB ─────────────────────────────────────────
        bottomNavigationBar: NafajBottomNav(currentIndex: 3, onTap: (_) {}),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 70),
          child: GestureDetector(
            onTap: () => _launchWhatsApp(context, job.phone),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: Ng.brand,
                borderRadius: BorderRadius.circular(Nr.btn),
                boxShadow: Ns.button,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.send_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    s.applyNow,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  void _launchWhatsApp(BuildContext context, String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/249$clean');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

}

// ─────────────────────────────────────────────────────────────────
//  Hero Background
// ─────────────────────────────────────────────────────────────────
class _HeroBackground extends StatelessWidget {
  final Job job;
  final bool isAr;
  const _HeroBackground({required this.job, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: Ng.darkHero),
      child: Stack(
        children: [
          Positioned(
            right: -50, top: -50,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Nc.brand.withValues(alpha: 0.07),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Sector icon + type badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: Ng.brand,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: Ns.button,
                        ),
                        child: Icon(job.sectorIcon,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Text(
                          isAr
                              ? _translateJobType(job.jobType)
                              : job.jobType,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Nc.success.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Nc.success.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_rounded,
                                color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              isAr
                                  ? _timeAgoAr(job.createdAt)
                                  : job.timeAgo,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    job.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.company,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Nc.textOnDarkMuted,
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

  String _translateJobType(String t) {
    switch (t) {
      case 'Full-time': return 'دوام كامل';
      case 'Part-time': return 'دوام جزئي';
      case 'Contract': return 'عقد';
      case 'Flexible': return 'مرن';
      default: return t;
    }
  }

  String _timeAgoAr(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 7) return 'منذ ${diff.inDays ~/ 7} أسبوع';
    if (diff.inDays > 0) return 'منذ ${diff.inDays} يوم';
    if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
    return 'الآن';
  }
}

// ─────────────────────────────────────────────────────────────────
//  Job Info Card
// ─────────────────────────────────────────────────────────────────
class _JobInfoCard extends StatelessWidget {
  final Job job;
  final bool isAr;
  final AppStrings s;
  const _JobInfoCard(
      {required this.job, required this.isAr, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Nc.surfaceCard,
        borderRadius: BorderRadius.circular(Nr.xl),
        border: Border.all(color: Nc.borderLight),
        boxShadow: Ns.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sector chip
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Nc.surfaceDim,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Nc.borderLight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.category_rounded,
                    color: Nc.brand, size: 13),
                const SizedBox(width: 5),
                Text(
                  job.sector,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Nc.brand,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Stats row
          Row(
            children: [
              _InfoChip(
                icon: Icons.location_on_rounded,
                label: isAr ? 'الموقع' : 'Location',
                value: job.location,
              ),
              const SizedBox(width: 12),
              _InfoChip(
                icon: Icons.payments_rounded,
                label: s.salaryTag,
                value: isAr && job.salary == 'Negotiable'
                    ? 'قابل للتفاوض'
                    : job.salary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoChip(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Nc.bgWarm,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Nc.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: Nc.textHint),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Nc.textHint,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Nc.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Description Card
// ─────────────────────────────────────────────────────────────────
class _DescriptionCard extends StatelessWidget {
  final Job job;
  final bool isAr;
  final AppStrings s;
  const _DescriptionCard(
      {required this.job, required this.isAr, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Nc.surfaceCard,
        borderRadius: BorderRadius.circular(Nr.xl),
        border: Border.all(color: Nc.borderLight),
        boxShadow: Ns.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.jobDescriptionLabel,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Nc.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            job.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Nc.textSecondary,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 16),
          // Info banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF2563EB).withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: Color(0xFF2563EB), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isAr
                        ? 'نُشر ${_timeAgoAr(job.createdAt)} • ${_translateJobType(job.jobType)}'
                        : 'Posted ${job.timeAgo} • ${job.jobType}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1D4ED8),
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

  String _translateJobType(String t) {
    switch (t) {
      case 'Full-time': return 'دوام كامل';
      case 'Part-time': return 'دوام جزئي';
      case 'Contract': return 'عقد';
      case 'Flexible': return 'مرن';
      default: return t;
    }
  }

  String _timeAgoAr(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 7) return 'منذ ${diff.inDays ~/ 7} أسبوع';
    if (diff.inDays > 0) return 'منذ ${diff.inDays} يوم';
    if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
    return 'الآن';
  }
}

// ─────────────────────────────────────────────────────────────────
//  Contact Card
// ─────────────────────────────────────────────────────────────────
class _ContactCard extends StatelessWidget {
  final Job job;
  final bool isAr;
  final AppStrings s;
  final BuildContext context;
  const _ContactCard({
    required this.job,
    required this.isAr,
    required this.s,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Nc.surfaceCard,
        borderRadius: BorderRadius.circular(Nr.xl),
        border: Border.all(color: Nc.borderLight),
        boxShadow: Ns.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.contactEmployer,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Nc.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Posted-by row
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: Ng.brand,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Nc.brand.withValues(alpha: 0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.postedBy,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Nc.textSecondary,
                      ),
                    ),
                    Text(
                      job.company,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Nc.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // WhatsApp button
          _ContactButton(
            icon: Icons.chat_bubble_rounded,
            color: const Color(0xFF25D366),
            label: s.whatsappLabel,
            subtitle: '+249 ${job.phone}',
            onTap: () => _launchWhatsApp(ctx, job.phone),
          ),
          const SizedBox(height: 10),

          // Phone call button
          _ContactButton(
            icon: Icons.phone_rounded,
            color: Nc.brand,
            label: s.phoneCallLabel,
            subtitle: '+249 ${job.phone}',
            onTap: () => _makePhoneCall(ctx, job.phone),
          ),
        ],
      ),
    );
  }

  void _launchWhatsApp(BuildContext ctx, String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/249$clean');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _makePhoneCall(BuildContext ctx, String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('tel:+249$clean');
    try {
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    } catch (_) {}
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(Nr.card),
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Nc.textPrimary,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Nc.borderLight, size: 22),
          ],
        ),
      ),
    );
  }
}
