import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/order_service.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';
import 'package:dio/dio.dart';

class DriverOrderTrackingDetailedScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const DriverOrderTrackingDetailedScreen({
    Key? key,
    required this.orderData,
  }) : super(key: key);

  @override
  State<DriverOrderTrackingDetailedScreen> createState() =>
      _DriverOrderTrackingDetailedScreenState();
}

class _DriverOrderTrackingDetailedScreenState
    extends State<DriverOrderTrackingDetailedScreen> {
  int _currentStage = 0;
  bool _isUpdatingStatus = false;
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  final ImagePicker _picker = ImagePicker();

  AppStrings _s = AppStrings.direct(isArabic: false);
  bool _isAr = false;

  List<Map<String, dynamic>> get _stages => [
    {
      'title': _s.stageTitleHeadingToPickup,
      'subtitle': _s.stageSubtitleHeadingToPickup,
      'icon': Icons.directions_bike_rounded,
      'status': null,
      'requiresImage': false,
    },
    {
      'title': _s.stageTitlePickupDone,
      'subtitle': _s.stageSubtitlePickupDone,
      'icon': Icons.camera_alt_rounded,
      'status': 'picked_up',
      'requiresImage': true,
      'imageType': 'pickup',
    },
    {
      'title': _s.stageTitleOutForDelivery,
      'subtitle': _s.stageSubtitleOutForDelivery,
      'icon': Icons.delivery_dining_rounded,
      'status': 'out_for_delivery',
      'requiresImage': false,
    },
    {
      'title': _s.stageTitleUploadDeliveryProof,
      'subtitle': _s.stageSubtitleUploadDeliveryProof,
      'icon': Icons.verified_rounded,
      'status': 'pending_confirmation',
      'requiresImage': true,
      'imageType': 'delivery',
    },
  ];

  @override
  void initState() {
    super.initState();
    _determineCurrentStage();
  }

  void _determineCurrentStage() {
    // Read actual DB status (set by driver dashboard as 'orderStatus')
    final status = (widget.orderData['orderStatus'] ?? widget.orderData['status'] ?? '').toString().toLowerCase();

    if (status == 'delivered' || status == 'pending_confirmation') {
      _currentStage = 4; // all stages complete / waiting confirmation
    } else if (status == 'out_for_delivery' || status == 'delivering') {
      _currentStage = 3; // delivery proof stage
    } else if (status == 'picked_up') {
      _currentStage = 2; // out for delivery stage
    } else {
      _currentStage = 0; // 'ready', 'confirmed' etc. → start from the beginning
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          // For web: read bytes
          final bytes = await image.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImageName = image.name;
            _selectedImage = null;
          });
        } else {
          // For mobile: use file path
          setState(() {
            _selectedImage = File(image.path);
            _selectedImageBytes = null;
            _selectedImageName = null;
          });
        }
      }
    } catch (e) {
      _showError('${_s.isArabic ? 'فشل اختيار الصورة: ' : 'Failed to pick image: '}$e');
    }
  }

  Future<void> _completeStage() async {
    final stage = _stages[_currentStage];

    // Stage 0 has no status update — just advance locally
    if (stage['status'] == null) {
      setState(() {
        _currentStage++;
        _selectedImage = null;
        _selectedImageBytes = null;
        _selectedImageName = null;
      });
      _showSuccess(_s.onYourWayTakePhoto);
      return;
    }

    if (stage['requiresImage'] == true && _selectedImage == null && _selectedImageBytes == null) {
      _showError(_s.pleaseUploadPhotoForStage);
      return;
    }

    setState(() => _isUpdatingStatus = true);

    try {
      final orderId = widget.orderData['orderId'] ?? widget.orderData['id'];
      final stageStatus = stage['status'] as String;
      final imageType = stage['imageType'] as String?;

      if (stage['requiresImage'] == true && (_selectedImage != null || _selectedImageBytes != null)) {
        await _updateStatusWithImage(orderId, stageStatus, imageType!);
      } else {
        await _updateStatusOnly(orderId, stageStatus);
      }

      setState(() {
        _currentStage++;
        _selectedImage = null;
        _selectedImageBytes = null;
        _selectedImageName = null;
        _isUpdatingStatus = false;
      });

      if (_currentStage >= _stages.length) {
        _showSuccess(_s.deliveryProofUploaded);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context, true);
      } else {
        _showSuccess(_s.stageCompleted);
      }
    } catch (e) {
      setState(() => _isUpdatingStatus = false);
      _showError('${_s.isArabic ? 'فشل إكمال المرحلة: ' : 'Failed to complete stage: '}$e');
    }
  }

  Future<void> _updateStatusWithImage(
      dynamic orderId, String status, String imageType) async {
    try {
      MultipartFile imageFile;
      
      if (kIsWeb && _selectedImageBytes != null) {
        // Web: upload from bytes
        imageFile = MultipartFile.fromBytes(
          _selectedImageBytes!,
          filename: _selectedImageName ?? 'order_${orderId}_$imageType.jpg',
        );
      } else if (_selectedImage != null) {
        // Mobile: upload from file
        imageFile = await MultipartFile.fromFile(
          _selectedImage!.path,
          filename: 'order_${orderId}_$imageType.jpg',
        );
      } else {
        throw Exception('No image selected');
      }

      final formData = FormData.fromMap({
        'status': status,
        'imageType': imageType,
        'image': imageFile,
      });

      final response = await ApiService.dio.patch(
        '/orders/$orderId/status/driver/with-image',
        data: formData,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update status');
      }
    } catch (e) {
      throw Exception('Status update failed: $e');
    }
  }

  Future<void> _updateStatusOnly(dynamic orderId, String status) async {
    final result = await OrderService.updateOrderStatus(
      int.parse(orderId.toString()),
      status,
    );

    if (result['success'] != true) {
      throw Exception(result['error'] ?? 'Failed to update status');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    _s = AppStrings.direct(isArabic: localeProvider.isArabic);
    _isAr = localeProvider.isArabic;

    return Directionality(
      textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC5500),
        elevation: 0,
        leading: IconButton(
          icon: Icon(_isAr ? Icons.arrow_forward : Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _s.orderTracking,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Order info header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFCC5500),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    widget.orderData['orderNumber'] ?? 'N/A',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.orderData['restaurant'] ?? 'Restaurant',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_s.deliveryTo}${widget.orderData['address'] ?? _s.naLabel}',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.attach_money, color: Colors.white, size: 20),
                      Text(
                        widget.orderData['earnings'] ?? 'N/A',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tracking stages
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Progress indicator
                  Row(
                    children: List.generate(
                      _stages.length,
                      (index) => Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: index < _currentStage
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            if (index < _stages.length - 1)
                              const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Current stage card
                  if (_currentStage < _stages.length)
                    _buildCurrentStageCard(_stages[_currentStage]),

                  const SizedBox(height: 24),

                  // All stages list
                  ...List.generate(
                    _stages.length,
                    (index) => _buildStageItem(index),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    ), // Scaffold
    ); // Directionality
  }

  Widget _buildCurrentStageCard(Map<String, dynamic> stage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFCC5500).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  stage['icon'],
                  color: const Color(0xFFCC5500),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage['title'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      stage['subtitle'],
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (stage['requiresImage'] == true) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Image upload section
            if (_selectedImage != null || _selectedImageBytes != null)
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb && _selectedImageBytes != null
                        ? Image.memory(
                            _selectedImageBytes!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            _selectedImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      _s.changeImage,
                      style: GoogleFonts.inter(),
                    ),
                  ),
                ],
              )
            else
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFCC5500).withOpacity(0.3),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        kIsWeb ? Icons.upload_file : Icons.camera_alt,
                        size: 48,
                        color: const Color(0xFFCC5500).withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _s.tapToImageType(stage['imageType'] ?? '', kIsWeb),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _s.requiredToCompleteStage,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFFEF4444),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],

          const SizedBox(height: 16),

          // Complete button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isUpdatingStatus ? null : _completeStage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCC5500),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isUpdatingStatus
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      stage['requiresImage'] == true && _selectedImage == null && _selectedImageBytes == null
                          ? _s.uploadImageToContinue
                          : _s.completeStage,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageItem(int index) {
    final stage = _stages[index];
    final isCompleted = index < _currentStage;
    final isCurrent = index == _currentStage;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF10B981)
                  : isCurrent
                      ? const Color(0xFFCC5500)
                      : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              isCompleted ? Icons.check : stage['icon'],
              color: isCompleted || isCurrent
                  ? Colors.white
                  : const Color(0xFF9CA3AF),
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage['title'],
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: isCompleted || isCurrent
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isCompleted || isCurrent
                        ? const Color(0xFF1F2937)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
                Text(
                  stage['subtitle'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Status badge
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _s.stageDone,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981),
                ),
              ),
            )
          else if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFCC5500).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _s.stageCurrent,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFCC5500),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
