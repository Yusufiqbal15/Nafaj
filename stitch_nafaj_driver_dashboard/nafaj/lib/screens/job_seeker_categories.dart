import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/job_service.dart';
import '../services/api_service.dart';
import '../models/job_model.dart';
import '../widgets/nafaj_bottom_nav.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';
import '../theme/nafaj_theme.dart';

// Arabic display names for each category id
const _arNames = <String, String>{
  'programming': 'برمجة',
  'web_design': 'تصميم مواقع',
  'graphic_design': 'تصميم جرافيك',
  'teaching': 'تدريس',
  'driver': 'سائق',
  'delivery': 'توصيل',
  'construction': 'إنشاء وبناء',
  'healthcare': 'رعاية صحية',
  'engineering': 'هندسة',
  'accounting': 'محاسبة ومالية',
  'marketing': 'تسويق ومبيعات',
  'customer_service': 'خدمة عملاء',
  'technology': 'تقنية ومعلومات',
  'agriculture': 'زراعة',
  'retail': 'تجارة التجزئة',
  'transport': 'نقل ولوجستيات',
  'security': 'أمن وحراسة',
  'hospitality': 'ضيافة وفندقة',
  'cleaning': 'تنظيف',
  'electrician': 'كهربائي',
  'plumbing': 'سباكة',
  'data_entry': 'إدخال بيانات',
  'photography': 'تصوير',
  'cooking': 'طبخ وتقديم طعام',
  'tailoring': 'خياطة وأزياء',
  'mechanic': 'ميكانيكا',
  'education': 'تعليم',
};

class JobSeekerCategoriesScreen extends StatefulWidget {
  const JobSeekerCategoriesScreen({super.key});

  @override
  State<JobSeekerCategoriesScreen> createState() =>
      _JobSeekerCategoriesScreenState();
}

class _JobSeekerCategoriesScreenState
    extends State<JobSeekerCategoriesScreen> {
  Map<String, int> _jobCounts = {};
  bool _isLoading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadJobCounts();
  }

  Future<void> _loadJobCounts() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.dio.get('/jobs');
      if (response.statusCode == 200 && mounted) {
        final rawJobs = response.data['jobs'] as List? ?? [];
        final jobs = rawJobs
            .map<Job>((j) => Job.fromJson(j as Map<String, dynamic>))
            .toList();
        final Map<String, int> counts = {};
        for (final job in jobs) {
          counts[job.sector] = (counts[job.sector] ?? 0) + 1;
        }
        setState(() {
          _jobCounts = counts;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<JobCategory> get _filtered {
    if (_search.isEmpty) return JobService.categories;
    final q = _search.toLowerCase();
    return JobService.categories.where((c) {
      final arName = _arNames[c.id] ?? '';
      return c.name.toLowerCase().contains(q) ||
          arName.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final s = AppStrings.direct(isArabic: locale.isArabic);
    final isAr = locale.isArabic;
    final categories = _filtered;
    final totalJobs = _jobCounts.values.fold(0, (a, b) => a + b);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Nc.bgWarm,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Hero Header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).padding.top + 16, 20, 32),
                decoration: BoxDecoration(
                  gradient: Ng.brand,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: Ns.button,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
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
                        Text(
                          s.browseJobs,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      s.findDreamJob,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAr
                          ? 'استكشف ${JobService.categories.length} قطاعاً في السودان'
                          : 'Explore ${JobService.categories.length} industries across Sudan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Search bar
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: Nc.brand,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              onChanged: (v) =>
                                  setState(() => _search = v),
                              textDirection: TextDirection.ltr,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Nc.textPrimary,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: s.searchCategories,
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: Nc.textHint,
                                ),
                              ),
                            ),
                          ),
                          if (_search.isNotEmpty)
                            GestureDetector(
                              onTap: () => setState(() => _search = ''),
                              child: Icon(
                                Icons.close_rounded,
                                color: Nc.textHint,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Stats + Section Title ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 22,
                      decoration: BoxDecoration(
                        gradient: Ng.brand,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      s.allIndustries,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Nc.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (!_isLoading && totalJobs > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: Ng.brand,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isAr
                              ? '$totalJobs وظيفة'
                              : '$totalJobs jobs',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      )
                    else
                      Text(
                        isAr
                            ? '${categories.length} ${s.sectorsCount}'
                            : '${categories.length} ${s.sectorsCount}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Nc.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Loading ───────────────────────────────────────────
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: Nc.brand),
                  ),
                ),
              )
            else

            // ── Categories Grid ───────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final cat = categories[i];
                    final count = _jobCounts[cat.name] ?? 0;
                    return _CategoryCard(
                      cat: cat,
                      jobCount: count,
                      isAr: isAr,
                      arName: _arNames[cat.id] ?? cat.name,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/job_seeker_listings',
                        arguments: {
                          'categoryId': cat.id,
                          'categoryName': cat.name,
                        },
                      ),
                    );
                  },
                  childCount: categories.length,
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

class _CategoryCard extends StatelessWidget {
  final JobCategory cat;
  final int jobCount;
  final bool isAr;
  final String arName;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.cat,
    required this.jobCount,
    required this.isAr,
    required this.arName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Nc.surfaceCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cat.color.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: cat.color.withValues(alpha: 0.09),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: cat.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(cat.icon, color: cat.color, size: 26),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                isAr ? arName : cat.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isAr ? 11 : 10,
                  fontWeight: FontWeight.w700,
                  color: Nc.textPrimary,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: jobCount > 0
                    ? cat.color.withValues(alpha: 0.10)
                    : Nc.surfaceDim,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                jobCount > 0
                    ? (isAr ? '$jobCount وظيفة' : '$jobCount ${jobCount == 1 ? "job" : "jobs"}')
                    : (isAr ? 'لا يوجد' : 'None'),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: jobCount > 0 ? cat.color : Nc.textHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
