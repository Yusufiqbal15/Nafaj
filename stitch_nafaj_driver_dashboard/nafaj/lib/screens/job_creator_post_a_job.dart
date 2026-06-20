import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/job_service.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';
import '../theme/nafaj_theme.dart';

class JobCreatorPostAJobScreen extends StatefulWidget {
  const JobCreatorPostAJobScreen({super.key});

  @override
  State<JobCreatorPostAJobScreen> createState() =>
      _JobCreatorPostAJobScreenState();
}

class _JobCreatorPostAJobScreenState
    extends State<JobCreatorPostAJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _creatorNameCtrl = TextEditingController();
  final _jobTitleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController(text: 'Khartoum, SD');
  final _salaryCtrl = TextEditingController();

  String _selectedSector = '';
  String _selectedJobType = 'Full-time';
  bool _isSubmitting = false;
  int _totalJobs = 0;

  // Job type options with Arabic translation
  static const _jobTypes = ['Full-time', 'Part-time', 'Contract', 'Flexible'];
  static const _jobTypesAr = ['دوام كامل', 'دوام جزئي', 'عقد', 'مرن'];

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  @override
  void dispose() {
    _creatorNameCtrl.dispose();
    _jobTitleCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _salaryCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCount() async {
    final count = await JobService.fetchTotalCount();
    if (mounted) setState(() => _totalJobs = count);
  }

  void _postJob(AppStrings s, bool isAr) {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedSector.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.selectSectorFirst),
          backgroundColor: Nc.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    _submitJob(s, isAr);
  }

  Future<void> _submitJob(AppStrings s, bool isAr) async {
    final title = _jobTitleCtrl.text.trim();
    final result = await JobService.createJob(
      title: title,
      description: _descCtrl.text.trim(),
      company: _creatorNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      sector: _selectedSector,
      jobType: _selectedJobType,
      salaryText: _salaryCtrl.text.trim().isEmpty
          ? s.negotiable
          : _salaryCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      _showSuccessDialog(context, title, s, isAr);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              result['error'] ?? (isAr ? 'فشل النشر' : 'Failed to post job')),
          backgroundColor: Nc.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showSuccessDialog(
      BuildContext ctx, String title, AppStrings s, bool isAr) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Nr.xxl),
        ),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76, height: 76,
              decoration: BoxDecoration(
                gradient: Ng.brand,
                shape: BoxShape.circle,
                boxShadow: Ns.button,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              s.jobPostedTitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Nc.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"$title" ${s.jobPostedDesc}',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Nc.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  Navigator.pushReplacementNamed(
                      ctx, '/job_creator_my_listings');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Nc.brand,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Nr.btn),
                  ),
                ),
                child: Text(
                  s.viewMyListings,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                _clearForm();
                _loadCount();
              },
              child: Text(
                s.postAnotherJob,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: Nc.brand,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearForm() {
    _creatorNameCtrl.clear();
    _jobTitleCtrl.clear();
    _descCtrl.clear();
    _phoneCtrl.clear();
    _salaryCtrl.clear();
    _locationCtrl.text = 'Khartoum, SD';
    setState(() {
      _selectedSector = '';
      _selectedJobType = 'Full-time';
    });
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
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
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
              ),
              title: Text(
                s.postAJob,
                style: GoogleFonts.plusJakartaSans(
                  color: Nc.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              centerTitle: true,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pushNamed(
                      context, '/job_creator_my_listings'),
                  child: Text(
                    s.myJobs,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Nc.brand,
                    ),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: Nc.borderLight),
              ),
            ),

            // ── Form Body ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats card
                      _StatsCard(totalJobs: _totalJobs, isAr: isAr, s: s),
                      const SizedBox(height: 28),

                      // Section heading
                      Text(
                        s.tellUsWhatYouNeed,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Nc.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.postJobSubtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Nc.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Fields
                      _FormField(
                        label: s.creatorName,
                        controller: _creatorNameCtrl,
                        hint: s.creatorNameHint,
                        icon: Icons.person_rounded,
                        s: s,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? s.requiredField
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _FormField(
                        label: s.jobTitle,
                        controller: _jobTitleCtrl,
                        hint: s.jobTitleHint,
                        icon: Icons.work_rounded,
                        s: s,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? s.requiredField
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Sector dropdown
                      _SectorDropdown(
                        selected: _selectedSector,
                        isAr: isAr,
                        s: s,
                        onChanged: (v) =>
                            setState(() => _selectedSector = v ?? ''),
                      ),
                      const SizedBox(height: 16),

                      // Job type chips
                      _JobTypeChips(
                        selected: _selectedJobType,
                        jobTypes: _jobTypes,
                        jobTypesAr: _jobTypesAr,
                        isAr: isAr,
                        s: s,
                        onSelected: (v) =>
                            setState(() => _selectedJobType = v),
                      ),
                      const SizedBox(height: 16),

                      _FormField(
                        label: s.locationLabel,
                        controller: _locationCtrl,
                        hint: s.locationHint,
                        icon: Icons.location_on_rounded,
                        s: s,
                      ),
                      const SizedBox(height: 16),
                      _FormField(
                        label: s.salaryLabel,
                        controller: _salaryCtrl,
                        hint: s.salaryHint,
                        icon: Icons.payments_rounded,
                        s: s,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      _DescriptionField(
                        controller: _descCtrl,
                        isAr: isAr,
                        s: s,
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      _PhoneField(
                        controller: _phoneCtrl,
                        s: s,
                        isAr: isAr,
                      ),
                      const SizedBox(height: 32),

                      // Submit button
                      GestureDetector(
                        onTap: _isSubmitting
                            ? null
                            : () => _postJob(s, isAr),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: _isSubmitting
                                ? null
                                : Ng.brandVertical,
                            color: _isSubmitting
                                ? Nc.brand.withValues(alpha: 0.4)
                                : null,
                            borderRadius: BorderRadius.circular(Nr.btn),
                            boxShadow:
                                _isSubmitting ? null : Ns.button,
                          ),
                          child: Center(
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 24, height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        s.postJobBtn,
                                        style:
                                            GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(Icons.send_rounded,
                                          color: Colors.white, size: 20),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
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
//  Stats Card
// ─────────────────────────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  final int totalJobs;
  final bool isAr;
  final AppStrings s;
  const _StatsCard(
      {required this.totalJobs, required this.isAr, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: Ng.brand,
        borderRadius: BorderRadius.circular(Nr.xl),
        boxShadow: Ns.button,
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.work_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.totalJobsPosted,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$totalJobs',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.trending_up_rounded,
              color: Colors.white.withValues(alpha: 0.40), size: 44),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Reusable Form Field
// ─────────────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final AppStrings s;
  final String? Function(String?)? validator;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.s,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Nc.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: Nc.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              color: Nc.textHint,
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: Nc.textHint, size: 19),
            filled: true,
            fillColor: Nc.surfaceCard,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Nr.card),
              borderSide: BorderSide(color: Nc.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Nr.card),
              borderSide: BorderSide(color: Nc.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Nr.card),
              borderSide: const BorderSide(color: Nc.brand, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Nr.card),
              borderSide: const BorderSide(color: Nc.error),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Sector Dropdown
// ─────────────────────────────────────────────────────────────────
class _SectorDropdown extends StatelessWidget {
  final String selected;
  final bool isAr;
  final AppStrings s;
  final ValueChanged<String?> onChanged;
  const _SectorDropdown({
    required this.selected,
    required this.isAr,
    required this.s,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.sectorLabel,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Nc.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Nc.surfaceCard,
            borderRadius: BorderRadius.circular(Nr.card),
            border: Border.all(color: Nc.borderLight),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: selected.isEmpty ? null : selected,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.category_rounded,
                  color: Nc.textHint, size: 19),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              hintText: s.selectSector,
              hintStyle: GoogleFonts.plusJakartaSans(
                color: Nc.textHint,
                fontSize: 14,
              ),
            ),
            isExpanded: true,
            icon: Icon(Icons.expand_more_rounded, color: Nc.textHint),
            items: JobService.sectorNames.map((sector) {
              return DropdownMenuItem(
                value: sector,
                child: Text(
                  sector,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Nc.textPrimary,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Job Type Chips
// ─────────────────────────────────────────────────────────────────
class _JobTypeChips extends StatelessWidget {
  final String selected;
  final List<String> jobTypes;
  final List<String> jobTypesAr;
  final bool isAr;
  final AppStrings s;
  final ValueChanged<String> onSelected;

  const _JobTypeChips({
    required this.selected,
    required this.jobTypes,
    required this.jobTypesAr,
    required this.isAr,
    required this.s,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.jobTypeLabel,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Nc.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(jobTypes.length, (i) {
            final type = jobTypes[i];
            final label = isAr ? jobTypesAr[i] : type;
            final isSelected = selected == type;
            return GestureDetector(
              onTap: () => onSelected(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected ? Ng.brand : null,
                  color: isSelected ? null : Nc.surfaceCard,
                  borderRadius: BorderRadius.circular(Nr.chip),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Nc.borderLight,
                    width: 1.5,
                  ),
                  boxShadow: isSelected ? Ns.button : null,
                ),
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Nc.textSecondary,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Description Field
// ─────────────────────────────────────────────────────────────────
class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final bool isAr;
  final AppStrings s;
  const _DescriptionField(
      {required this.controller, required this.isAr, required this.s});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.jobDescriptionLabel,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Nc.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 4,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? s.requiredField : null,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 14, color: Nc.textPrimary),
          decoration: InputDecoration(
            hintText: s.jobDescHint,
            hintStyle: GoogleFonts.plusJakartaSans(
                color: Nc.textHint, fontSize: 13),
            filled: true,
            fillColor: Nc.surfaceCard,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Nr.card),
              borderSide: BorderSide(color: Nc.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Nr.card),
              borderSide: BorderSide(color: Nc.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Nr.card),
              borderSide: const BorderSide(color: Nc.brand, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Nr.card),
              borderSide: const BorderSide(color: Nc.error),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Phone Field
// ─────────────────────────────────────────────────────────────────
class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final AppStrings s;
  final bool isAr;
  const _PhoneField(
      {required this.controller, required this.s, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.phoneNumber,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Nc.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Nc.surfaceDim,
                borderRadius: BorderRadius.circular(Nr.card),
                border: Border.all(color: Nc.borderLight),
              ),
              child: Center(
                child: Text(
                  '+249',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Nc.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? s.requiredField
                    : null,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: Nc.textPrimary),
                decoration: InputDecoration(
                  hintText: '912 345 678',
                  hintStyle: GoogleFonts.plusJakartaSans(
                      color: Nc.textHint, fontSize: 14),
                  filled: true,
                  fillColor: Nc.surfaceCard,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Nr.card),
                    borderSide: BorderSide(color: Nc.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Nr.card),
                    borderSide: BorderSide(color: Nc.borderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Nr.card),
                    borderSide:
                        const BorderSide(color: Nc.brand, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Nr.card),
                    borderSide: const BorderSide(color: Nc.error),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
