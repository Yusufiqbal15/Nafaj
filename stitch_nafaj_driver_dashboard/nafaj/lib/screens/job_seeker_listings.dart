import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../models/job_model.dart';
import '../widgets/nafaj_bottom_nav.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';
import '../theme/nafaj_theme.dart';

class JobSeekerListingsScreen extends StatefulWidget {
  const JobSeekerListingsScreen({super.key});

  @override
  State<JobSeekerListingsScreen> createState() =>
      _JobSeekerListingsScreenState();
}

class _JobSeekerListingsScreenState extends State<JobSeekerListingsScreen> {
  List<Job> _jobs = [];
  bool _isLoading = true;
  String _categoryId = '';
  String _categoryName = 'All Jobs';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments
        as Map<String, String>?;
    final newId = args?['categoryId'] ?? '';
    final newName = args?['categoryName'] ?? 'All Jobs';
    if (_categoryId != newId || _categoryName != newName) {
      _categoryId = newId;
      _categoryName = newName;
      _loadJobs();
    }
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);
    try {
      final response = _categoryId.isEmpty
          ? await ApiService.dio.get('/jobs')
          : await ApiService.dio.get('/jobs',
              queryParameters: {'sector': _categoryName});
      if (response.statusCode == 200 && mounted) {
        final raw = response.data['jobs'] as List? ?? [];
        setState(() {
          _jobs = raw
              .map<Job>((j) => Job.fromJson(j as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
            // ── Header ──────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: Nc.surfaceCard,
              elevation: 0,
              expandedHeight: 130,
              automaticallyImplyLeading: false,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: Nc.borderLight),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: Nc.surfaceDim,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Nc.borderLight),
                                ),
                                child: Icon(
                                  isAr
                                      ? Icons.arrow_forward_rounded
                                      : Icons.arrow_back_rounded,
                                  color: Nc.textPrimary,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _categoryId.isEmpty
                                        ? (isAr ? 'جميع الوظائف' : 'All Jobs')
                                        : _categoryName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Nc.textPrimary,
                                    ),
                                  ),
                                  if (!_isLoading)
                                    Text(
                                      isAr
                                          ? '${_jobs.length} ${s.jobsAvailable}'
                                          : '${_jobs.length} ${_jobs.length == 1 ? s.jobAvailableSingle : s.jobsAvailable}',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Nc.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: Nc.surfaceDim,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Nc.borderLight),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.tune_rounded,
                                      color: Nc.brand, size: 15),
                                  const SizedBox(width: 5),
                                  Text(
                                    s.filterLabel,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Nc.brand,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Search
                        Container(
                          height: 44,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Nc.bgWarm,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Nc.borderLight),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded,
                                  color: Nc.brand, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                isAr
                                    ? '${s.searchInLabel} ${_categoryId.isEmpty ? (isAr ? "الكل" : "All") : _categoryName}...'
                                    : '${s.searchInLabel} ${_categoryId.isEmpty ? "All" : _categoryName}...',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: Nc.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Loading ──────────────────────────────────────────
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Nc.brand),
                ),
              )

            // ── Empty ────────────────────────────────────────────
            else if (_jobs.isEmpty)
              SliverFillRemaining(
                child: _EmptyState(s: s, categoryName: _categoryName, isAr: isAr),
              )

            // ── Jobs List ────────────────────────────────────────
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _JobCard(
                        job: _jobs[i],
                        isNew: i == 0,
                        isAr: isAr,
                        s: s,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/job_details',
                          arguments: _jobs[i],
                        ),
                      ),
                    ),
                    childCount: _jobs.length,
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: NafajBottomNav(currentIndex: 3, onTap: (_) {}),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Empty State
// ─────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final AppStrings s;
  final String categoryName;
  final bool isAr;
  const _EmptyState(
      {required this.s, required this.categoryName, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Nc.brand.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.work_off_rounded,
                  color: Nc.brand, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              s.noJobsYet,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Nc.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.noJobsPosted,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Nc.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: Ng.brand,
                  borderRadius: BorderRadius.circular(Nr.btn),
                  boxShadow: Ns.button,
                ),
                child: Text(
                  isAr ? 'تصفح قطاعات أخرى' : 'Browse Other Categories',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Job Card
// ─────────────────────────────────────────────────────────────────
class _JobCard extends StatelessWidget {
  final Job job;
  final bool isNew;
  final bool isAr;
  final AppStrings s;
  final VoidCallback onTap;

  const _JobCard({
    required this.job,
    required this.isNew,
    required this.isAr,
    required this.s,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Nc.surfaceCard,
        borderRadius: BorderRadius.circular(Nr.xl),
        border: Border.all(color: Nc.borderLight),
        boxShadow: Ns.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // NEW badge
          if (isNew)
            Positioned(
              top: 0,
              right: isAr ? null : 0,
              left: isAr ? 0 : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  gradient: Ng.brand,
                  borderRadius: BorderRadius.only(
                    topLeft: isAr ? Radius.zero : const Radius.circular(Nr.xl),
                    topRight: isAr ? const Radius.circular(Nr.xl) : Radius.zero,
                    bottomRight: isAr ? Radius.zero : const Radius.circular(12),
                    bottomLeft: isAr ? const Radius.circular(12) : Radius.zero,
                  ),
                ),
                child: Text(
                  s.newLabel,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: Ng.brand,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Nc.brand.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(job.sectorIcon,
                          color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Nc.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            job.company,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: Nc.brand,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  job.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: Nc.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),

                // Tags row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Tag(
                        icon: Icons.location_on_rounded,
                        text: job.location),
                    _Tag(
                        icon: Icons.schedule_rounded,
                        text: isAr ? _translateJobType(job.jobType) : job.jobType),
                    _Tag(
                        icon: Icons.access_time_rounded,
                        text: isAr
                            ? _timeAgoAr(job.createdAt)
                            : 'Posted ${job.timeAgo}'),
                  ],
                ),
                const SizedBox(height: 14),
                Container(height: 1, color: Nc.borderLight),
                const SizedBox(height: 14),

                // Salary + Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.salaryTag,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Nc.textHint,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isAr && job.salary == 'Negotiable'
                              ? 'قابل للتفاوض'
                              : job.salary,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Nc.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 11),
                        decoration: BoxDecoration(
                          gradient: Ng.brand,
                          borderRadius: BorderRadius.circular(Nr.btn),
                          boxShadow: [
                            BoxShadow(
                              color: Nc.brand.withValues(alpha: 0.30),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          s.viewDetails,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _translateJobType(String type) {
    switch (type) {
      case 'Full-time': return 'دوام كامل';
      case 'Part-time': return 'دوام جزئي';
      case 'Contract': return 'عقد';
      case 'Flexible': return 'مرن';
      default: return type;
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

class _Tag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Tag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Nc.surfaceDim,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Nc.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Nc.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Nc.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
