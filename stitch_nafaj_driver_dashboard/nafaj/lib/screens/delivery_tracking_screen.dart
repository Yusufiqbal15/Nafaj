import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/order_service.dart';
import '../services/notification_service.dart';
import '../config/api_config.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  const DeliveryTrackingScreen({super.key});

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _pulseController;

  // Order data from args + polling
  int? _orderId;
  String _orderNumber = '';
  String _orderStatus = 'pending';
  String _deliveryAddress = '';
  double _finalAmount = 0;
  bool _driverAssigned = false;
  String? _driverName;
  String? _driverPhone;
  String? _driverVehicleType;
  String? _driverVehiclePlate;
  String? _vendorName;
  List<dynamic> _items = [];
  String? _pickupImageUrl;
  String? _deliveryImageUrl;
  bool _isLoading = true;
  bool _isConfirmingDelivery = false;

  // Map
  LatLng _deliveryLocation = const LatLng(15.5007, 32.5599);
  LatLng _driverSimLocation = const LatLng(15.5100, 32.5500);
  Timer? _pollTimer;
  Timer? _driverMoveTimer;
  String _prevStatus = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _orderId == null) {
      _orderId = args['orderId'] is int
          ? args['orderId']
          : int.tryParse(args['orderId']?.toString() ?? '');
      _orderNumber = args['orderNumber']?.toString() ?? '';
      _deliveryAddress = args['dropoff']?.toString() ?? args['deliveryAddress']?.toString() ?? '';
      _finalAmount = (args['total'] ?? 0).toDouble();
      if (_orderId != null) {
        _startPolling();
      }
    }
  }

  void _startPolling() {
    _fetchOrderTracking();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchOrderTracking());
  }

  Future<void> _fetchOrderTracking() async {
    if (_orderId == null) return;
    try {
      final result = await OrderService.getOrderTracking(_orderId!);
      if (result['success'] == true && mounted) {
        final data = result['data'] as Map<String, dynamic>;
        final newStatus = data['orderStatus'] ?? 'pending';

        // Detect status change — play sound and show banner
        if (_prevStatus.isNotEmpty && _prevStatus != newStatus) {
          NotificationService.playOrderReceivedSound();
          if (mounted) {
            NotificationService.showOrderNotification(
              context: context,
              title: _statusLabel(newStatus),
              body: _statusDescription(newStatus),
              color: _statusColor(newStatus),
              icon: _statusIcon(newStatus),
            );
          }
        }
        _prevStatus = newStatus;

        setState(() {
          _orderStatus = newStatus;
          _orderNumber = data['orderNumber']?.toString() ?? _orderNumber;
          _deliveryAddress = data['deliveryAddress']?.toString() ?? _deliveryAddress;
          _finalAmount = double.tryParse(data['finalAmount']?.toString() ?? '0') ?? _finalAmount;
          _driverAssigned = data['driverAssigned'] == true;
          _driverName = data['driverName'];
          _driverPhone = data['driverPhone'];
          _driverVehicleType = data['driverVehicleType'];
          _driverVehiclePlate = data['driverVehiclePlate'];
          _vendorName = data['vendorName'];
          _items = data['items'] ?? [];

          // Image URLs from driver's proof photos
          final rawPickup = data['pickupImageUrl'];
          final rawDelivery = data['deliveryImageUrl'];
          _pickupImageUrl = (rawPickup != null && rawPickup.toString().isNotEmpty)
              ? '${ApiConfig.imageBaseUrl}$rawPickup'
              : null;
          _deliveryImageUrl = (rawDelivery != null && rawDelivery.toString().isNotEmpty)
              ? '${ApiConfig.imageBaseUrl}$rawDelivery'
              : null;

          _isLoading = false;

          // Update map location
          final lat = double.tryParse(data['deliveryLatitude']?.toString() ?? '');
          final lng = double.tryParse(data['deliveryLongitude']?.toString() ?? '');
          if (lat != null && lng != null) {
            _deliveryLocation = LatLng(lat, lng);
          }
        });

        // Start driver simulation when picked up
        if ((_orderStatus == 'picked_up' || _orderStatus == 'out_for_delivery') &&
            _driverMoveTimer == null) {
          _startDriverSimulation();
        }
      } else if (!result.containsKey('data')) {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startDriverSimulation() {
    _driverMoveTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        final currentLat = _driverSimLocation.latitude;
        final currentLng = _driverSimLocation.longitude;
        _driverSimLocation = LatLng(
          currentLat + (_deliveryLocation.latitude - currentLat) * 0.08,
          currentLng + (_deliveryLocation.longitude - currentLng) * 0.08,
        );
      });
      _mapController?.animateCamera(CameraUpdate.newLatLng(_driverSimLocation));
    });
  }

  Future<void> _confirmDelivery() async {
    if (_orderId == null) return;
    setState(() => _isConfirmingDelivery = true);
    final result = await OrderService.confirmDelivery(_orderId!);
    if (!mounted) return;
    setState(() => _isConfirmingDelivery = false);
    if (result['success'] == true) {
      NotificationService.playSuccessSound();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delivery confirmed! Thank you.',
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _fetchOrderTracking();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed',
              style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _driverMoveTimer?.cancel();
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  int get _currentStep {
    switch (_orderStatus) {
      case 'pending_vendor_confirmation': return 0;
      case 'vendor_confirmed': return 1;
      case 'driver_assigned': return 2;
      case 'pending': return 0;
      case 'confirmed': return 1;
      case 'preparing': return 2;
      case 'ready': return _driverAssigned ? 3 : 2;
      case 'picked_up': return 3;
      case 'out_for_delivery': return 4;
      case 'delivering': return 4;
      case 'pending_confirmation': return 5;
      case 'delivered': return 5;
      default: return 0;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending': return 'Order Placed';
      case 'confirmed': return 'Order Confirmed';
      case 'preparing': return 'Being Prepared';
      case 'ready': return _driverAssigned ? 'Driver Assigned' : 'Ready for Pickup';
      case 'picked_up': return 'Driver Picked Up';
      case 'out_for_delivery': return 'Out for Delivery!';
      case 'delivering': return 'On The Way!';
      case 'pending_confirmation': return 'Arrived — Please Confirm';
      case 'delivered': return 'Delivered!';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }

  String _statusDescription(String status) {
    switch (status) {
      case 'confirmed': return 'Vendor confirmed your order.';
      case 'preparing': return 'Vendor is preparing your order.';
      case 'ready': return _driverAssigned ? 'Driver is on the way to pickup your order!' : 'Order is ready — finding a driver.';
      case 'picked_up': return 'Driver is on the way to you!';
      case 'out_for_delivery': return 'Your order is out for delivery!';
      case 'pending_confirmation': return 'Tap Confirm Delivery to complete.';
      case 'delivered': return 'Your order has been delivered!';
      default: return '';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered': return const Color(0xFF10B981);
      case 'cancelled': return const Color(0xFFEF4444);
      case 'pending_confirmation': return const Color(0xFF8B5CF6);
      case 'out_for_delivery':
      case 'delivering':
      case 'picked_up': return const Color(0xFFCC5500);
      default: return const Color(0xFF3B82F6);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'delivered': return Icons.check_circle_rounded;
      case 'cancelled': return Icons.cancel_rounded;
      case 'picked_up':
      case 'out_for_delivery':
      case 'delivering': return Icons.delivery_dining_rounded;
      case 'pending_confirmation': return Icons.hourglass_empty_rounded;
      case 'preparing': return Icons.restaurant_rounded;
      default: return Icons.receipt_long_rounded;
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    markers.add(Marker(
      markerId: const MarkerId('dropoff'),
      position: _deliveryLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: 'Your Location', snippet: _deliveryAddress),
    ));
    if (_driverAssigned) {
      markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: _driverSimLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(
          title: _driverName ?? 'Driver',
          snippet: _driverVehicleType ?? 'On the way',
        ),
        zIndex: 2,
      ));
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFCC5500);
    const Color darkSlate = Color(0xFF0F172A);
    const Color textGrey = Color(0xFF64748B);
    const Color greenColor = Color(0xFF10B981);

    final bool isDelivered = _orderStatus == 'delivered';
    final bool isCancelled = _orderStatus == 'cancelled';
    final bool needsConfirmation = _orderStatus == 'pending_confirmation';
    final bool showDriver = _driverAssigned && _driverName != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCC5500)),
              ),
            )
          : Column(
              children: [
                // Map
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.38,
                  child: Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: (c) => _mapController = c,
                        initialCameraPosition: CameraPosition(
                          target: _deliveryLocation,
                          zoom: 14,
                        ),
                        mapType: MapType.satellite,
                        markers: _buildMarkers(),
                        myLocationEnabled: false,
                        zoomControlsEnabled: false,
                        compassEnabled: false,
                      ),
                      // Header row
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                                ),
                                child: const Icon(Icons.arrow_back_rounded, color: darkSlate, size: 20),
                              ),
                            ),
                            const Spacer(),
                            // Live badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedBuilder(
                                    animation: _pulseController,
                                    builder: (ctx, _) => Container(
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(
                                        color: isDelivered ? greenColor : primaryColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [BoxShadow(
                                          color: (isDelivered ? greenColor : primaryColor).withOpacity(_pulseController.value * 0.6),
                                          blurRadius: 6, spreadRadius: 2,
                                        )],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isDelivered ? 'DELIVERED' : 'LIVE TRACKING',
                                    style: GoogleFonts.inter(
                                      fontSize: 10, fontWeight: FontWeight.bold,
                                      color: isDelivered ? greenColor : primaryColor,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(width: 44),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom sheet
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Handle
                          Center(
                            child: Container(
                              width: 40, height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Status header
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _statusLabel(_orderStatus),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 22, fontWeight: FontWeight.bold,
                                        color: isCancelled ? const Color(0xFFEF4444) : darkSlate,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _statusDescription(_orderStatus),
                                      style: GoogleFonts.inter(fontSize: 13, color: textGrey),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '#$_orderNumber',
                                  style: GoogleFonts.inter(
                                    fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Progress Steps
                          _buildProgressSteps(primaryColor, greenColor, darkSlate, textGrey),
                          const SizedBox(height: 24),

                          // Driver Card (shown as soon as driver is assigned)
                          if (showDriver) ...[
                            Text('Your Driver', style: GoogleFonts.plusJakartaSans(
                              fontSize: 16, fontWeight: FontWeight.bold, color: darkSlate,
                            )),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBF7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: primaryColor.withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 54, height: 54,
                                    decoration: BoxDecoration(
                                      color: greenColor.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.directions_bike_rounded, color: Color(0xFF10B981), size: 30),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _driverName ?? 'Your Driver',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 16, fontWeight: FontWeight.bold, color: darkSlate,
                                          ),
                                        ),
                                        if (_driverVehicleType != null || _driverVehiclePlate != null)
                                          Text(
                                            [_driverVehicleType, _driverVehiclePlate]
                                                .where((e) => e != null && e.isNotEmpty)
                                                .join(' • '),
                                            style: GoogleFonts.inter(fontSize: 12, color: textGrey),
                                          ),
                                        if (_driverPhone != null)
                                          Text(
                                            _driverPhone!,
                                            style: GoogleFonts.inter(
                                              fontSize: 13, fontWeight: FontWeight.w600, color: darkSlate,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Call button
                                  if (_driverPhone != null)
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Calling ${_driverPhone!}',
                                                style: GoogleFonts.inter(color: Colors.white)),
                                            backgroundColor: greenColor,
                                            behavior: SnackBarBehavior.floating,
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 46, height: 46,
                                        decoration: BoxDecoration(
                                          color: greenColor, shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(color: greenColor.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
                                        ),
                                        child: const Icon(Icons.call_rounded, color: Colors.white, size: 22),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Pickup proof image
                          if (_pickupImageUrl != null) ...[
                            Text('Pickup Proof', style: GoogleFonts.plusJakartaSans(
                              fontSize: 16, fontWeight: FontWeight.bold, color: darkSlate,
                            )),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                _pickupImageUrl!,
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                                loadingBuilder: (ctx, child, progress) => progress == null
                                    ? child
                                    : Container(
                                        height: 180,
                                        color: Colors.grey.shade100,
                                        child: const Center(child: CircularProgressIndicator()),
                                      ),
                                errorBuilder: (ctx, _, __) => Container(
                                  height: 100,
                                  color: Colors.grey.shade100,
                                  child: const Center(child: Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Delivery proof image + confirm button
                          if (_deliveryImageUrl != null) ...[
                            Text('Delivery Proof', style: GoogleFonts.plusJakartaSans(
                              fontSize: 16, fontWeight: FontWeight.bold, color: darkSlate,
                            )),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                _deliveryImageUrl!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                loadingBuilder: (ctx, child, progress) => progress == null
                                    ? child
                                    : Container(
                                        height: 200,
                                        color: Colors.grey.shade100,
                                        child: const Center(child: CircularProgressIndicator()),
                                      ),
                                errorBuilder: (ctx, _, __) => Container(
                                  height: 100,
                                  color: Colors.grey.shade100,
                                  child: const Center(child: Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Delivery address
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: primaryColor.withOpacity(0.1)),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.location_on_rounded, color: primaryColor, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('DELIVERY ADDRESS', style: GoogleFonts.inter(
                                        fontSize: 10, fontWeight: FontWeight.bold,
                                        color: primaryColor, letterSpacing: 1,
                                      )),
                                      const SizedBox(height: 4),
                                      Text(_deliveryAddress.isNotEmpty ? _deliveryAddress : 'Your location',
                                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: darkSlate)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Order items
                          if (_items.isNotEmpty) ...[
                            Text('Order Items', style: GoogleFonts.plusJakartaSans(
                              fontSize: 16, fontWeight: FontWeight.bold, color: darkSlate,
                            )),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: primaryColor.withOpacity(0.1)),
                              ),
                              child: Column(
                                children: _items.asMap().entries.map((e) {
                                  final item = e.value;
                                  final isLast = e.key == _items.length - 1;
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 36, height: 36,
                                            decoration: BoxDecoration(
                                              color: primaryColor.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Text('${item['quantity']}x',
                                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(item['product_name'] ?? 'Item',
                                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: darkSlate)),
                                          ),
                                          Text(
                                            'SDG ${(double.tryParse(item['total_price']?.toString() ?? '0') ?? 0).toStringAsFixed(0)}',
                                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: darkSlate),
                                          ),
                                        ],
                                      ),
                                      if (!isLast) ...[
                                        const SizedBox(height: 10),
                                        Divider(color: Colors.grey.shade100, height: 1),
                                        const SizedBox(height: 10),
                                      ],
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Total amount
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: primaryColor.withOpacity(0.12)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Paid', style: GoogleFonts.inter(fontSize: 13, color: textGrey)),
                                Text(
                                  'SDG ${_finalAmount.toStringAsFixed(0)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18, fontWeight: FontWeight.w900, color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Confirm Delivery button
                          if (needsConfirmation) ...[
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton.icon(
                                onPressed: _isConfirmingDelivery ? null : _confirmDelivery,
                                icon: _isConfirmingDelivery
                                    ? const SizedBox(
                                        width: 18, height: 18,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.check_circle_rounded, size: 22),
                                label: Text(
                                  _isConfirmingDelivery ? 'Confirming...' : 'Confirm Delivery',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: greenColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],

                          if (isDelivered) ...[
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: greenColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: greenColor.withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_rounded, color: greenColor, size: 28),
                                  const SizedBox(width: 12),
                                  Text('Order Delivered Successfully!',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15, fontWeight: FontWeight.bold, color: greenColor,
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProgressSteps(Color primaryColor, Color greenColor, Color darkSlate, Color textGrey) {
    final steps = [
      ('Order Placed', Icons.receipt_long_rounded),
      ('Confirmed', Icons.check_circle_outline_rounded),
      ('Preparing', Icons.restaurant_rounded),
      ('Driver On Way', Icons.directions_bike_rounded),
      ('Out for Delivery', Icons.delivery_dining_rounded),
      ('Delivered', Icons.check_circle_rounded),
    ];

    return Column(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final step = e.value;
        final isDone = i < _currentStep;
        final isCurrent = i == _currentStep;
        final isLast = i == steps.length - 1;
        final color = isDone ? greenColor : isCurrent ? primaryColor : Colors.grey.shade300;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: isDone ? greenColor : isCurrent ? primaryColor : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                    boxShadow: (isDone || isCurrent)
                        ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: isDone
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                      : isCurrent
                          ? Icon(step.$2, color: Colors.white, size: 14)
                          : null,
                ),
                if (!isLast)
                  Container(
                    width: 2, height: 32,
                    color: isDone ? greenColor : color.withOpacity(0.3),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                step.$1,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                  color: isDone ? darkSlate : isCurrent ? darkSlate : textGrey,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
