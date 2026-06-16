import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../constants.dart';
import '../services/order_service.dart';
import '../services/api_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  GoogleMapController? _mapController;
  Map<String, dynamic>? _orderData;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  // Driver profile (fetched from backend)
  String _driverName = '';
  String _driverVehiclePlate = '';
  String _driverVehicleType = 'Motorcycle';

  // Order status tracking
  int? _orderId;
  String _currentStatus = 'picked_up';
  bool _isUpdatingStatus = false;
  Timer? _statusTimer;

  // Simulated driver position
  LatLng _deliveryBoyPosition = const LatLng(15.5050, 32.5620);
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fetchDriverProfile();

    _locationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _simulateDeliveryBoyMovement();
    });
  }

  Future<void> _fetchDriverProfile() async {
    final result = await ApiService.getProfile();
    if (result['success'] == true && mounted) {
      final data = result['data'];
      setState(() {
        _driverName =
            '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'.trim();
        _driverVehiclePlate = data['vehicle_plate'] ?? '';
        _driverVehicleType = data['vehicle_type'] ?? 'Motorcycle';
      });
      _buildMarkers();
    }
  }

  Future<void> _pollOrderStatus() async {
    if (_orderId == null) return;
    final result = await OrderService.getOrderTracking(_orderId!);
    if (result['success'] == true && mounted) {
      final data = result['data'];
      final newStatus = data['orderStatus'] as String? ?? _currentStatus;
      if (newStatus != _currentStatus) {
        setState(() => _currentStatus = newStatus);
      }
    }
  }

  Future<void> _updateStatus(String newStatus, String label) async {
    if (_orderId == null || _isUpdatingStatus) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Confirm Action',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Mark this order as: $label?',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: const Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC5500),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text('Confirm',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isUpdatingStatus = true);
    final result =
        await OrderService.updateOrderStatus(_orderId!, newStatus);
    if (mounted) {
      setState(() {
        _isUpdatingStatus = false;
        if (result['success'] == true) _currentStatus = newStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true
                ? 'Status updated: $label'
                : result['error'] ?? 'Failed to update status',
          ),
          backgroundColor: result['success'] == true
              ? const Color(0xFF10B981)
              : Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      if (result['success'] == true &&
          newStatus == 'delivering') {
        // Give a moment then pop back to dashboard
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      }
    }
  }

  void _simulateDeliveryBoyMovement() {
    if (_orderData == null) return;
    setState(() {
      final targetLat = _orderData!['lat'] as double;
      final targetLng = _orderData!['lng'] as double;
      final currentLat = _deliveryBoyPosition.latitude;
      final currentLng = _deliveryBoyPosition.longitude;
      final newLat = currentLat + (targetLat - currentLat) * 0.1;
      final newLng = currentLng + (targetLng - currentLng) * 0.1;
      _deliveryBoyPosition = LatLng(newLat, newLng);
      _buildMarkers();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _orderData == null) {
      _orderData = args;
      _orderId = int.tryParse(args['id']?.toString() ?? '');
      _buildMarkers();

      if (_orderId != null) {
        _pollOrderStatus();
        _statusTimer = Timer.periodic(
          const Duration(seconds: 8),
          (_) => _pollOrderStatus(),
        );
      }
    }
  }

  void _buildMarkers() {
    if (_orderData == null) return;

    final restaurantPos = LatLng(
      _orderData!['lat'] as double,
      _orderData!['lng'] as double,
    );

    final driverLabel =
        _driverName.isNotEmpty ? '$_driverName - On the way' : 'Driver - On the way';

    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('restaurant'),
        position: restaurantPos,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: _orderData!['restaurant'] ?? 'Restaurant',
          snippet: _orderData!['address'] ?? '',
        ),
      ),
      Marker(
        markerId: const MarkerId('delivery_boy'),
        position: _deliveryBoyPosition,
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'You',
          snippet: driverLabel,
        ),
      ),
      Marker(
        markerId: const MarkerId('customer'),
        position: const LatLng(15.5007, 32.5599),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(
          title: 'Customer Location',
          snippet: 'Drop off point',
        ),
      ),
    };

    final Set<Polyline> polylines = {
      Polyline(
        polylineId: const PolylineId('delivery_route'),
        points: [_deliveryBoyPosition, restaurantPos],
        color: const Color(0xFF10B981),
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
      Polyline(
        polylineId: const PolylineId('dropoff_route'),
        points: [restaurantPos, const LatLng(15.5007, 32.5599)],
        color: const Color(0xFFCC5500),
        width: 3,
        patterns: [PatternItem.dash(15), PatternItem.gap(8)],
      ),
    };

    setState(() {
      _markers = markers;
      _polylines = polylines;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController?.dispose();
    _locationTimer?.cancel();
    _statusTimer?.cancel();
    super.dispose();
  }

  bool _statusAtOrAfter(String check, String current) {
    const order = [
      'pending', 'confirmed', 'preparing', 'ready',
      'picked_up', 'out_for_delivery', 'delivering', 'delivered'
    ];
    final checkIdx = order.indexOf(check);
    final curIdx = order.indexOf(current);
    return curIdx >= checkIdx;
  }

  String _estimatedArrival() {
    final now = DateTime.now();
    final estMinutes =
        int.tryParse((_orderData?['time'] as String? ?? '20 mins')
                .replaceAll(RegExp(r'[^0-9]'), '')) ??
            20;
    final arrival = now.add(Duration(minutes: estMinutes));
    final h = arrival.hour % 12 == 0 ? 12 : arrival.hour % 12;
    final m = arrival.minute.toString().padLeft(2, '0');
    final ampm = arrival.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFCC5500);
    const Color bgColor = Color(0xFFFFFBF7);
    const Color darkSlate = Color(0xFF0F172A);
    const Color textGrey = Color(0xFF475569);
    const Color greenColor = Color(0xFF10B981);

    final String restaurantName = _orderData?['restaurant'] ?? 'Restaurant';
    final String earnings = _orderData?['earnings'] ?? 'SDG 0';
    final String distance = _orderData?['distance'] ?? '0 km';
    final String estTime = _orderData?['time'] ?? '0 mins';
    final String deliveryAddress =
        _orderData?['address'] ?? 'Delivery Address';
    final String orderNumber = _orderData?['orderNumber'] ?? 'N/A';
    final String userName = _orderData?['userName'] ?? 'Customer';
    final String userPhone = _orderData?['userPhone'] ?? 'N/A';
    final String deliveryFee = _orderData?['deliveryFee'] ?? 'SDG 0';
    final String totalAmount = _orderData?['totalAmount'] ?? 'SDG 0';
    final List<dynamic> items = _orderData?['items'] ?? [];

    final bool isPickedUp = _statusAtOrAfter('picked_up', _currentStatus);
    final bool isOutForDelivery =
        _statusAtOrAfter('out_for_delivery', _currentStatus);
    final bool isDelivered = _statusAtOrAfter('delivering', _currentStatus);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                            color: primaryColor.withValues(alpha: 0.12)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
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
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: greenColor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: greenColor.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnim,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnim.value,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Active Delivery',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 46),
                ],
              ),
            ),

            // ── Google Map ──
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _deliveryBoyPosition,
                          zoom: 14.0,
                        ),
                        mapType: MapType.satellite,
                        markers: _markers,
                        polylines: _polylines,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        compassEnabled: false,
                        mapToolbarEnabled: false,
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                      ),
                      // Live tracking badge
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: greenColor.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: greenColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          greenColor.withValues(alpha: 0.5),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'LIVE TRACKING',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () {
                            _mapController?.animateCamera(
                              CameraUpdate.newLatLng(_deliveryBoyPosition),
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(Icons.my_location_rounded,
                                color: greenColor, size: 22),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom Info Sheet ──
            Expanded(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.fromLTRB(
                    AppConstants.paddingLarge, 24,
                    AppConstants.paddingLarge, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Order Number + Status
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBF7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: primaryColor.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #$orderNumber',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: darkSlate,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDelivered
                                    ? greenColor
                                    : primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isDelivered
                                    ? 'DELIVERED'
                                    : isOutForDelivery
                                        ? 'OUT FOR DELIVERY'
                                        : 'IN PROGRESS',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Delivery Location + Customer
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: primaryColor.withValues(alpha: 0.1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.location_on_rounded,
                                      color: primaryColor, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DELIVERY LOCATION',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        deliveryAddress,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: darkSlate,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Divider(
                                color: textGrey.withValues(alpha: 0.1),
                                height: 1),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        greenColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.person_rounded,
                                      color: greenColor, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CUSTOMER',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: greenColor,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        userName.isNotEmpty
                                            ? userName
                                            : 'Customer',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: darkSlate,
                                        ),
                                      ),
                                      Text(
                                        userPhone,
                                        style: GoogleFonts.inter(
                                            fontSize: 12, color: textGrey),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: greenColor,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: greenColor.withValues(
                                              alpha: 0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.call_rounded,
                                        color: Colors.white, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Order Items
                      if (items.isNotEmpty) ...[
                        Text(
                          'Order Items',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: darkSlate,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: primaryColor.withValues(alpha: 0.1)),
                          ),
                          child: Column(
                            children: items.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final isLast = index == items.length - 1;
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: primaryColor.withValues(
                                              alpha: 0.08),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${item['quantity']}x',
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item['product_name'] ?? 'Item',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: darkSlate,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'SDG ${(double.tryParse(item['total_price']?.toString() ?? '0') ?? 0.0).toStringAsFixed(0)}',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: darkSlate,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (!isLast) ...[
                                    const SizedBox(height: 12),
                                    Divider(
                                        color:
                                            textGrey.withValues(alpha: 0.1),
                                        height: 1),
                                    const SizedBox(height: 12),
                                  ],
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Earnings Breakdown
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: primaryColor.withValues(alpha: 0.15)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Order Amount',
                                    style: GoogleFonts.inter(
                                        fontSize: 13, color: textGrey)),
                                Text(totalAmount,
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: darkSlate)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Your Delivery Fee',
                                    style: GoogleFonts.inter(
                                        fontSize: 13, color: textGrey)),
                                Text(deliveryFee,
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: greenColor)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Divider(
                                color: primaryColor.withValues(alpha: 0.2),
                                height: 1),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text('YOUR EARNINGS',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                      letterSpacing: 1,
                                    )),
                                Text(earnings,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: primaryColor,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Restaurant + Distance row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurantName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: darkSlate,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.location_on_rounded,
                                      color: primaryColor, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$distance • $estTime',
                                    style: GoogleFonts.inter(
                                        fontSize: 13, color: textGrey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color:
                                      primaryColor.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              earnings,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Estimated Arrival
                      Text(
                        'ESTIMATED ARRIVAL',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _estimatedArrival(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: darkSlate,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '($estTime)',
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: textGrey),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.access_time_rounded,
                                color: primaryColor, size: 22),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Driver Card (real data) ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBF7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: primaryColor.withValues(alpha: 0.08)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: greenColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.directions_bike_rounded,
                                color: Color(0xFF10B981),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _driverName.isNotEmpty
                                        ? _driverName
                                        : 'Loading...',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: darkSlate,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(Icons.star_rounded,
                                          color: const Color(0xFFF59E0B),
                                          size: 14),
                                      const SizedBox(width: 2),
                                      Text(
                                        '4.8 • Khartoum',
                                        style: GoogleFonts.inter(
                                            fontSize: 12, color: textGrey),
                                      ),
                                    ],
                                  ),
                                  if (_driverVehiclePlate.isNotEmpty)
                                    Text(
                                      '$_driverVehicleType • $_driverVehiclePlate',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: textGrey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: greenColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: greenColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                'YOU',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: greenColor,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Order Progress ──
                      Text(
                        'Order Progress',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkSlate,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildProgressStep('Order Placed', greenColor, true,
                          darkSlate, textGrey),
                      _buildProgressConnector(greenColor, true),
                      _buildProgressStep('Preparing Order', greenColor, true,
                          darkSlate, textGrey),
                      _buildProgressConnector(
                          isPickedUp ? primaryColor : Colors.grey.shade300,
                          isPickedUp),
                      _buildProgressStep(
                          'Picked Up',
                          isPickedUp ? primaryColor : Colors.grey.shade300,
                          isPickedUp,
                          darkSlate,
                          textGrey),
                      _buildProgressConnector(
                          isOutForDelivery
                              ? greenColor
                              : Colors.grey.shade300,
                          isOutForDelivery),
                      _buildProgressStep(
                          'Out for Delivery',
                          isOutForDelivery
                              ? greenColor
                              : Colors.grey.shade300,
                          isOutForDelivery,
                          darkSlate,
                          textGrey),
                      _buildProgressConnector(
                          isDelivered ? greenColor : Colors.grey.shade300,
                          isDelivered),
                      _buildProgressStep(
                          'Delivered',
                          isDelivered ? greenColor : Colors.grey.shade300,
                          isDelivered,
                          darkSlate,
                          textGrey),
                      const SizedBox(height: 28),

                      // ── Action Button ──
                      if (!isDelivered) ...[
                        if (!isPickedUp)
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: _isUpdatingStatus
                                  ? null
                                  : () => _updateStatus('picked_up', 'Picked Up'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                disabledBackgroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                                shadowColor: primaryColor.withOpacity(0.3),
                              ),
                              child: _isUpdatingStatus
                                  ? const SizedBox(
                                      width: 24, height: 24,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.shopping_bag_rounded,
                                            color: Colors.white, size: 22),
                                        const SizedBox(width: 10),
                                        Text('Confirm Pickup',
                                            style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                      ],
                                    ),
                            ),
                          )
                        else if (!isOutForDelivery)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.hourglass_empty_rounded,
                                      color: Color(0xFFF59E0B), size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Waiting for Vendor',
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF0F172A))),
                                      const SizedBox(height: 3),
                                      Text(
                                          'Vendor must mark order as "Out for Delivery"',
                                          style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: const Color(0xFF475569))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: _isUpdatingStatus
                                  ? null
                                  : () => _updateStatus('delivering', 'Delivered'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: greenColor,
                                disabledBackgroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                                shadowColor: greenColor.withOpacity(0.3),
                              ),
                              child: _isUpdatingStatus
                                  ? const SizedBox(
                                      width: 24, height: 24,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.check_circle_rounded,
                                            color: Colors.white, size: 22),
                                        const SizedBox(width: 10),
                                        Text('Mark as Delivered',
                                            style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                      ],
                                    ),
                            ),
                          ),
                        const SizedBox(height: 16),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: greenColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: greenColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: greenColor, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                'Delivery Complete!',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: greenColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
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

  Widget _buildProgressStep(
    String title,
    Color color,
    bool isDone,
    Color darkSlate,
    Color textGrey,
  ) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDone ? color : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
            boxShadow: isDone
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: isDone
              ? const Icon(Icons.check_rounded,
                  color: Colors.white, size: 16)
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDone ? darkSlate : textGrey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressConnector(Color color, bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(left: 13),
      child: Container(
        width: 2,
        height: 30,
        color: isDone ? color : color.withValues(alpha: 0.3),
      ),
    );
  }
}
