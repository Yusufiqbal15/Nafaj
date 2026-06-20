import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/order_service.dart';
import '../widgets/nafaj_bottom_nav.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';

class UserOrdersScreen extends StatefulWidget {
  const UserOrdersScreen({super.key});

  @override
  State<UserOrdersScreen> createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'all';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_isLoading) _fetchOrders(status: _selectedFilter == 'all' ? null : _selectedFilter, silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrders({String? status, bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final result = await OrderService.getUserOrders(status: status);

      if (result['success'] == true && mounted) {
        setState(() {
          _orders = result['data']['orders'] ?? [];
          _isLoading = false;
        });
      } else if (!silent && mounted) {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to load orders';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!silent && mounted) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmDelivery(int orderId) async {
    // Show confirmation dialog
    final dlgS = AppStrings.direct(
      isArabic: Provider.of<LocaleProvider>(context, listen: false).isArabic,
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 28),
            const SizedBox(width: 12),
            Text(
              dlgS.confirmDeliveryDialogTitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          dlgS.confirmDeliveryDialogMsg,
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              dlgS.cancel,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              dlgS.yesConfirmBtn,
              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
              const SizedBox(height: 16),
              Text(
                dlgS.confirmingDeliveryMsg,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final result = await OrderService.confirmDelivery(orderId);

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      if (result['success'] == true) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                dlgS.deliveryConfirmedSuccess,
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        // Refresh orders list
        _fetchOrders();
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['error'] ?? 'Failed to confirm delivery',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });

    if (filter == 'all') {
      _fetchOrders();
    } else {
      _fetchOrders(status: filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFCC5500);
    const Color bgColor = Color(0xFFFFFBF7);
    const Color darkSlate = Color(0xFF0F172A);
    const Color textGrey = Color(0xFF64748B);
    final locale = Provider.of<LocaleProvider>(context);
    final s = AppStrings.direct(isArabic: locale.isArabic);

    return Directionality(
      textDirection: locale.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        locale.isArabic
                            ? Icons.arrow_forward_rounded
                            : Icons.arrow_back_rounded,
                        color: darkSlate,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.myOrders,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: darkSlate,
                          ),
                        ),
                        Text(
                          s.ordersTotal(_orders.length),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterChip(s.filterAll, 'all', primaryColor),
                  const SizedBox(width: 8),
                  _buildFilterChip(s.filterPending, 'pending', primaryColor),
                  const SizedBox(width: 8),
                  _buildFilterChip(s.filterDelivered, 'delivered', primaryColor),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Orders List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: textGrey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _fetchOrders(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  s.retryBtn,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _orders.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 80,
                                    color: textGrey.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    s.noOrdersYet,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: darkSlate,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    s.ordersWillAppearHere,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () => _fetchOrders(),
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: _orders.length,
                                itemBuilder: (context, index) {
                                  final order = _orders[index];
                                  return _buildOrderCard(
                                    order,
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
      bottomNavigationBar: NafajBottomNav(
        currentIndex: 1,
        onTap: (index) {},
      ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color primaryColor) {
    final bool isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () => _onFilterChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xFFE2E8F0),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
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
    final int orderId = order['id'] ?? 0; // Extract order ID
    final String orderNumber = order['order_number'] ?? 'N/A';
    final String vendorName = order['vendor_name'] ?? 'Vendor';
    final String vendorEmail = order['vendor_email'] ?? '';
    
    // SAFE conversion to double - handles String, int, double, or null
    double finalAmount = 0.0;
    try {
      final amountValue = order['final_amount'];
      if (amountValue != null) {
        if (amountValue is String) {
          finalAmount = double.tryParse(amountValue) ?? 0.0;
        } else if (amountValue is int) {
          finalAmount = amountValue.toDouble();
        } else if (amountValue is double) {
          finalAmount = amountValue;
        }
      }
    } catch (e) {
      finalAmount = 0.0;
    }
    
    final String orderStatus = order['order_status'] ?? 'pending';
    final String createdAt = order['created_at'] ?? '';
    final List items = order['items'] ?? [];

    // Parse date
    DateTime? orderDate;
    try {
      orderDate = DateTime.parse(createdAt);
    } catch (e) {
      orderDate = null;
    }

    final String formattedDate = orderDate != null
        ? '${orderDate.day}/${orderDate.month}/${orderDate.year} ${orderDate.hour}:${orderDate.minute.toString().padLeft(2, '0')}'
        : 'N/A';

    // Status color
    Color statusColor;
    String statusText;
    IconData statusIcon;

    final orderS = AppStrings.direct(
      isArabic: Provider.of<LocaleProvider>(context, listen: false).isArabic,
    );
    switch (orderStatus) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = orderS.statusPending;
        statusIcon = Icons.schedule_rounded;
        break;
      case 'confirmed':
        statusColor = Colors.blue;
        statusText = orderS.statusConfirmedLabel;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'preparing':
        statusColor = Colors.purple;
        statusText = orderS.statusPreparingLabel;
        statusIcon = Icons.restaurant_rounded;
        break;
      case 'ready':
        statusColor = Colors.teal;
        statusText = orderS.statusReadyLabel;
        statusIcon = Icons.shopping_bag_rounded;
        break;
      case 'picked_up':
        statusColor = const Color(0xFF10B981);
        statusText = orderS.statusPickedUpLabel;
        statusIcon = Icons.local_shipping_rounded;
        break;
      case 'out_for_delivery':
        statusColor = const Color(0xFF10B981);
        statusText = orderS.statusOutForDeliveryLabel;
        statusIcon = Icons.delivery_dining_rounded;
        break;
      case 'delivering':
        statusColor = const Color(0xFF10B981);
        statusText = orderS.statusArrivingSoonLabel;
        statusIcon = Icons.delivery_dining_rounded;
        break;
      case 'pending_confirmation':
        statusColor = const Color(0xFF8B5CF6);
        statusText = orderS.statusConfirmReceiptLabel;
        statusIcon = Icons.assignment_turned_in_rounded;
        break;
      case 'delivered':
        statusColor = const Color(0xFF10B981);
        statusText = orderS.statusDeliveredLabel;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = orderS.statusCancelled;
        statusIcon = Icons.cancel_rounded;
        break;
      default:
        statusColor = textGrey;
        statusText = orderStatus;
        statusIcon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderNumber,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: darkSlate,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedDate,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      size: 14,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Vendor Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryColor.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.store_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendorName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: darkSlate,
                        ),
                      ),
                      if (vendorEmail.isNotEmpty)
                        Text(
                          vendorEmail,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: textGrey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Order Items
          if (items.isNotEmpty) ...[
            Text(
              orderS.itemsListCount(items.length),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: darkSlate,
              ),
            ),
            const SizedBox(height: 8),
            ...items.take(3).map((item) {
              final String productName = item['product_name'] ?? 'Product';
              final String productDescription = item['product_description'] ?? '';
              final int quantity = item['quantity'] ?? 0;
              final String productUnit = item['product_unit'] ?? 'pc';
              
              // SAFE conversion to double
              double unitPrice = 0.0;
              try {
                final priceValue = item['unit_price'];
                if (priceValue != null) {
                  if (priceValue is String) {
                    unitPrice = double.tryParse(priceValue) ?? 0.0;
                  } else if (priceValue is int) {
                    unitPrice = priceValue.toDouble();
                  } else if (priceValue is double) {
                    unitPrice = priceValue;
                  }
                }
              } catch (e) {
                unitPrice = 0.0;
              }
              
              // Parse product images
              String? productImage;
              try {
                final images = item['product_images'];
                if (images != null && images.isNotEmpty) {
                  if (images is String) {
                    // Try to parse JSON array
                    final imageList = images.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').split(',');
                    if (imageList.isNotEmpty && imageList[0].isNotEmpty) {
                      productImage = imageList[0].trim();
                    }
                  }
                }
              } catch (e) {
                productImage = null;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    // Product Image
                    if (productImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          productImage,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50,
                              height: 50,
                              color: primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.image_not_supported,
                                color: primaryColor,
                                size: 24,
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.shopping_bag,
                          color: primaryColor,
                          size: 24,
                        ),
                      ),
                    const SizedBox(width: 12),
                    // Product Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: darkSlate,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (productDescription.isNotEmpty)
                            Text(
                              productDescription,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: textGrey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            '$quantity $productUnit × SDG ${unitPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Total Price
                    Text(
                      'SDG ${(unitPrice * quantity).toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: darkSlate,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            if (items.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  orderS.moreItemsLabel(items.length - 3),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],

          // Divider
          Divider(
            color: textGrey.withOpacity(0.2),
            height: 1,
          ),

          const SizedBox(height: 12),

          // Total Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderS.totalAmountLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: darkSlate,
                ),
              ),
              Text(
                'SDG ${finalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // View order details
                    _showOrderDetails(order);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    orderS.viewDetailsBtn,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (orderStatus == 'pending_confirmation')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Confirm delivery
                      _confirmDelivery(orderId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      orderS.confirmDeliveryBtn,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else if (orderStatus == 'delivered' || orderStatus == 'picked_up' || orderStatus == 'out_for_delivery')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Track order
                      Navigator.pushNamed(
                        context,
                        '/order_tracking',
                        arguments: {
                          'restaurant': vendorName,
                          'earnings': 'SDG ${finalAmount.toStringAsFixed(2)}',
                          'distance': '2.5 km',
                          'time': '15 mins',
                          'lat': 15.5087,
                          'lng': 32.5599,
                          'address': order['delivery_address'] ?? '',
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      orderS.trackOrderBtn,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final items = order['items'] ?? [];
        final sheetS = AppStrings.direct(
          isArabic: Provider.of<LocaleProvider>(context, listen: false).isArabic,
        );
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  sheetS.orderDetailsTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildDetailRow(sheetS.orderNumberLabel, order['order_number']),
                    _buildDetailRow(sheetS.filterAll, order['order_status']),
                    _buildDetailRow(sheetS.vendorNameLabel, order['vendor_name']),
                    _buildDetailRow(sheetS.vendorEmailLabel, order['vendor_email']),
                    _buildDetailRow(sheetS.deliveryAddressLabel, order['delivery_address']),
                    _buildDetailRow(sheetS.paymentMethodLabel, order['payment_method']),
                    _buildDetailRow(sheetS.totalAmountLabel, 'SDG ${order['final_amount']}'),
                    const SizedBox(height: 16),
                    Text(
                      sheetS.orderItemsLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...items.map((item) => _buildItemRow(item)).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item) {
    final String productName = item['product_name'] ?? 'Product';
    final String productDescription = item['product_description'] ?? '';
    final int quantity = item['quantity'] ?? 0;
    final String productUnit = item['product_unit'] ?? 'pc';
    final String categoryName = item['category_name'] ?? '';
    
    // SAFE conversion for prices
    double unitPrice = 0.0;
    double totalPrice = 0.0;
    
    try {
      final priceValue = item['unit_price'];
      if (priceValue != null) {
        if (priceValue is String) {
          unitPrice = double.tryParse(priceValue) ?? 0.0;
        } else if (priceValue is int) {
          unitPrice = priceValue.toDouble();
        } else if (priceValue is double) {
          unitPrice = priceValue;
        }
      }
    } catch (e) {
      unitPrice = 0.0;
    }
    
    try {
      final totalValue = item['total_price'];
      if (totalValue != null) {
        if (totalValue is String) {
          totalPrice = double.tryParse(totalValue) ?? 0.0;
        } else if (totalValue is int) {
          totalPrice = totalValue.toDouble();
        } else if (totalValue is double) {
          totalPrice = totalValue;
        }
      }
    } catch (e) {
      totalPrice = unitPrice * quantity;
    }
    
    // Parse product image
    String? productImage;
    try {
      final images = item['product_images'];
      if (images != null && images.isNotEmpty) {
        if (images is String) {
          final imageList = images.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').split(',');
          if (imageList.isNotEmpty && imageList[0].isNotEmpty) {
            productImage = imageList[0].trim();
          }
        }
      }
    } catch (e) {
      productImage = null;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFCC5500).withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          // Product Image
          if (productImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                productImage,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: const Color(0xFFCC5500).withOpacity(0.1),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Color(0xFFCC5500),
                      size: 30,
                    ),
                  );
                },
              ),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFCC5500).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shopping_bag,
                color: Color(0xFFCC5500),
                size: 30,
              ),
            ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (productDescription.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      productDescription,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (categoryName.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCC5500).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        categoryName,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: const Color(0xFFCC5500),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$quantity $productUnit',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      ' × SDG ${unitPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Total Price
          Text(
            'SDG ${totalPrice.toStringAsFixed(2)}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFCC5500),
            ),
          ),
        ],
      ),
    );
  }
}
