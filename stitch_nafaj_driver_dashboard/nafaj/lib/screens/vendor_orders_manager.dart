import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/order_service.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class VendorOrdersManagerScreen extends StatefulWidget {
  const VendorOrdersManagerScreen({super.key});

  @override
  State<VendorOrdersManagerScreen> createState() => _VendorOrdersManagerScreenState();
}

class _VendorOrdersManagerScreenState extends State<VendorOrdersManagerScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  Timer? _pollingTimer;
  Set<int> _knownOrderIds = {};
  String? _vendorEmail;
  int? _vendorId;

  @override
  void initState() {
    super.initState();
    _loadVendorEmail();
    _loadVendorOrders(isInitial: true);
    // Auto-refresh every 8 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _loadVendorOrders(isInitial: false);
    });
  }

  Future<void> _loadVendorEmail() async {
    final email = await ApiService.getEmail();
    final id = await ApiService.getUserId();
    if (mounted) {
      setState(() {
        _vendorEmail = email;
        _vendorId = id;
      });
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadVendorOrders({bool isInitial = false}) async {
    if (isInitial) setState(() => _isLoading = true);

    try {
      final isLoggedIn = await ApiService.isLoggedIn();
      final userType = await ApiService.getUserType();

      if (!isLoggedIn || userType != 'vendor') {
        if (mounted && isInitial) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please login as vendor', style: GoogleFonts.inter(color: Colors.white)),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final result = await OrderService.getVendorOrders();

      if (result['success'] == true && mounted) {
        final responseData = result['data'];

        // Capture vendor identity if present (email → ID)
        if (responseData['vendorEmail'] != null && mounted) {
          setState(() {
            _vendorEmail = responseData['vendorEmail'] as String?;
            _vendorId = responseData['vendorId'] as int?;
          });
        }

        final rawOrders = (responseData['orders'] ?? []) as List;

        final newOrders = rawOrders.map<Map<String, dynamic>>((order) {
          final custFirst = order['first_name'] ?? '';
          final custLast = order['last_name'] ?? '';
          final custName = '$custFirst $custLast'.trim();
          return {
            'orderId': order['id'] as int,
            'orderNumber': order['order_number'] ?? 'N/A',
            'customerName': custName.isNotEmpty ? custName : (order['user_email'] ?? 'Customer'),
            'customerPhone': order['phone'] ?? order['user_phone'] ?? 'N/A',
            'deliveryAddress': order['delivery_address'] ?? 'No address',
            'finalAmount': double.tryParse(order['final_amount']?.toString() ?? '0') ?? 0.0,
            'orderStatus': order['order_status'] ?? 'pending',
            'vendorId': order['vendor_id'],
            'vendorName': order['vendor_name'] ?? 'Vendor',
            'vendorEmail': order['vendor_email'] ?? '',
            'driverId': order['driver_id'],
            'driverAssigned': order['driver_id'] != null,
            'driverName': order['driver_first_name'] != null
                ? '${order['driver_first_name']} ${order['driver_last_name'] ?? ''}'.trim()
                : null,
            'driverPhone': order['driver_phone'],
            'driverVehicle': order['driver_vehicle_type'],
            'driverPlate': order['driver_vehicle_plate'],
            'createdAt': order['created_at'],
            'items': order['items'] ?? [],
          };
        }).toList();

        // Detect new orders
        if (!isInitial && _knownOrderIds.isNotEmpty) {
          final newIds = newOrders.map((o) => o['orderId'] as int).toSet();
          final brandNewIds = newIds.difference(_knownOrderIds);
          if (brandNewIds.isNotEmpty && mounted) {
            NotificationService.playOrderReceivedSound();
            NotificationService.showOrderNotification(
              context: context,
              title: '${brandNewIds.length} New Order${brandNewIds.length > 1 ? 's' : ''}!',
              body: 'New order received — tap to review.',
              color: const Color(0xFFCC5500),
              icon: Icons.shopping_bag_rounded,
            );
          }
        }

        _knownOrderIds = newOrders.map((o) => o['orderId'] as int).toSet();

        setState(() {
          _orders = newOrders;
          _isLoading = false;
        });
      } else {
        if (isInitial && mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (isInitial && mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmOrder(int orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Confirm Order?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text('Accept this order and make it visible to drivers?', style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Confirm', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final loadingDialog = showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCC5500)))),
    );

    final result = await OrderService.vendorConfirmOrder(orderId);
    if (mounted) Navigator.of(context).pop();

    if (result['success'] == true) {
      NotificationService.playSuccessSound();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Order confirmed — drivers can now see it', style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ));
        _loadVendorOrders();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['error'] ?? 'Failed', style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _rejectOrder(int orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reject Order?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text('This will cancel the order. This action cannot be undone.', style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Keep', style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Reject', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final loadingDialog = showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)))),
    );

    final result = await OrderService.vendorRejectOrder(orderId);
    if (mounted) Navigator.of(context).pop();

    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Order rejected and cancelled', style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ));
        _loadVendorOrders();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['error'] ?? 'Failed', style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _updateOrderStatus(int orderId, String status) async {
    final label = _actionLabel(status);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('$label?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text('Mark this order as "$label"?', style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC5500),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Yes', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    final loadingDialog = showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCC5500)),
        ),
      ),
    );

    final result = await OrderService.vendorUpdateOrderStatus(orderId, status);
    if (mounted) Navigator.of(context).pop(); // close loading

    if (result['success'] == true) {
      NotificationService.playSuccessSound();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order updated: $label', style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _loadVendorOrders();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed', style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _actionLabel(String status) {
    switch (status) {
      case 'confirmed': return 'Confirm Order';
      case 'preparing': return 'Start Preparing';
      case 'ready': return 'Mark Ready';
      case 'out_for_delivery': return 'Out for Delivery';
      default: return status;
    }
  }

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedFilter == 'all') return _orders;
    return _orders.where((o) => o['orderStatus'] == _selectedFilter).toList();
  }

  int _getCount(String status) {
    if (status == 'all') return _orders.length;
    return _orders.where((o) => o['orderStatus'] == status).length;
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
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: darkSlate, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('All Orders', style: GoogleFonts.plusJakartaSans(
                          fontSize: 22, fontWeight: FontWeight.bold, color: darkSlate,
                        )),
                        Text('${_orders.length} orders', style: GoogleFonts.inter(
                          fontSize: 14, color: primaryColor, fontWeight: FontWeight.w600,
                        )),
                        if (_vendorEmail != null)
                          Text(
                            _vendorId != null
                                ? 'ID: $_vendorId • $_vendorEmail'
                                : _vendorEmail!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  // Manual refresh
                  GestureDetector(
                    onTap: () => _loadVendorOrders(isInitial: true),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.refresh_rounded, color: primaryColor, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Filter tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _filterChip('All', 'all', _getCount('all'), primaryColor),
                  const SizedBox(width: 10),
                  _filterChip('New', 'pending_vendor_confirmation', _getCount('pending_vendor_confirmation'), const Color(0xFFF59E0B)),
                  const SizedBox(width: 10),
                  _filterChip('Confirmed', 'vendor_confirmed', _getCount('vendor_confirmed'), const Color(0xFF10B981)),
                  const SizedBox(width: 10),
                  _filterChip('Driver Assigned', 'driver_assigned', _getCount('driver_assigned'), const Color(0xFF3B82F6)),
                  const SizedBox(width: 10),
                  _filterChip('Preparing', 'preparing', _getCount('preparing'), primaryColor),
                  const SizedBox(width: 10),
                  _filterChip('On Way', 'out_for_delivery', _getCount('out_for_delivery'), primaryColor),
                  const SizedBox(width: 10),
                  _filterChip('Done', 'delivered', _getCount('delivered'), primaryColor),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Orders list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCC5500)),
                      ),
                    )
                  : _filteredOrders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_rounded, size: 64,
                                  color: textGrey.withOpacity(0.3)),
                              const SizedBox(height: 16),
                              Text('No orders', style: GoogleFonts.plusJakartaSans(
                                fontSize: 18, fontWeight: FontWeight.w600, color: textGrey,
                              )),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => _loadVendorOrders(isInitial: true),
                          color: primaryColor,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _filteredOrders.length,
                            itemBuilder: (ctx, i) => _buildOrderCard(
                              _filteredOrders[i], primaryColor, darkSlate, textGrey,
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value, int count, Color primaryColor) {
    final bool isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? primaryColor : primaryColor.withOpacity(0.2)),
          boxShadow: isSelected
              ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            )),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$count', style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor,
                )),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    Map<String, dynamic> order,
    Color primaryColor,
    Color darkSlate,
    Color textGrey,
  ) {
    final String status = order['orderStatus'];
    final int orderId = order['orderId'];
    final bool driverAssigned = order['driverAssigned'];
    final String? driverName = order['driverName'];
    final String? driverPhone = order['driverPhone'];

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'pending_vendor_confirmation':
        statusColor = const Color(0xFFF59E0B); statusText = 'Awaiting Confirmation'; statusIcon = Icons.hourglass_top_rounded; break;
      case 'vendor_confirmed':
        statusColor = const Color(0xFF10B981); statusText = 'Confirmed'; statusIcon = Icons.check_circle_outline; break;
      case 'driver_assigned':
        statusColor = const Color(0xFF3B82F6); statusText = 'Driver Assigned'; statusIcon = Icons.directions_bike_rounded; break;
      case 'pending':
        statusColor = const Color(0xFFF59E0B); statusText = 'Pending'; statusIcon = Icons.schedule_rounded; break;
      case 'confirmed':
        statusColor = const Color(0xFF3B82F6); statusText = 'Confirmed'; statusIcon = Icons.check_circle_outline; break;
      case 'preparing':
        statusColor = const Color(0xFF8B5CF6); statusText = 'Preparing'; statusIcon = Icons.restaurant_rounded; break;
      case 'ready':
        statusColor = const Color(0xFF06B6D4); statusText = 'Ready'; statusIcon = Icons.shopping_bag_rounded; break;
      case 'picked_up':
        statusColor = const Color(0xFFCC5500); statusText = 'Picked Up'; statusIcon = Icons.local_shipping_rounded; break;
      case 'out_for_delivery':
        statusColor = const Color(0xFFCC5500); statusText = 'Out for Delivery'; statusIcon = Icons.delivery_dining_rounded; break;
      case 'pending_confirmation':
        statusColor = const Color(0xFF8B5CF6); statusText = 'Awaiting Confirm'; statusIcon = Icons.hourglass_empty_rounded; break;
      case 'delivered':
        statusColor = const Color(0xFF10B981); statusText = 'Delivered'; statusIcon = Icons.check_circle_rounded; break;
      case 'cancelled':
        statusColor = const Color(0xFFEF4444); statusText = 'Cancelled'; statusIcon = Icons.cancel_rounded; break;
      default:
        statusColor = textGrey; statusText = status; statusIcon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: status == 'pending_vendor_confirmation'
            ? Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5), width: 2)
            : status == 'vendor_confirmed'
                ? Border.all(color: const Color(0xFF10B981).withOpacity(0.4), width: 1.5)
                : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order['orderNumber'], style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.bold, color: darkSlate,
                    )),
                    Text(order['customerName'].isNotEmpty ? order['customerName'] : 'Customer',
                        style: GoogleFonts.inter(fontSize: 13, color: textGrey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 13),
                    const SizedBox(width: 4),
                    Text(statusText, style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.bold, color: statusColor,
                    )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: textGrey.withOpacity(0.08), height: 1),
          const SizedBox(height: 10),

          // Vendor name
          if (order['vendorName'] != null && order['vendorName'] != 'Vendor')
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Icon(Icons.store_rounded, size: 14, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  order['vendorName'],
                  style: GoogleFonts.inter(fontSize: 13, color: primaryColor, fontWeight: FontWeight.w600),
                ),
              ]),
            ),

          // Customer phone
          Row(children: [
            Icon(Icons.phone, size: 14, color: textGrey),
            const SizedBox(width: 8),
            Text(order['customerPhone'], style: GoogleFonts.inter(fontSize: 13, color: textGrey)),
          ]),
          const SizedBox(height: 6),

          // Address
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.location_on, size: 14, color: textGrey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(order['deliveryAddress'],
                  style: GoogleFonts.inter(fontSize: 13, color: textGrey),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ]),

          // Driver info (when assigned)
          if (driverAssigned && driverName != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.delivery_dining_rounded, size: 16, color: Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      driverPhone != null ? '$driverName • $driverPhone' : driverName,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF10B981)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Amount + Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SDG ${order['finalAmount'].toStringAsFixed(0)}',
                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              Row(
                children: [
                  // View Details/Track Order Button
                  OutlinedButton(
                    onPressed: () => _viewOrderDetails(order),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          driverAssigned && ['picked_up', 'out_for_delivery', 'pending_confirmation'].contains(status)
                              ? Icons.location_on_rounded
                              : Icons.visibility_rounded,
                          size: 14,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          driverAssigned && ['picked_up', 'out_for_delivery', 'pending_confirmation'].contains(status)
                              ? 'Track'
                              : 'Details',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status Update Button
                  _buildActionButton(orderId, status, driverAssigned, primaryColor),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(int orderId, String status, bool driverAssigned, Color primaryColor) {
    // New workflow: pending_vendor_confirmation → vendor_confirmed (or cancelled)
    if (status == 'pending_vendor_confirmation') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => _rejectOrder(orderId),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text('Reject', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _confirmOrder(orderId),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text('Confirm', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      );
    }

    String? nextStatus;
    String? label;
    Color? color;

    switch (status) {
      case 'vendor_confirmed':
        // Waiting for driver — vendor has no further action until driver accepts
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('Awaiting Driver', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF10B981))),
        );
      case 'driver_assigned':
      case 'picked_up':
        nextStatus = 'out_for_delivery'; label = 'Out for Delivery'; color = const Color(0xFF10B981); break;
      case 'confirmed':
        nextStatus = 'preparing'; label = 'Start Preparing'; color = const Color(0xFF8B5CF6); break;
      case 'preparing':
        nextStatus = 'ready'; label = 'Mark Ready'; color = const Color(0xFF06B6D4); break;
      case 'ready':
        if (driverAssigned) { nextStatus = 'out_for_delivery'; label = 'Out for Delivery'; color = const Color(0xFF10B981); }
        break;
    }

    if (nextStatus == null || label == null) {
      if (!driverAssigned && ['pending', 'confirmed', 'preparing', 'ready'].contains(status)) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.hourglass_empty, size: 13, color: Colors.orange),
            const SizedBox(width: 5),
            Text('Awaiting Driver', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.orange)),
          ]),
        );
      }
      return const SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed: () => _updateOrderStatus(orderId, nextStatus!),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  // View order details or track order
  void _viewOrderDetails(Map<String, dynamic> order) {
    final int orderId = order['orderId'];
    final String status = order['orderStatus'];
    final bool driverAssigned = order['driverAssigned'];
    
    // If driver assigned and order is in active delivery, show tracking
    if (driverAssigned && ['picked_up', 'out_for_delivery', 'pending_confirmation'].contains(status)) {
      _showOrderTracking(order);
    } else {
      // Otherwise show order details dialog
      _showOrderDetailsDialog(order);
    }
  }

  // Show order tracking dialog with live status
  void _showOrderTracking(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping_rounded, color: Color(0xFF10B981), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Tracking',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          order['orderNumber'],
                          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF475569)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.grey.withOpacity(0.2)),
              const SizedBox(height: 20),

              // Driver Info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF10B981),
                      child: Text(
                        order['driverName'] != null && order['driverName'].isNotEmpty
                            ? order['driverName'][0].toUpperCase()
                            : 'D',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['driverName'] ?? 'Driver',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            '${order['driverVehicle'] ?? 'Vehicle'} • ${order['driverPlate'] ?? 'N/A'}',
                            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569)),
                          ),
                        ],
                      ),
                    ),
                    if (order['driverPhone'] != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.phone, color: Color(0xFF10B981), size: 18),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Order Status Timeline
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Status',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildTrackingStep('Order Placed', true, true),
                      _buildTrackingStep('Confirmed', true, true),
                      _buildTrackingStep('Preparing', true, true),
                      _buildTrackingStep('Ready for Pickup', true, true),
                      _buildTrackingStep(
                        'Picked Up',
                        ['picked_up', 'out_for_delivery', 'pending_confirmation', 'delivered'].contains(order['orderStatus']),
                        ['picked_up', 'out_for_delivery', 'pending_confirmation', 'delivered'].contains(order['orderStatus']),
                      ),
                      _buildTrackingStep(
                        'Out for Delivery',
                        ['out_for_delivery', 'pending_confirmation', 'delivered'].contains(order['orderStatus']),
                        ['out_for_delivery', 'pending_confirmation', 'delivered'].contains(order['orderStatus']),
                      ),
                      _buildTrackingStep(
                        'Delivered',
                        order['orderStatus'] == 'delivered',
                        false,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Customer Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: Color(0xFFCC5500), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        order['deliveryAddress'],
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildTrackingStep(String label, bool completed, bool showLine) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: completed ? const Color(0xFF10B981) : Colors.grey.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: completed ? const Color(0xFF10B981) : Colors.grey,
                  width: 2,
                ),
              ),
              child: completed
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (showLine)
              Container(
                width: 2,
                height: 30,
                color: completed ? const Color(0xFF10B981) : Colors.grey.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: completed ? FontWeight.w600 : FontWeight.normal,
              color: completed ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
            ),
          ),
        ),
      ],
    );
  }

  // Show order details dialog
  void _showOrderDetailsDialog(Map<String, dynamic> order) {
    final List items = order['items'] ?? [];
    
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCC5500).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: Color(0xFFCC5500), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Details',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          order['orderNumber'],
                          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF475569)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: Colors.grey.withOpacity(0.2)),
              const SizedBox(height: 16),

              // Customer Info
              _buildDetailRow(Icons.person_rounded, 'Customer', order['customerName']),
              _buildDetailRow(Icons.phone_rounded, 'Phone', order['customerPhone']),
              _buildDetailRow(Icons.location_on_rounded, 'Address', order['deliveryAddress']),
              
              const SizedBox(height: 16),
              Divider(color: Colors.grey.withOpacity(0.2)),
              const SizedBox(height: 16),

              // Order Items
              if (items.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Order Items (${items.length})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.shopping_bag_rounded, size: 20, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['product_name'] ?? 'Product',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Qty: ${item['quantity']}',
                                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'SDG ${item['total_price']}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFCC5500),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.withOpacity(0.2)),
              ],

              // Total Amount
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'SDG ${order['finalAmount'].toStringAsFixed(0)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFCC5500),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
