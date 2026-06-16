import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class NafajUserSignUpScreen extends StatefulWidget {
  const NafajUserSignUpScreen({super.key});

  @override
  State<NafajUserSignUpScreen> createState() => _NafajUserSignUpScreenState();
}

class _NafajUserSignUpScreenState extends State<NafajUserSignUpScreen> {
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signUp() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('الرجاء إدخال جميع البيانات المطلوبة')),
      );
      return;
    }

    // Format phone number to Pakistani format
    String phone = _phoneController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
    if (phone.startsWith('249')) {
      phone = '0${phone.substring(3)}';
    } else if (phone.startsWith('+249')) {
      phone = '0${phone.substring(4)}';
    } else if (!phone.startsWith('0')) {
      phone = '0$phone';
    }

    setState(() => _isLoading = true);
    
    try {
      // Split name into first and last name
      final nameParts = _nameController.text.trim().split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final result = await ApiService.userRegister(
        email: _emailController.text.trim(),
        phone: phone,
        password: _passwordController.text,
        firstName: firstName,
        lastName: lastName,
      );

      if (!mounted) return;

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'تم إنشاء الحساب بنجاح')),
        );
        // Navigate to home/dashboard
        Navigator.pushReplacementNamed(context, '/nafaj_marketplace_home');
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_forward,
                            color: Color(0xFF0F172A), size: 20),
                      ),
                    ),
                    Image.asset('logo.png', height: 48),
                    const SizedBox(width: 44),
                  ],
                ),
                const SizedBox(height: 48),
                Text(
                  'إنشاء حساب جديد',
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'أدخل بياناتك للتسجيل كمستخدم جديد في التطبيق',
                  style: GoogleFonts.notoSansArabic(
                    fontSize: 16,
                    color: const Color(0xFF64748B),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 48),

                // Name
                _buildLabel('الاسم الكامل'),
                _buildInput(
                  controller: _nameController,
                  hintText: 'أدخل اسمك الكامل',
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 24),

                // Phone
                _buildLabel('رقم الهاتف'),
                _buildInput(
                  controller: _phoneController,
                  hintText: '09xx xxx xxx',
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 24),

                // Email
                _buildLabel('البريد الإلكتروني'),
                _buildInput(
                  controller: _emailController,
                  hintText: 'user@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 24),

                // Password
                _buildLabel('كلمة المرور'),
                _buildInput(
                  controller: _passwordController,
                  hintText: '••••••••',
                  obscureText: true,
                  textDirection: TextDirection.ltr,
                ),
                const SizedBox(height: 32),

                // Submit Button
                GestureDetector(
                  onTap: _isLoading ? null : _signUp,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF7A00), Color(0xFFFF9500)],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF7A00).withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'تسجيل',
                              style: GoogleFonts.notoSansArabic(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Switch to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لديك حساب بالفعل؟ ',
                      style: GoogleFonts.notoSansArabic(
                          fontSize: 15, color: const Color(0xFF64748B)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'تسجيل الدخول',
                        style: GoogleFonts.notoSansArabic(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF7A00),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: GoogleFonts.notoSansArabic(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textDirection: textDirection,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          hintText: hintText,
          hintStyle:
              GoogleFonts.plusJakartaSans(color: const Color(0xFFCBD5E1)),
        ),
      ),
    );
  }
}
