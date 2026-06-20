import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';
import '../theme/nafaj_theme.dart';
import '../services/api_service.dart';
import '../models/job_model.dart';

class JobCreatorMyListingsScreen extends StatefulWidget {
  const JobCreatorMyListingsScreen({super.key});

  @override
  State<JobCreatorMyListingsScreen> createState() =>
      _JobCreatorMyListingsScreenState();
}

class _JobCreatorMyListingsScreenState
    extends State<JobCreatorMyListingsScreen>
    with SingleTickerProviderStateMixin {
  List<Job> _jobs = [];
  bool _isLoading = true;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadMyJobs();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMyJobs() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.dio.get('/jobs');
      if (response.statusCode == 200 && mounted) {
        final rawJobs = response.data['jobs'] as List? ?? [];
        final fetched = rawJobs
            .map<Job>((j) => Job.fromJson(j as Map<String, dynamic>))
            .toList();
        setState(() {
          _jobs = fetched;
          _isLoading = false;
        });
        _fadeCtrl.forward(from: 0);
      }
    } catch (_) {
      if (mounted) setState(() { _jobs = []; _isLoading = false; });
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
        appBar: _buildAppBar(s),
        body: _isLoading ? _buildLoader() : _buildBody(s, isAr),
        floatingActionButton: _buildFAB(s),
        bottomNavigationBar: _buildBottomNav(s),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppStrings s) {
    return AppBar(
      backgroundColor: Nc.surfaceCard,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: Nc.textPrimary, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        s.myListings,
        style: GoogleFonts.inter(
          color: Nc.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search_rounded, color: Nc.textPrimary, size: 22),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.tune_rounded, color: Nc.textPrimary, size: 22),
          onPressed: () {},
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFCC5500).withOpacity(0.12)),
      ),
    );
  }

  Widget _buildLoader() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCC5500)),
      ),
    );
  }

  Widget _buildBody(AppStrings s, bool isAr) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildStatsCard(s),
          const SizedBox(height: 20),
          _buildSectionHeader(s),
          const SizedBox(height: 12),
          Expanded(child: _buildJobsList(s, isAr)),
        ],
      ),
    );
  }

  Widget _buildStatsCard(AppStrings s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFCC5500), Color(0xFFE8691A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFCC5500).withOpacity(0.30),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: Icons.work_outline_rounded,
                value: '${_jobs.length}',
                label: s.totalJobsPosted,
              ),
            ),
            _buildDivider(),
            Expanded(
              child: _buildStatItem(
                icon: Icons.remove_red_eye_outlined,
                value: '${_jobs.length * 150}',
                label: s.totalViews,
              ),
            ),
            _buildDivider(),
            Expanded(
              child: _buildStatItem(
                icon: Icons.groups_outlined,
                value: '${_jobs.length * 8}',
                label: s.totalApplicants,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 44,
      color: Colors.white.withOpacity(0.25),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.80),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(AppStrings s) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            s.activeJobsCount(_jobs.length),
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Nc.textPrimary,
            ),
          ),
          if (_jobs.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF16A34A).withOpacity(0.20),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    s.allActive,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJobsList(AppStrings s, bool isAr) {
    if (_jobs.isEmpty) return _buildEmptyState(s);
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: _jobs.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildJobCard(_jobs[i], s, isAr),
      ),
    );
  }

  Widget _buildEmptyState(AppStrings s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFCC5500).withOpacity(0.08),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.post_add_rounded,
              color: Color(0xFFCC5500),
              size: 44,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            s.noJobsPostedYet,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Nc.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.tapToPostFirstJob,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Nc.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Job job, AppStrings s, bool isAr) {
    const primary = Color(0xFFCC5500);
    return Container(
      decoration: BoxDecoration(
        color: Nc.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top accent bar
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFCC5500), Color(0xFFE8691A)],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF16A34A).withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF16A34A),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            s.activeStatus,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      s.postedTimeAgo(job.timeAgo),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Nc.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Job identity
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: primary.withOpacity(0.12)),
                      ),
                      child: Icon(job.sectorIcon, color: primary, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Nc.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            job.sector,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Nc.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChip(Icons.location_on_outlined, job.location),
                    _buildChip(Icons.schedule_outlined, job.jobType),
                  ],
                ),
                const SizedBox(height: 14),

                // Salary
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: primary.withOpacity(0.12)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.payments_outlined, size: 15, color: primary),
                      const SizedBox(width: 7),
                      Text(
                        job.salary,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Nc.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Mini analytics row
                Row(
                  children: [
                    _buildMiniStat(Icons.remove_red_eye_outlined, '${150}'),
                    const SizedBox(width: 16),
                    _buildMiniStat(Icons.people_outline_rounded, '${8}'),
                  ],
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            s.viewApplicants,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 44,
                      width: 44,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: BorderSide(color: primary.withOpacity(0.25)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Icon(Icons.edit_outlined, color: primary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      width: 44,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: BorderSide(color: primary.withOpacity(0.25)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Icon(Icons.more_horiz_rounded, color: primary, size: 18),
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

  Widget _buildChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Nc.textSecondary),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Nc.textSecondary),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Nc.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFAB(AppStrings s) {
    return FloatingActionButton.extended(
      onPressed: () async {
        await Navigator.pushNamed(context, '/job_creator_post_a_job');
        _loadMyJobs();
      },
      backgroundColor: const Color(0xFFCC5500),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        s.postJobBtn,
        style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }

  Widget _buildBottomNav(AppStrings s) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Nc.surfaceCard,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/nafaj_home_exact_header_match'),
                child: _buildNavItem(Icons.home_rounded, s.navHome, false),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/nafaj_job_portal_selection'),
                child: _buildNavItem(Icons.work_rounded, s.navJobsPortal, true),
              ),
              _buildNavItem(Icons.chat_bubble_outline_rounded, s.navMessages, false),
              _buildNavItem(Icons.person_outline_rounded, s.navProfileUser, false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    const primary = Color(0xFFCC5500);
    final color = isActive ? primary : const Color(0xFF94A3B8);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isActive)
          Container(
            width: 32,
            height: 3,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 3),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
