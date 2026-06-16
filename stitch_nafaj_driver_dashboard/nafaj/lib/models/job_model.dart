import 'package:flutter/material.dart';

class JobCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const JobCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class Job {
  final String id;
  final String title;
  final String company;
  final String sector;
  final String description;
  final String phone;
  final String location;
  final String jobType;
  final String salary;
  final DateTime createdAt;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.sector,
    required this.description,
    required this.phone,
    this.location = 'Khartoum, SD',
    this.jobType = 'Full-time',
    this.salary = 'Negotiable',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      company: json['company'] ?? 'Posted on Nafaj',
      sector: json['sector'] ?? '',
      description: json['description'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? 'N/A',
      jobType: json['job_type'] ?? 'Full-time',
      salary: json['salary_text'] ?? 'Negotiable',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inDays > 7) return '${diff.inDays ~/ 7}w ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }

  IconData get sectorIcon {
    switch (sector.toLowerCase()) {
      case 'programming':
      case 'technology & it':
        return Icons.code_rounded;
      case 'web design':
      case 'graphic design':
        return Icons.design_services_rounded;
      case 'teaching':
      case 'education':
        return Icons.school_rounded;
      case 'driver':
      case 'transport & logistics':
        return Icons.local_shipping_rounded;
      case 'construction':
        return Icons.construction_rounded;
      case 'healthcare':
        return Icons.medical_services_rounded;
      case 'delivery':
        return Icons.delivery_dining_rounded;
      case 'agriculture & farming':
        return Icons.agriculture_rounded;
      case 'retail & commerce':
        return Icons.storefront_rounded;
      case 'engineering':
        return Icons.engineering_rounded;
      case 'accounting & finance':
        return Icons.account_balance_rounded;
      case 'marketing & sales':
        return Icons.campaign_rounded;
      case 'customer service':
        return Icons.headset_mic_rounded;
      case 'security':
        return Icons.security_rounded;
      case 'hospitality':
        return Icons.hotel_rounded;
      case 'cleaning':
        return Icons.cleaning_services_rounded;
      case 'electrician':
        return Icons.electrical_services_rounded;
      case 'plumbing':
        return Icons.plumbing_rounded;
      case 'data entry':
        return Icons.keyboard_rounded;
      case 'photography':
        return Icons.camera_alt_rounded;
      case 'cooking & catering':
        return Icons.restaurant_rounded;
      case 'tailoring & fashion':
        return Icons.checkroom_rounded;
      case 'mechanic':
        return Icons.build_rounded;
      default:
        return Icons.work_rounded;
    }
  }
}
