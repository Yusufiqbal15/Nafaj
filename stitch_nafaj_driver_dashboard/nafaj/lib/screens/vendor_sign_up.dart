import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../services/api_service.dart';

class VendorSignUpScreen extends StatefulWidget {
  const VendorSignUpScreen({super.key});

  @override
  State<VendorSignUpScreen> createState() => _VendorSignUpScreenState();
}

class _VendorSignUpScreenState extends State<VendorSignUpScreen> {
  int _currentStep = 0;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  // ── Step 1: Owner Info ──
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();

  // ── Step 2: Business Documents ──
  final TextEditingController _tradeLicenseController =
      TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _taxIdController = TextEditingController();

  // ── Step 3: Shop Details ──
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _shopAddressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _businessPhoneController =
      TextEditingController();
  final TextEditingController _openingHoursController =
      TextEditingController();
  final TextEditingController _closingHoursController =
      TextEditingController();

  @override
  void dispose() {
    _ownerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nationalIdController.dispose();
    _tradeLicenseController.dispose();
    _gstController.dispose();
    _taxIdController.dispose();
    _shopNameController.dispose();
    _shopAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _businessPhoneController.dispose();
    _openingHoursController.dispose();
    _closingHoursController.dispose();
    super.dispose();
  }

  bool _validateStep0() {
    if (_ownerNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _nationalIdController.text.trim().isEmpty) {
      _showSnack('Please fill all required fields in Step 1');
      return false;
    }
    final rawPhone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (rawPhone.length < 10) {
      _showSnack('Phone number must be at least 10 digits');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnack('Passwords do not match');
      return false;
    }
    return true;
  }

  bool _validateStep1() {
    if (_tradeLicenseController.text.trim().isEmpty ||
        _taxIdController.text.trim().isEmpty) {
      _showSnack('Please fill required business document fields');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_shopNameController.text.trim().isEmpty ||
        _shopAddressController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _businessPhoneController.text.trim().isEmpty) {
      _showSnack('Please fill all required shop detail fields');
      return false;
    }
    final rawBizPhone = _businessPhoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (rawBizPhone.length < 10) {
      _showSnack('Business phone must be at least 10 digits');
      return false;
    }
    if (!_agreedToTerms) {
      _showSnack('Please agree to Terms of Service');
      return false;
    }
    return true;
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      String phone = _phoneController.text.trim();

      // Split owner name into first and last name
      final nameParts = _ownerNameController.text.trim().split(' ');
      final ownerFirstName = nameParts.first;
      final ownerLastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final result = await ApiService.vendorRegister(
        email: _emailController.text.trim(),
        phone: phone,
        password: _passwordController.text,
        businessName: _shopNameController.text.trim(),
        ownerFirstName: ownerFirstName,
        ownerLastName: ownerLastName,
        businessType: 'General', // Can be made dynamic
        shopAddress: _shopAddressController.text.trim(),
        city: _cityController.text.trim(),
        ntnNumber: _taxIdController.text.trim(),
      );

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Awaiting admin approval.')),
        );
        // Navigate to pending approval screen — admin must approve before accessing dashboard
        Navigator.pushReplacementNamed(
          context,
          '/pending_approval',
          arguments: {'userType': 'vendor'},
        );
      } else {
        _showSnack(result['error'] ?? 'فشل إنشاء الحساب');
      }
    } catch (e) {
      if (mounted) _showSnack('خطأ: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFCC5500);
    const Color bgColor = Color(0xFFFFFBF7);
    const Color darkSlate = Color(0xFF0F172A);
    const Color textGrey = Color(0xFF475569);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: darkSlate, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Vendor Registration',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkSlate),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Step ${_currentStep + 1}/3',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Progress Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? primaryColor
                            : primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 8),

            // ── Body ──
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _currentStep == 0
                    ? _buildOwnerInfoStep(primaryColor, darkSlate, textGrey)
                    : _currentStep == 1
                        ? _buildBusinessDocsStep(
                            primaryColor, darkSlate, textGrey)
                        : _buildShopDetailsStep(
                            primaryColor, darkSlate, textGrey),
              ),
            ),

            // ── Bottom Buttons ──
            Container(
              padding: const EdgeInsets.fromLTRB(
                  AppConstants.paddingLarge, 12, AppConstants.paddingLarge, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: primaryColor.withValues(alpha: 0.08)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _currentStep--),
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Back',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: _currentStep > 0 ? 2 : 1,
                    child: GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                              if (_currentStep == 0) {
                                if (_validateStep0()) {
                                  setState(() => _currentStep++);
                                }
                              } else if (_currentStep == 1) {
                                if (_validateStep1()) {
                                  setState(() => _currentStep++);
                                }
                              } else {
                                if (_validateStep2()) {
                                  _submit();
                                }
                              }
                            },
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFCC5500), Color(0xFFE67322)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _currentStep < 2
                                          ? 'Continue'
                                          : 'Submit & Register',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_rounded,
                                        color: Colors.white, size: 18),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════
  // STEP 1: Owner & Personal Information
  // ═══════════════════════════════════════
  Widget _buildOwnerInfoStep(
      Color primaryColor, Color darkSlate, Color textGrey) {
    return SingleChildScrollView(
      key: const ValueKey('step0'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              'Owner Information', 'Tell us about yourself',
              Icons.person_rounded, primaryColor, darkSlate, textGrey),
          const SizedBox(height: 24),

          _buildFieldLabel('Full Name *', darkSlate),
          _buildTextField('e.g. Ahmed Mohamed', Icons.badge_rounded,
              primaryColor, darkSlate,
              controller: _ownerNameController),
          const SizedBox(height: 16),

          _buildFieldLabel('Email Address *', darkSlate),
          _buildTextField('email@example.com', Icons.email_rounded,
              primaryColor, darkSlate,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),

          _buildFieldLabel('Phone Number *', darkSlate),
          _buildTextField('+1234567890', Icons.phone_rounded,
              primaryColor, darkSlate,
              controller: _phoneController,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 16),

          _buildFieldLabel('Password *', darkSlate),
          _buildTextField('Create strong password', Icons.lock_rounded,
              primaryColor, darkSlate,
              obscure: true, controller: _passwordController),
          const SizedBox(height: 16),

          _buildFieldLabel('Confirm Password *', darkSlate),
          _buildTextField('Repeat password', Icons.lock_outline_rounded,
              primaryColor, darkSlate,
              obscure: true, controller: _confirmPasswordController),
          const SizedBox(height: 16),

          _buildFieldLabel('National ID Number *', darkSlate),
          _buildTextField('e.g. 29-123456789', Icons.credit_card_rounded,
              primaryColor, darkSlate,
              controller: _nationalIdController),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // STEP 2: Business Documents & License
  // ═══════════════════════════════════════
  Widget _buildBusinessDocsStep(
      Color primaryColor, Color darkSlate, Color textGrey) {
    return SingleChildScrollView(
      key: const ValueKey('step1'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
              'Business Documents',
              'Upload your business credentials',
              Icons.description_rounded,
              primaryColor,
              darkSlate,
              textGrey),
          const SizedBox(height: 24),

          _buildFieldLabel('Business/Trade License Number *', darkSlate),
          _buildTextField('e.g. TL-2024-00345',
              Icons.assured_workload_rounded, primaryColor, darkSlate,
              controller: _tradeLicenseController),
          const SizedBox(height: 16),

          _buildFieldLabel('GST / VAT Registration Number', darkSlate),
          _buildTextField('e.g. GST-29AABCU9603R1Z',
              Icons.receipt_long_rounded, primaryColor, darkSlate,
              controller: _gstController),
          const SizedBox(height: 16),

          _buildFieldLabel('Tax ID / TIN Number *', darkSlate),
          _buildTextField('e.g. TIN-123456789',
              Icons.account_balance_rounded, primaryColor, darkSlate,
              controller: _taxIdController),
          const SizedBox(height: 20),

          // Document Upload Cards (UI only - file upload requires storage pkg)
          _buildUploadCard('Trade License',
              'Upload your trade/business license',
              Icons.business_center_rounded, primaryColor, darkSlate, textGrey),
          const SizedBox(height: 12),
          _buildUploadCard('GST/VAT Certificate',
              'Upload GST/VAT registration certificate',
              Icons.verified_rounded, primaryColor, darkSlate, textGrey),
          const SizedBox(height: 12),
          _buildUploadCard('Owner ID Card',
              'Upload front & back of national ID',
              Icons.perm_identity_rounded, primaryColor, darkSlate, textGrey),
          const SizedBox(height: 12),
          _buildUploadCard('Bank Account Details',
              'Upload bank statement or passbook',
              Icons.account_balance_wallet_rounded,
              primaryColor, darkSlate, textGrey),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // STEP 3: Shop & Address Details
  // ═══════════════════════════════════════
  Widget _buildShopDetailsStep(
      Color primaryColor, Color darkSlate, Color textGrey) {
    return SingleChildScrollView(
      key: const ValueKey('step2'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Shop Details', 'Tell us about your business',
              Icons.store_rounded, primaryColor, darkSlate, textGrey),
          const SizedBox(height: 24),

          _buildFieldLabel('Shop / Store Name *', darkSlate),
          _buildTextField('e.g. Tasty Grill Express', Icons.store_rounded,
              primaryColor, darkSlate,
              controller: _shopNameController),
          const SizedBox(height: 16),

          _buildFieldLabel('Shop Address *', darkSlate),
          _buildTextField('Street Address, Area', Icons.location_on_rounded,
              primaryColor, darkSlate,
              controller: _shopAddressController),
          const SizedBox(height: 16),

          _buildFieldLabel('City *', darkSlate),
          _buildTextField('e.g. Khartoum', Icons.location_city_rounded,
              primaryColor, darkSlate,
              controller: _cityController),
          const SizedBox(height: 16),

          _buildFieldLabel('State / Region', darkSlate),
          _buildTextField('e.g. Khartoum State', Icons.map_rounded,
              primaryColor, darkSlate,
              controller: _stateController),
          const SizedBox(height: 16),

          _buildFieldLabel('Business Phone *', darkSlate),
          _buildTextField('Shop contact number',
              Icons.phone_in_talk_rounded, primaryColor, darkSlate,
              controller: _businessPhoneController,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 16),

          _buildFieldLabel('Operating Hours', darkSlate),
          Row(
            children: [
              Expanded(
                child: _buildTextField('Open 9:00 AM',
                    Icons.schedule_rounded, primaryColor, darkSlate,
                    controller: _openingHoursController),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField('Close 10:00 PM',
                    Icons.schedule_rounded, primaryColor, darkSlate,
                    controller: _closingHoursController),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Terms
          GestureDetector(
            onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _agreedToTerms
                      ? primaryColor
                      : primaryColor.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color:
                          _agreedToTerms ? primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _agreedToTerms
                            ? primaryColor
                            : const Color(0xFFCBD5E1),
                        width: 2,
                      ),
                    ),
                    child: _agreedToTerms
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF475569),
                            height: 1.4),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Vendor Policy',
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════
  // Reusable Components
  // ═══════════════════════════════════════

  Widget _buildSectionHeader(String title, String subtitle, IconData icon,
      Color primaryColor, Color darkSlate, Color textGrey) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          primaryColor.withValues(alpha: 0.08),
          primaryColor.withValues(alpha: 0.02),
        ]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkSlate)),
              Text(subtitle,
                  style:
                      GoogleFonts.inter(fontSize: 12, color: textGrey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, Color darkSlate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(label,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: darkSlate)),
    );
  }

  Widget _buildTextField(
    String hint,
    IconData icon,
    Color primaryColor,
    Color darkSlate, {
    bool obscure = false,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style:
            GoogleFonts.inter(fontSize: 15, color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
              color: const Color(0xFFADB5BD), fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 16, horizontal: 16),
          prefixIcon:
              Icon(icon, color: primaryColor.withValues(alpha: 0.5), size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: primaryColor.withValues(alpha: 0.12)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: primaryColor.withValues(alpha: 0.12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: primaryColor.withValues(alpha: 0.5), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadCard(
    String title,
    String subtitle,
    IconData icon,
    Color primaryColor,
    Color darkSlate,
    Color textGrey,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: primaryColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: primaryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: darkSlate)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        GoogleFonts.inter(fontSize: 12, color: textGrey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: primaryColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_upload_rounded,
                    color: primaryColor, size: 16),
                const SizedBox(width: 4),
                Text('Upload',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
