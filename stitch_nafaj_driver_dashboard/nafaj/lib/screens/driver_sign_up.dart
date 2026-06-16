import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

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

  final List<String> _cities = [
    'Khartoum',
    'Omdurman',
    'Khartoum North (Bahri)',
    'Port Sudan',
    'Wad Madani',
  ];

  static const Color primaryColor = Color(0xFFCC5500);
  static const Color bgColor = Color(0xFFF8F7F5);
  static const Color darkSlate = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: darkSlate),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() {
                _currentStep--;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Driver Registration',
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
                        'Step $_currentStep of 3',
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
                      alignment: Alignment.centerLeft,
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

            // Footer (Already have an account?) - Only on step 1
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
                      'Already have an account? ',
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
                        'Log in',
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
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1:
        return 'Personal Details';
      case 2:
        return 'Document Submit';
      case 3:
        return 'Confirm Details';
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
        // Header Area
        Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Become a Nafaj Driver',
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
                'Enter your details to start earning on your own schedule.',
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
        _buildLabel('Full Name'),
        TextField(
          controller: _nameController,
          style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.black),
          decoration: _inputDecoration(
            hintText: 'Enter your full name',
            iconData: Icons.person_rounded,
            primaryColor: primaryColor,
          ),
        ),
        const SizedBox(height: 20),

        _buildLabel('Email Address'),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.black),
          decoration: _inputDecoration(
            hintText: 'Enter your email',
            iconData: Icons.email_rounded,
            primaryColor: primaryColor,
          ),
        ),
        const SizedBox(height: 20),

        _buildLabel('Password'),
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.black),
          decoration: _inputDecoration(
            hintText: 'Create strong password',
            iconData: Icons.lock_rounded,
            primaryColor: primaryColor,
          ),
        ),
        const SizedBox(height: 20),

        _buildLabel('Phone Number'),
        Row(
          children: [
            Container(
              width: 80,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                '+249',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: darkSlate,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.plusJakartaSans(fontSize: 16, color: darkSlate),
                decoration: _inputDecoration(
                  hintText: '9xx xxx xxx',
                  iconData: Icons.call_rounded,
                  primaryColor: primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildLabel('City / State (Sudan)'),
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
                    'Select your location',
                    style: GoogleFonts.plusJakartaSans(fontSize: 16, color: const Color(0xFF94A3B8)),
                  ),
                ],
              ),
              icon: const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Icon(Icons.expand_more_rounded, color: Color(0xFF94A3B8)),
              ),
              items: _cities.map((String city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on_rounded, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 12),
                      Text(city, style: GoogleFonts.plusJakartaSans(fontSize: 16, color: darkSlate)),
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

        _buildLabel('Vehicle Type'),
        Row(
          children: [
            Expanded(
              child: _buildVehicleOption(
                id: 'motorcycle',
                label: 'Motorcycle',
                icon: Icons.motorcycle_rounded,
                primaryColor: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildVehicleOption(
                id: 'rickshaw',
                label: 'Rickshaw',
                icon: Icons.electric_rickshaw_rounded,
                primaryColor: primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildVehicleOption(
                id: 'car',
                label: 'Car',
                icon: Icons.directions_car_rounded,
                primaryColor: primaryColor,
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
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }
              setState(() {
                _currentStep = 2;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Next Step',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
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
                'Submit Documents',
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
                'Please provide your identification and driving details.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: const Color(0xFF475569),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        _buildLabel('Driving License Number'),
        TextField(
          controller: _licenseController,
          style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.black),
          decoration: _inputDecoration(
            hintText: 'Enter license number',
            iconData: Icons.badge_rounded,
            primaryColor: primaryColor,
          ),
        ),
        const SizedBox(height: 24),

        _buildLabel('Nationality ID Number'),
        TextField(
          controller: _nationalIdController,
          style: GoogleFonts.plusJakartaSans(fontSize: 16, color: Colors.black),
          decoration: _inputDecoration(
            hintText: 'Enter national ID',
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
              if (_licenseController.text.isEmpty || _nationalIdController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide all documents')),
                );
                return;
              }
              setState(() {
                _currentStep = 3;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue to Review',
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
                'Confirm Details',
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
                'Please review your details before submitting.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: const Color(0xFF475569),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        // Summary Card
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
              )
            ],
          ),
          child: Column(
            children: [
              _buildSummaryRow(Icons.person, 'Full Name', _nameController.text),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildSummaryRow(Icons.email, 'Email', _emailController.text),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildSummaryRow(Icons.phone, 'Phone', '+249 ${_phoneController.text}'),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildSummaryRow(Icons.location_city, 'City', _selectedCity ?? ''),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildSummaryRow(Icons.directions_car, 'Vehicle', _selectedVehicle?.toUpperCase() ?? ''),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildSummaryRow(Icons.badge, 'License No.', _licenseController.text),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildSummaryRow(Icons.credit_card, 'Nationality ID', _nationalIdController.text),
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
                // Format phone number to Pakistani format
                String phone = _phoneController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
                if (phone.startsWith('249')) {
                  phone = '0${phone.substring(3)}';
                } else if (phone.startsWith('+249')) {
                  phone = '0${phone.substring(4)}';
                } else if (!phone.startsWith('0')) {
                  phone = '0$phone';
                }

                // Split name into first and last name
                final nameParts = _nameController.text.trim().split(' ');
                final firstName = nameParts.first;
                final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

                final result = await ApiService.driverRegister(
                  email: _emailController.text.trim(),
                  phone: phone,
                  password: _passwordController.text,
                  firstName: firstName,
                  lastName: lastName,
                  licenseNumber: _licenseController.text.trim(),
                  vehicleType: _selectedVehicle,
                  vehiclePlate: '', // Can be added later
                );

                if (!mounted) return;

                if (result['success']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registration successful! Awaiting admin approval.')),
                  );
                  // Navigate to pending approval screen — admin must approve before accessing dashboard
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/pending_approval',
                    (route) => false,
                    arguments: {'userType': 'driver'},
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['error'] ?? 'فشل إنشاء الحساب')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطأ: $e')),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Confirm & Proceed',
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
            'By continuing, you agree to Nafaj\'s Terms of Service and Privacy Policy.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF64748B)),
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
    required Color primaryColor,
  }) {
    bool isSelected = _selectedVehicle == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVehicle = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : const Color(0xFFF1F5F9), // slate-100
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? primaryColor
                  : const Color(0xFF64748B), // slate-500
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isSelected
                    ? primaryColor
                    : const Color(0xFF475569), // slate-600
              ),
            ),
          ],
        ),
      ),
    );
  }
}

