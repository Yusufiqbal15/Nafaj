import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:math' show cos, sqrt, asin, pi;
import '../constants.dart' hide AppStrings;
import '../services/order_service.dart';
import '../services/notification_service.dart';
import '../config/api_config.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';

class DriverDashboardAnimated3DScreen extends StatefulWidget {
  const DriverDashboardAnimated3DScreen({super.key});

  @override
  State<DriverDashboardAnimated3DScreen> createState() =>
      _DriverDashboardAnimated3DScreenState();
}

class _DriverDashboardAnimated3DScreenState
    extends State<DriverDashboardAnimated3DScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  final bool _isOnline = true;
  GoogleMapController? _mapController;

  static const LatLng _driverLocation = LatLng(15.5007, 32.5599);

  List<Map<String, dynamic>> _orders = [];
  bool _isLoadingOrders = false;
  Set<String> _knownOrderIds = {};
  Timer? _pollingTimer;

  Set<Marker> _markers = {};

  AppStrings _s = AppStrings.direct(isArabic: false);
  bool _isAr = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _loadAvailableOrders();
    // Poll for new orders every 10 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadAvailableOrders(isPolling: true);
    });
  }

  Future<void> _loadAvailableOrders({bool isPolling = false}) async {
    if (!isPolling) {
      print('🔍 DEBUG: Starting to load orders...');
      setState(() => _isLoadingOrders = true);
    }

    try {
      print('🔍 DEBUG: Calling OrderService.getDriverOrders...');
      print('🔍 DEBUG: API URL: ${ApiConfig.baseUrl}/orders/driver/orders');
      
      final result = await OrderService.getDriverOrders(status: 'available');
      
      print('🔍 DEBUG: API Response received:');
      print('   Success: ${result['success']}');
      print('   Data keys: ${result.keys.toList()}');
      
      if (result['error'] != null) {
        print('   ❌ Error: ${result['error']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_s.connectionErrorPrefix}${result['error']}',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }

      if (result['success'] == true && mounted) {
        final orders = result['data']['orders'] as List;
        print('🔍 DEBUG: Found ${orders.length} orders');

        // Detect new orders for notification
        if (isPolling && _knownOrderIds.isNotEmpty) {
          final newIds = orders.map((o) => o['id'].toString()).toSet();
          final brandNew = newIds.difference(_knownOrderIds);
          if (brandNew.isNotEmpty && mounted) {
            NotificationService.playOrderReceivedSound();
            final count = brandNew.length;
            NotificationService.showOrderNotification(
              context: context,
              title: _isAr
                  ? '$count ${count > 1 ? 'طلبات جديدة' : 'طلب جديد'} متاحة!'
                  : '$count New Order${count > 1 ? 's' : ''} Available!',
              body: _isAr ? 'اسحب للقبول وابدأ الكسب.' : 'Slide to accept and start earning.',
              color: const Color(0xFFCC5500),
              icon: Icons.delivery_dining_rounded,
            );
          }
        }
        
        if (orders.isNotEmpty) {
          print('🔍 DEBUG: First order: ${orders[0]}');
        }

        _knownOrderIds = orders.map((o) => o['id'].toString()).toSet();

        setState(() {
          _orders = orders.map((order) {
            // Convert string coordinates to double
            final deliveryLat = order['delivery_latitude'] != null 
                ? double.tryParse(order['delivery_latitude'].toString()) 
                : null;
            final deliveryLng = order['delivery_longitude'] != null 
                ? double.tryParse(order['delivery_longitude'].toString()) 
                : null;
            
            // Convert string amounts to double
            final finalAmount = double.tryParse(order['final_amount']?.toString() ?? '0') ?? 0.0;
            final deliveryFee = double.tryParse(order['delivery_fee']?.toString() ?? '0') ?? 0.0;
            
            // Calculate distance if coordinates are available
            String distance = 'N/A';
            if (deliveryLat != null && deliveryLng != null) {
              try {
                distance = '${_calculateDistance(_driverLocation.latitude, _driverLocation.longitude, deliveryLat, deliveryLng).toStringAsFixed(1)} km';
              } catch (e) {
                print('Error calculating distance: $e');
                distance = 'N/A';
              }
            }
            
            return {
              'id': order['id'].toString(),
              'orderNumber': order['order_number'] ?? 'N/A',
              'restaurant': order['vendor_name'] ?? 'Unknown Vendor',
              'address': order['delivery_address'] ?? 'No address',
              'distance': distance,
              'time': '${_estimateDeliveryTime(distance)} mins',
              'earnings': 'SDG ${(deliveryFee > 0 ? deliveryFee : 500).toStringAsFixed(0)}',
              'deliveryFee': 'SDG ${(deliveryFee > 0 ? deliveryFee : 500).toStringAsFixed(0)}',
              'totalAmount': 'SDG ${finalAmount.toStringAsFixed(0)}',
              'lat': deliveryLat ?? 15.5107,
              'lng': deliveryLng ?? 32.5699,
              'status': order['order_status'] == 'ready' ? 'READY' : 'NEW ORDER',
              'color': order['order_status'] == 'ready' ? const Color(0xFFEF4444) : const Color(0xFFCC5500),
              'userName': '${order['first_name'] ?? ''} ${order['last_name'] ?? ''}'.trim(),
              'userPhone': order['user_phone'] ?? 'N/A',
              'vendorAddress': order['vendor_address'] ?? 'Restaurant location',
              'items': order['items'] ?? [],
              // Actual DB status — needed by driver tracking to determine current stage
              'orderStatus': order['order_status'] ?? 'ready',
            };
          }).toList();
          _isLoadingOrders = false;
        });

        print('🔍 DEBUG: Orders list updated. Count: ${_orders.length}');
        _buildMarkers();
      } else {
        print('❌ DEBUG: API call failed or no orders');
        if (mounted) {
          setState(() {
            _orders = [];
            _isLoadingOrders = false;
          });
        }
      }
    } catch (e) {
      print('❌ ERROR loading orders: $e');
      if (mounted) {
        setState(() {
          _orders = [];
          _isLoadingOrders = false;
        });
      }
    }
  }

  Future<void> _acceptOrder(String orderId) async {
    try {
      final result = await OrderService.acceptOrder(int.parse(orderId));

      if (result['success'] == true && mounted) {
        NotificationService.playSuccessSound();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _s.orderAcceptedSuccess,
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

        // Find the order data to pass to tracking page
        final orderData = _orders.firstWhere(
          (order) => order['id'] == orderId,
          orElse: () => {},
        );

        // Navigate to tracking page
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && orderData.isNotEmpty) {
          Navigator.pushNamed(
            context,
            '/order_tracking',
            arguments: orderData,
          ).then((_) {
            // Reload orders when coming back from tracking
            _loadAvailableOrders();
          });
        } else {
          // Reload orders if navigation fails
          _loadAvailableOrders();
        }
      } else {
        if (mounted) {
          String errorMessage = result['error'] ?? _s.failedToAcceptOrder;

          if (errorMessage.contains('active delivery') || errorMessage.contains('complete it first')) {
            showDialog(
              context: context,
              builder: (ctx) => Directionality(
                textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Row(
                    children: [
                      const Icon(Icons.warning_rounded, color: Color(0xFFF59E0B), size: 28),
                      const SizedBox(width: 12),
                      Text(
                        _s.activeDelivery,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    _s.activeDeliveryMessage,
                    style: GoogleFonts.notoSansArabic(fontSize: 14),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        _s.ok,
                        style: GoogleFonts.notoSansArabic(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFCC5500),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushNamed(context, '/driver_delivery_history');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC5500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _s.viewActiveOrder,
                        style: GoogleFonts.notoSansArabic(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  errorMessage,
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_s.errorPrefix}$e',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = 0.5 - 0.5 * cos(2 * dLat) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * (1 - cos(2 * dLon)) / 2;
    
    return earthRadius * 2 * asin(sqrt(a));
  }
  
  double _toRadians(double degree) {
    return degree * pi / 180;
  }
  
  // Estimate delivery time based on distance
  int _estimateDeliveryTime(String distanceStr) {
    try {
      final distance = double.parse(distanceStr.replaceAll(' km', ''));
      // Assume 30 km/h average speed + 10 minutes preparation
      return ((distance / 30) * 60 + 10).round();
    } catch (e) {
      return 15; // default 15 minutes
    }
  }

  void _buildMarkers() {
    final Set<Marker> markers = {};

    // Driver marker
    markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: _driverLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(title: _s.youAreHere),
      ),
    );

    // Order markers
    for (int i = 0; i < _orders.length; i++) {
      final order = _orders[i];
      markers.add(
        Marker(
          markerId: MarkerId(order['id']),
          position: LatLng(order['lat'], order['lng']),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == 0
                ? BitmapDescriptor.hueRed
                : i == 1
                ? BitmapDescriptor.hueGreen
                : i == 2
                ? BitmapDescriptor.hueViolet
                : i == 3
                ? BitmapDescriptor.hueRose
                : BitmapDescriptor.hueYellow,
          ),
          infoWindow: InfoWindow(
            title: order['restaurant'],
            snippet: '${order['distance']} • ${order['earnings']}',
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    _s = AppStrings.direct(isArabic: localeProvider.isArabic);
    _isAr = localeProvider.isArabic;

    const Color primaryColor = Color(0xFFCC5500);
    const Color darkSlate = Color(0xFF0F172A);
    const Color textGrey = Color(0xFF475569);

    return Directionality(
      textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      bottomNavigationBar: _buildDriverBottomNav(context, 0),
      body: Column(
        children: [
          // ── Top Section: Header + Map ──
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Top Header ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.navigation_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOnline ? _s.online : _s.offline,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkSlate,
                            ),
                          ),
                          Text(
                            _isOnline ? _s.readyForOrders : _s.tapToGoOnline,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _isOnline
                                  ? const Color(0xFF10B981)
                                  : textGrey,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _s.networkLabel,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: textGrey,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            _s.highStrength,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: darkSlate,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.signal_cellular_alt_rounded,
                        color: darkSlate,
                        size: 22,
                      ),
                    ],
                  ),
                ),

                // ── Search Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingLarge,
                    vertical: 4,
                  ),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Icon(
                          Icons.search_rounded,
                          color: primaryColor,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _s.searchRouteOrRestaurant,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: textGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Google Map (Satellite Mode) ──
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _driverLocation,
                    zoom: 13.5,
                  ),
                  mapType: MapType.satellite,
                  markers: _markers,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
                // Zoom controls
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    children: [
                      _buildMapControl(Icons.add, primaryColor, () {
                        _mapController?.animateCamera(CameraUpdate.zoomIn());
                      }),
                      const SizedBox(height: 2),
                      _buildMapControl(Icons.remove, primaryColor, () {
                        _mapController?.animateCamera(CameraUpdate.zoomOut());
                      }),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLng(_driverLocation),
                          );
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.15),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.my_location_rounded,
                            color: primaryColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Active orders count badge
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _s.activeOrdersCount(_orders.length),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Orders List Section ──
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Section header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _s.availableOrders,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkSlate,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _s.ordersCount(_orders.length),
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
                  // Scrollable order cards
                  Expanded(
                    child: _isLoadingOrders && _orders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _s.findingOrders,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: darkSlate,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _s.searchingNearby,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: textGrey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _orders.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: primaryColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Icon(
                                        Icons.shopping_cart_outlined,
                                        size: 40,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      _s.noOrdersAvailable,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: darkSlate,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _s.ordersAppearWhenVendors,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: textGrey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      onPressed: _loadAvailableOrders,
                                      icon: const Icon(Icons.refresh),
                                      label: Text(
                                        _s.refresh,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadAvailableOrders,
                                color: primaryColor,
                                child: ListView.builder(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 4, 20, 16),
                                  physics:
                                      const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  itemCount: _orders.length,
                                  itemBuilder: (context, index) {
                                    return _buildOrderCard(
                                      _orders[index],
                                      primaryColor,
                                      darkSlate,
                                      textGrey,
                                    );
                                  },
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ), // Scaffold
    ); // Directionality
  }

  Widget _buildOrderCard(
    Map<String, dynamic> order,
    Color primaryColor,
    Color darkSlate,
    Color textGrey,
  ) {
    final bool isUrgent = order['status'] == 'URGENT';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUrgent
              ? const Color(0xFFEF4444).withValues(alpha: 0.3)
              : primaryColor.withValues(alpha: 0.08),
          width: isUrgent ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isUrgent
                ? const Color(0xFFEF4444).withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row: status + earnings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                      : primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isUrgent
                        ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                        : primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isUrgent)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.priority_high_rounded,
                          color: const Color(0xFFEF4444),
                          size: 14,
                        ),
                      ),
                    Text(
                      order['status'],
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isUrgent
                            ? const Color(0xFFEF4444)
                            : primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _s.earnings,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: textGrey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    order['earnings'],
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Restaurant info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['restaurant'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkSlate,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: primaryColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            order['address'],
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: textGrey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Distance, Time, and Order Value
          Row(
            children: [
              _buildInfoChip(
                Icons.location_on_outlined,
                _s.distance,
                order['distance'],
                primaryColor,
                darkSlate,
                textGrey,
              ),
              const SizedBox(width: 14),
              _buildInfoChip(
                Icons.access_time_rounded,
                _s.estTime,
                order['time'],
                primaryColor,
                darkSlate,
                textGrey,
              ),
              const SizedBox(width: 14),
              _buildInfoChip(
                Icons.shopping_bag_outlined,
                _s.order,
                order['totalAmount'],
                primaryColor,
                darkSlate,
                textGrey,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Slide to Accept Button
          _SlideToAcceptButton(
            onAccepted: () {
              _acceptOrder(order['id']);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapControl(
    IconData icon,
    Color primaryColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF0F172A), size: 20),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    String value,
    Color primaryColor,
    Color darkSlate,
    Color textGrey,
  ) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryColor, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 10, color: textGrey),
            ),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: darkSlate,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDriverBottomNav(BuildContext context, int currentIndex) {
    const Color primaryColor = Color(0xFFCC5500);
    const Color inactiveGrey = Color(0xFF94A3B8);

    final items = [
      {
        'icon': Icons.map_rounded,
        'label': _s.navMap,
        'route': '/driver_dashboard_animated_3d',
      },
      {
        'icon': Icons.format_list_bulleted_rounded,
        'label': _s.navHistory,
        'route': '/driver_delivery_history',
      },
      {
        'icon': Icons.account_balance_wallet_rounded,
        'label': _s.navWallet,
        'route': '/driver_wallet',
      },
      {
        'icon': Icons.person_rounded,
        'label': _s.navProfile,
        'route': '/driver_profile',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: primaryColor.withValues(alpha: 0.08))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isActive = index == currentIndex;
              return GestureDetector(
                onTap: () {
                  if (!isActive) {
                    Navigator.pushReplacementNamed(
                      context,
                      items[index]['route'] as String,
                    );
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: isActive
                      ? BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[index]['icon'] as IconData,
                        color: isActive ? primaryColor : inactiveGrey,
                        size: 24,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[index]['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isActive ? primaryColor : inactiveGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Slide to Accept Button ──
class _SlideToAcceptButton extends StatefulWidget {
  final VoidCallback onAccepted;

  const _SlideToAcceptButton({required this.onAccepted});

  @override
  State<_SlideToAcceptButton> createState() => _SlideToAcceptButtonState();
}

class _SlideToAcceptButtonState extends State<_SlideToAcceptButton> {
  double _dragPosition = 0;
  bool _isAccepted = false;

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFCC5500);
    final localeProvider = context.watch<LocaleProvider>();
    final s = AppStrings.direct(isArabic: localeProvider.isArabic);
    final isAr = localeProvider.isArabic;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double buttonWidth = 48.0;
        final double maxDrag = maxWidth - buttonWidth - 12;

        return Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFCC5500), Color(0xFFE67322)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.35),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
            children: [
              Center(
                child: Text(
                  _isAccepted ? s.accepted : s.slideToAccept,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                left: isAr ? null : 6 + _dragPosition,
                right: isAr ? 6 + _dragPosition : null,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    if (_isAccepted) return;
                    setState(() {
                      final delta = isAr ? -details.delta.dx : details.delta.dx;
                      _dragPosition += delta;
                      if (_dragPosition < 0) _dragPosition = 0;
                      if (_dragPosition > maxDrag) _dragPosition = maxDrag;
                    });
                  },
                  onPanEnd: (details) {
                    if (_isAccepted) return;
                    if (_dragPosition > maxDrag * 0.8) {
                      setState(() {
                        _dragPosition = maxDrag;
                        _isAccepted = true;
                      });
                      Future.delayed(const Duration(milliseconds: 300), () {
                        widget.onAccepted();
                        if (mounted) {
                          setState(() {
                            _dragPosition = 0;
                            _isAccepted = false;
                          });
                        }
                      });
                    } else {
                      setState(() {
                        _dragPosition = 0;
                      });
                    }
                  },
                  child: Container(
                    width: buttonWidth,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isAr ? Icons.keyboard_double_arrow_left_rounded : Icons.double_arrow_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
