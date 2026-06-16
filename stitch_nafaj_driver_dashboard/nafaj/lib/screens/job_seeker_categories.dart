import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/job_service.dart';
import '../services/api_service.dart';
import '../models/job_model.dart';
import '../widgets/nafaj_bottom_nav.dart';

class JobSeekerCategoriesScreen extends StatefulWidget {
  const JobSeekerCategoriesScreen({super.key});

  @override
  State<JobSeekerCategoriesScreen> createState() => _JobSeekerCategoriesScreenState();
}

class _JobSeekerCategoriesScreenState extends State<JobSeekerCategoriesScreen> {
  Map<String, int> _jobCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJobCounts();
  }

  Future<void> _loadJobCounts() async {
    setState(() => _isLoading = true);

    try {
      // Fetch all jobs from backend
      final response = await ApiService.dio.get('/jobs');
      
      if (response.statusCode == 200 && mounted) {
        final rawJobs = response.data['jobs'] as List? ?? [];
        final jobs = rawJobs.map<Job>((j) => Job.fromJson(j as Map<String, dynamic>)).toList();
        
        // Count jobs by sector
        final Map<String, int> counts = {};
        for (final job in jobs) {
          final sector = job.sector;
          counts[sector] = (counts[sector] ?? 0) + 1;
        }
        
        setState(() {
          _jobCounts = counts;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading job counts: $e');
      if (mounted) {
        setState(() {
          _jobCounts = {};
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFCC5500);
    const Color bgColor = Color(0xFFF8F9FA);
    const Color darkSlate = Color(0xFF0F172A);
    final categories = JobService.categories;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Orange Header ──
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFCC5500), Color(0xFFE67E22)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      Text(
                        'Browse Jobs',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Find Your\nDream Job',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore ${categories.length} industries across Sudan',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search bar
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF94A3B8),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Search categories...',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Section Title ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'All Industries',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: darkSlate,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${categories.length} sectors',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Categories Grid ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final cat = categories[index];
                final jobCount = _jobCounts[cat.name] ?? 0;
                return _buildCategoryCard(context, cat, jobCount);
              }, childCount: categories.length),
            ),
          ),
        ],
      ),

      bottomNavigationBar: NafajBottomNav(currentIndex: 3, onTap: (index) {}),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    JobCategory cat,
    int jobCount,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/job_seeker_listings',
          arguments: {'categoryId': cat.id, 'categoryName': cat.name},
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cat.color.withOpacity(0.12), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: cat.color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cat.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(cat.icon, color: cat.color, size: 28),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                cat.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155),
                  height: 1.2,
                ),
              ),
            ),
            if (jobCount > 0) ...[
              const SizedBox(height: 4),
              Text(
                '$jobCount ${jobCount == 1 ? 'job' : 'jobs'}',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: cat.color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
