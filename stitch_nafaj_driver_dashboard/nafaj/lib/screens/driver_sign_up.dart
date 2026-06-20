import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';

class DriverSignUpScreen extends StatefulWidget {
  const DriverSignUpScreen({super.key});

  @override
  State<DriverSignUpScreen> createState() => _DriverSignUpScreenState();
}

class _DriverSignUpScreenState extends State<DriverSignUpScreen> {
  int _currentStep = 1;
  String? _selectedCity;
  String? _selectedVehicle;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();

  late AppStrings _s;
  late bool _isAr;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _licenseController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  static const Color primaryColor = Color(0xFFCC5500);
  static const Color bgColor = Color(0xFFF8F7F5);
  static const Color darkSlate = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    _s = AppStrings.direct(isArabic: localeProvider.isArabic);
    _isAr = localeProvider.isArabic;

    return Directionality(
      textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              _isAr ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
              color: darkSlate,
            ),
            onPressed: () {
              if (_currentStep > 1) {
                setState(() => _currentStep--);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            _s.driverRegistration,
            style: GoogleFonts.plusJakartaSans(
              color: darkSlate,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Progress Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getStepTitle(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: darkSlate,
                          ),
                        ),
                        Text(
                          '${_s.stepOf3} $_currentStep ${_s.of3}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: _isAr ? Alignment.centerRight : Alignment.centerLeft,
                        widthFactor: _currentStep / 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(4),
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
                  padding: const EdgeInsets.all(16.0),
                  child: _buildCurrentStep(),
                ),
              ),

              if (_currentStep == 1)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _s.alreadyHaveAccount,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/driver_login');
                        },
                        child: Text(
                          _s.logIn,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
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
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1:
        return _s.stepPersonalDetails;
      case 2:
        return _s.stepDocumentSubmit;
      case 3:
        return _s.stepConfirmDetails;
      default:
        return '';
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _s.becomeNafajDriver,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: darkSlate,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _s.driverSignUpSubtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: const Color(0xFF475569),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
        _buildLabel(_s.fullName),
        TextField(
          controller: _nameController,
          textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
          style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.black),
          decoration: _inputDecoration(
            hintText: _s.enterFullName,
            iconData: Icons.person_rounded,
            primaryColor: primaryColor,
          ),
        ),
        const SizedBox(height: 20),

        _buildLabel(_s.emailLabel),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.black),
          decoration: _inputDecoration(
            hintText: _s.enterEmail,
            iconData: Icons.email_rounded,
            primaryColor: primaryColor,
          ),
        ),
        const SizedBox(height: 20),

        _buildLabel(_s.passwordLabel),
        TextField(
          controller: _passwordController,
          obscureText: true,
          textDirection: TextDirection.ltr,
          style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.black),
          decoration: _inputDecoration(
            hintText: _s.createStrongPassword,
            iconData: Icons.lock_rounded,
            primaryColor: primaryColor,
          ),
        ),
        const SizedBox(height: 20),

        _buildLabel(_s.phoneNumber),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          style: GoogleFonts.plusJakartaSans(fontSize: 16, color: darkSlate),
          decoration: _inputDecoration(
            hintText: '+1234567890',
            iconData: Icons.call_rounded,
            primaryColor: primaryColor,
          ),
        ),
        const SizedBox(height: 20),

        _buildLabel(_s.cityState),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedCity,
              hint: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on_rounded, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 12),
                  Text(
                    _s.selectLocation,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              icon: const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(Icons.expand_more_rounded, color: Color(0xFF94A3B8)),
              ),
              items: _s.cities.map((String city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on_rounded, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 12),
                      Text(
                        city,
                        style: GoogleFonts.plusJakartaSans(fontSize: 16, color: darkSlate),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCity = newValue;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 20),

        _buildLabel(_s.vehicleType),
        Row(
          children: [
            Expanded(
              child: _buildVehicleOption(
                id: 'motorcycle',
                label: _s.motorcycle,
                icon: Icons.motorcycle_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildVehicleOption(
                id: 'rickshaw',
                label: _s.rickshaw,
                icon: Icons.electric_rickshaw_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildVehicleOption(
                id: 'car',
                label: _s.car,
                icon: Icons.directions_car_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (_emailController.text.isEmpty ||
                  _passwordController.text.isEmpty ||
                  _nameController.text.isEmpty ||
                  _phoneController.text.isEmpty ||
                  _selectedCity == null ||
                  _selectedVehicle == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_s.fillAllFields)),
                );
                return;
              }
              final rawPhone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
              if (rawPhone.length < 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phone number must be at least 10 digits')),
                );
                return;
              }
              setState(() => _currentStep = 2);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _s.nextStep,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isAr ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _s.submitDocuments,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: darkSlate,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _s.documentsSubtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: const Color(0xFF475569),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        _buildLabel(_s.drivingLicenseNumber),
        TextField(
          controller: _licenseController,
          textDirection: TextDirection.ltr,
          style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.black),
          decoration: _inputDecoration(
            hintText: _s.enterLicenseNumber,
            iconData: Icons.badge_rounded,
            primaryColor: primaryColor,
          ),
        ),
        const SizedBox(height: 24),

        _buildLabel(_s.nationalIdNumber),
        TextField(
          controller: _nationalIdController,
          textDirection: TextDirection.ltr,
          style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.black),
          decoration: _inputDecoration(
            hintText: _s.enterNationalId,
            iconData: Icons.credit_card_rounded,
            primaryColor: primaryColor,
          ),
        ),
        const SizedBox(height: 48),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              if (_licenseController.text.isEmpty ||
                  _nationalIdController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_s.provideAllDocuments)),
                );
                return;
              }
              setState(() => _currentStep = 3);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _s.continueToReview,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.assignment_turned_in_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _s.confirmDetailsTitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: darkSlate,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _s.reviewBeforeSubmit,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: const Color(0xFF475569),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSummaryRow(Icons.person, _s.fullName, _nameController.text),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildSummaryRow(Icons.email, _s.summaryEmail, _emailController.text),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildSummaryRow(Icons.phone, _s.summaryPhone, _phoneController.text),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildSummaryRow(Icons.location_city, _s.summaryCity, _selectedCity ?? ''),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildSummaryRow(Icons.directions_car, _s.summaryVehicle,
                  _selectedVehicle?.toUpperCase() ?? ''),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildSummaryRow(Icons.badge, _s.summaryLicense, _licenseController.text),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildSummaryRow(Icons.credit_card, _s.summaryNationalId, _nationalIdController.text),
            ],
          ),
        ),

        const SizedBox(height: 32),

        SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              try {
                String phone = _phoneController.text.trim();

                final nameParts = _nameController.text.trim().split(' ');
                final firstName = nameParts.first;
                final lastName =
                    nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

                final result = await ApiService.driverRegister(
                  email: _emailController.text.trim(),
                  phone: phone,
                  password: _passwordController.text,
                  firstName: firstName,
                  lastName: lastName,
                  licenseNumber: _licenseController.text.trim(),
                  vehicleType: _selectedVehicle,
                  vehiclePlate: '',
                );

                if (!mounted) return;

                if (result['success']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_s.registrationSuccess)),
                  );
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/pending_approval',
                    (route) => false,
                    arguments: {'userType': 'driver'},
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(result['error'] ?? _s.registrationFailed)),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${_s.errorPrefix}$e')),
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _s.confirmAndProceed,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle_outline, color: Colors.white),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            _s.termsAgreement,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: darkSlate,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData iconData,
    required Color primaryColor,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      prefixIcon: Icon(iconData, color: const Color(0xFF94A3B8)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    );
  }

  Widget _buildVehicleOption({
    required String id,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = _selectedVehicle == id;

    return GestureDetector(
      onTap: () => setState(() => _selectedVehicle = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xFFF1F5F9),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : const Color(0xFF64748B),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isSelected ? primaryColor : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
