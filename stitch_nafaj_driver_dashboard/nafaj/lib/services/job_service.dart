import 'package:flutter/material.dart';
import '../models/job_model.dart';
import 'api_service.dart';

class JobService {
  // ──── NO MORE DUMMY/STATIC DATA ────
  // All data now comes from the backend database

  // ──── All Job Categories (25+ industries like Mourjan) ────
  static const List<JobCategory> categories = [
    JobCategory(
      id: 'programming',
      name: 'Programming',
      icon: Icons.code_rounded,
      color: Color(0xFF2196F3),
    ),
    JobCategory(
      id: 'web_design',
      name: 'Web Design',
      icon: Icons.web_rounded,
      color: Color(0xFF9C27B0),
    ),
    JobCategory(
      id: 'graphic_design',
      name: 'Graphic Design',
      icon: Icons.design_services_rounded,
      color: Color(0xFFE91E63),
    ),
    JobCategory(
      id: 'teaching',
      name: 'Teaching',
      icon: Icons.school_rounded,
      color: Color(0xFF4CAF50),
    ),
    JobCategory(
      id: 'driver',
      name: 'Driver',
      icon: Icons.local_taxi_rounded,
      color: Color(0xFFFF9800),
    ),
    JobCategory(
      id: 'delivery',
      name: 'Delivery',
      icon: Icons.delivery_dining_rounded,
      color: Color(0xFFFF5722),
    ),
    JobCategory(
      id: 'construction',
      name: 'Construction',
      icon: Icons.construction_rounded,
      color: Color(0xFF795548),
    ),
    JobCategory(
      id: 'healthcare',
      name: 'Healthcare',
      icon: Icons.medical_services_rounded,
      color: Color(0xFFF44336),
    ),
    JobCategory(
      id: 'engineering',
      name: 'Engineering',
      icon: Icons.engineering_rounded,
      color: Color(0xFF607D8B),
    ),
    JobCategory(
      id: 'accounting',
      name: 'Accounting & Finance',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF009688),
    ),
    JobCategory(
      id: 'marketing',
      name: 'Marketing & Sales',
      icon: Icons.campaign_rounded,
      color: Color(0xFFFF6F00),
    ),
    JobCategory(
      id: 'customer_service',
      name: 'Customer Service',
      icon: Icons.headset_mic_rounded,
      color: Color(0xFF3F51B5),
    ),
    JobCategory(
      id: 'technology',
      name: 'Technology & IT',
      icon: Icons.computer_rounded,
      color: Color(0xFF00BCD4),
    ),
    JobCategory(
      id: 'agriculture',
      name: 'Agriculture & Farming',
      icon: Icons.agriculture_rounded,
      color: Color(0xFF8BC34A),
    ),
    JobCategory(
      id: 'retail',
      name: 'Retail & Commerce',
      icon: Icons.storefront_rounded,
      color: Color(0xFFCDDC39),
    ),
    JobCategory(
      id: 'transport',
      name: 'Transport & Logistics',
      icon: Icons.local_shipping_rounded,
      color: Color(0xFF455A64),
    ),
    JobCategory(
      id: 'security',
      name: 'Security',
      icon: Icons.security_rounded,
      color: Color(0xFF37474F),
    ),
    JobCategory(
      id: 'hospitality',
      name: 'Hospitality',
      icon: Icons.hotel_rounded,
      color: Color(0xFFAB47BC),
    ),
    JobCategory(
      id: 'cleaning',
      name: 'Cleaning',
      icon: Icons.cleaning_services_rounded,
      color: Color(0xFF26A69A),
    ),
    JobCategory(
      id: 'electrician',
      name: 'Electrician',
      icon: Icons.electrical_services_rounded,
      color: Color(0xFFFFC107),
    ),
    JobCategory(
      id: 'plumbing',
      name: 'Plumbing',
      icon: Icons.plumbing_rounded,
      color: Color(0xFF5C6BC0),
    ),
    JobCategory(
      id: 'data_entry',
      name: 'Data Entry',
      icon: Icons.keyboard_rounded,
      color: Color(0xFF78909C),
    ),
    JobCategory(
      id: 'photography',
      name: 'Photography',
      icon: Icons.camera_alt_rounded,
      color: Color(0xFFEC407A),
    ),
    JobCategory(
      id: 'cooking',
      name: 'Cooking & Catering',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFD84315),
    ),
    JobCategory(
      id: 'tailoring',
      name: 'Tailoring & Fashion',
      icon: Icons.checkroom_rounded,
      color: Color(0xFFAD1457),
    ),
    JobCategory(
      id: 'mechanic',
      name: 'Mechanic',
      icon: Icons.build_rounded,
      color: Color(0xFF546E7A),
    ),
    JobCategory(
      id: 'education',
      name: 'Education',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF1565C0),
    ),
  ];

  static List<String> get sectorNames => categories.map((c) => c.name).toList();

  // ──── Fetch all jobs from API (optional sector filter) ────
  static Future<List<Job>> fetchJobs({String? sector}) async {
    try {
      final queryParams = <String, String>{};
      if (sector != null && sector.isNotEmpty) queryParams['sector'] = sector;

      final uri = Uri.parse('${ApiService.dio.options.baseUrl}/jobs')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await ApiService.dio.getUri(uri);
      if (response.statusCode == 200) {
        final rawJobs = (response.data['jobs'] as List?) ?? [];
        return rawJobs.map((j) => Job.fromJson(j as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  // ──── Fetch jobs posted by a specific user ────
  static Future<List<Job>> fetchMyJobs(int userId) async {
    try {
      final response = await ApiService.dio.get('/jobs', queryParameters: {'userId': userId});
      if (response.statusCode == 200) {
        final rawJobs = (response.data['jobs'] as List?) ?? [];
        return rawJobs.map((j) => Job.fromJson(j as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  // ──── Fetch total job count ────
  static Future<int> fetchTotalCount() async {
    try {
      final response = await ApiService.dio.get('/jobs');
      if (response.statusCode == 200) {
        return (response.data['count'] as int?) ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  // ──── Post a new job to the API ────
  static Future<Map<String, dynamic>> createJob({
    required String title,
    required String description,
    required String company,
    required String phone,
    required String sector,
    required String jobType,
    required String salaryText,
    required String location,
  }) async {
    try {
      final response = await ApiService.dio.post('/jobs', data: {
        'title': title,
        'description': description,
        'company': company,
        'phone': phone,
        'sector': sector,
        'jobType': jobType,
        'salaryText': salaryText,
        'location': location,
        'budget': 0,
      });
      if (response.statusCode == 201) {
        return {'success': true, 'jobId': response.data['jobId']};
      }
      return {'success': false, 'error': response.data['error'] ?? 'Failed to post job'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ──── Delete a job ────
  static Future<bool> deleteJob(int jobId) async {
    try {
      final response = await ApiService.dio.delete('/jobs/$jobId');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
