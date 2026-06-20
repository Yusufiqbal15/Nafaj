import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/order_service.dart';
import '../services/api_service.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';

class DriverDeliveryHistoryScreen extends StatefulWidget {
  const DriverDeliveryHistoryScreen({super.key});

  @override
  State<DriverDeliveryHistoryScreen> createState() =>
      _DriverDeliveryHistoryScreenState();
}

class _DriverDeliveryHistoryScreenState
    extends State<DriverDeliveryHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<Map<String, dynamic>> _deliveries = [];
  bool _isLoading = true;
  int? _driverId;

  AppStrings _s = AppStrings.direct(isArabic: false);
  bool _isAr = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDriverDeliveries();
  }
  
  Future<void> _loadDriverDeliveries() async {
    setState(() => _isLoading = true);
    
    try {
      // Check if driver is logged in
      final isLoggedIn = await ApiService.isLoggedIn();
      final userType = await ApiService.getUserType();
      
      if (!isLoggedIn || userType != 'driver') {
        print('❌ Driver not logged in or wrong user type: $userType');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _s.loginAsDriverToView,
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: _s.loginAction,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/driver_login');
                },
              ),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      
      // Get driver ID from storage
      _driverId = await ApiService.getUserId();
      
      print('🔍 Loading deliveries for driver ID: $_driverId');
      
      // Fetch driver's accepted orders (without status to get all driver's orders)
      final result = await OrderService.getDriverOrders(); // No status filter
      
      if (result['success'] == true && mounted) {
        final orders = result['data']['orders'] as List;
        
        print('📦 Fetched ${orders.length} orders for driver $_driverId');
        
        setState(() {
          _deliveries = orders.map((order) {
            // Parse amounts
            final finalAmount = double.tryParse(order['final_amount']?.toString() ?? '0') ?? 0.0;
            final deliveryFee = double.tryParse(order['delivery_fee']?.toString() ?? '0') ?? 0.0;
            
            // Determine status text
            String statusText = 'pending';
            if (order['order_status'] == 'delivered') {
              statusText = 'completed';
            } else if (order['order_status'] == 'cancelled') {
              statusText = 'cancelled';
            } else if (order['order_status'] == 'pending_confirmation') {
              statusText = 'pending_confirmation';
            } else if (order['order_status'] == 'picked_up' || order['order_status'] == 'out_for_delivery') {
              statusText = 'in_progress';
            }
            
            return {
              'id': order['order_number'] ?? 'N/A',
              'pickup': order['vendor_address'] ?? 'Restaurant',
              'dropoff': order['delivery_address'] ?? 'Customer Address',
              'date': _formatDate(order['created_at']),
              'distance': 'N/A', // Calculate if needed
              'amount': '${finalAmount.toStringAsFixed(0)} SDG',
              'status': statusText,
              'customerName': '${order['first_name'] ?? ''} ${order['last_name'] ?? ''}'.trim(),
              'duration': '—',
              'orderId': order['id'],
              'driverId': order['driver_id'],
            };
          }).toList();
          
          _isLoading = false;
        });
      } else {
        print('❌ Failed to load orders: ${result['error']}');
        if (mounted && result['error'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['error'],
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Error loading deliveries: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _s.errorLoadingDeliveries,
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }
  
  String _formatDate(String? dateStr) {
    if (dateStr == null) return _s.naLabel;

    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      final timeStr = '${date.hour}:${date.minute.toString().padLeft(2, '0')}';

      if (diff.inDays == 0) {
        return '${_s.todayPrefix}$timeStr';
      } else if (diff.inDays == 1) {
        return '${_s.yesterdayPrefix}$timeStr';
      } else {
        return '${date.day} ${_getMonthName(date.month)}, $timeStr';
      }
    } catch (e) {
      return dateStr;
    }
  }

  String _getMonthName(int month) {
    if (_isAr) {
      const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
                      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
      return months[month - 1];
    }
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredDeliveries {
    switch (_tabController.index) {
      case 1:
        return _deliveries.where((d) => d['status'] == 'completed').toList();
      case 2:
        return _deliveries.where((d) => d['status'] == 'cancelled').toList();
      default:
        return _deliveries;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    _s = AppStrings.direct(isArabic: localeProvider.isArabic);
    _isAr = localeProvider.isArabic;

    const Color primaryColor = Color(0xFFCC5500);
    const Color bgColor = Color(0xFFFFFBF7);
    const Color darkSlate = Color(0xFF0F172A);
    const Color textGrey = Color(0xFF475569);

    int completedCount = _deliveries
        .where((d) => d['status'] == 'completed')
        .length;
    int cancelledCount = _deliveries
        .where((d) => d['status'] == 'cancelled')
        .length;

    return Directionality(
      textDirection: _isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
      backgroundColor: bgColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCC5500)),
              ),
            )
          : SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                          color: primaryColor.withOpacity(0.12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: darkSlate,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _s.deliveryHistoryTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: darkSlate,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryColor.withOpacity(0.12)),
                    ),
                    child: const Icon(
                      Icons.filter_list_rounded,
                      color: darkSlate,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // ── Stats Row ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildStatCard(
                    _s.total,
                    '${_deliveries.length}',
                    Icons.local_shipping_rounded,
                    primaryColor,
                    darkSlate,
                    textGrey,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    _s.completed,
                    '$completedCount',
                    Icons.check_circle_rounded,
                    const Color(0xFF10B981),
                    darkSlate,
                    textGrey,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    _s.cancelled,
                    '$cancelledCount',
                    Icons.cancel_rounded,
                    const Color(0xFFEF4444),
                    darkSlate,
                    textGrey,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Tab Bar ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColor.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (_) => setState(() {}),
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFCC5500), Color(0xFFE67322)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: textGrey,
                labelStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                dividerColor: Colors.transparent,
                indicatorPadding: const EdgeInsets.all(4),
                tabs: [
                  Tab(text: _s.tabAll),
                  Tab(text: _s.tabCompleted),
                  Tab(text: _s.tabCancelled),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Delivery List ──
            Expanded(
              child: _deliveries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 64,
                            color: textGrey.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _s.noDeliveryHistory,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textGrey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _s.acceptOrdersToSee,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: textGrey.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadDriverDeliveries,
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(
                              _s.refresh,
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadDriverDeliveries,
                      color: primaryColor,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredDeliveries.length,
                        itemBuilder: (context, index) {
                          return _buildDeliveryCard(
                            _filteredDeliveries[index],
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

      // ── Bottom Nav ──
      bottomNavigationBar: _buildDriverBottomNav(context, 1),
    ), // Scaffold
    ); // Directionality
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Color darkSlate,
    Color textGrey,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkSlate,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(
    Map<String, dynamic> delivery,
    Color primaryColor,
    Color darkSlate,
    Color textGrey,
  ) {
    final String status = delivery['status'];
    final bool isCompleted = status == 'completed';
    final bool isCancelled = status == 'cancelled';
    final bool isInProgress = status == 'in_progress';
    final bool isPendingConfirmation = status == 'pending_confirmation';
    
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    if (isCompleted) {
      statusColor = const Color(0xFF10B981);
      statusText = _s.statusCompleted;
      statusIcon = Icons.check_circle_rounded;
    } else if (isCancelled) {
      statusColor = const Color(0xFFEF4444);
      statusText = _s.statusCancelled;
      statusIcon = Icons.cancel_rounded;
    } else if (isPendingConfirmation) {
      statusColor = const Color(0xFF8B5CF6);
      statusText = _s.statusAwaitingConfirmation;
      statusIcon = Icons.hourglass_empty_rounded;
    } else if (isInProgress) {
      statusColor = const Color(0xFFF59E0B);
      statusText = _s.statusInProgress;
      statusIcon = Icons.local_shipping_rounded;
    } else {
      statusColor = primaryColor;
      statusText = _s.statusPending;
      statusIcon = Icons.pending_rounded;
    }

    return InkWell(
      onTap: () async {
        // Navigate to detailed tracking for in_progress orders only
        // Don't allow editing pending_confirmation orders
        if (isInProgress && !isPendingConfirmation) {
          final result = await Navigator.pushNamed(
            context,
            '/driver_order_tracking_detailed',
            arguments: {
              'orderId': delivery['orderId'],
              'id': delivery['orderId'],
              'orderNumber': delivery['id'],
              'restaurant': delivery['pickup'],
              'address': delivery['dropoff'],
              'earnings': delivery['amount'],
              'status': status,
            },
          );
          
          // Refresh if tracking completed
          if (result == true) {
            _loadDriverDeliveries();
          }
        } else if (isPendingConfirmation) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _s.waitingCustomerDelivery,
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF8B5CF6),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top row - ID and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  delivery['id'],
                  style: GoogleFonts.inter(
                    fontSize: 14,
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        color: statusColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Route
            Row(
              children: [
                Column(
                  children: [
                    Icon(
                      Icons.my_location_rounded,
                      color: primaryColor,
                      size: 16,
                    ),
                    Container(
                      width: 1.5,
                      height: 20,
                      color: primaryColor.withOpacity(0.2),
                    ),
                    const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFEF4444),
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery['pickup'],
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: darkSlate,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        delivery['dropoff'],
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

            const SizedBox(height: 14),
            Container(height: 1, color: primaryColor.withOpacity(0.06)),
            const SizedBox(height: 14),

            // Bottom details row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailChip(
                  Icons.person_rounded,
                  delivery['customerName'],
                  textGrey,
                ),
                _buildDetailChip(
                  Icons.schedule_rounded,
                  delivery['duration'],
                  textGrey,
                ),
                _buildDetailChip(
                  Icons.straighten_rounded,
                  delivery['distance'],
                  textGrey,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Amount and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  delivery['date'],
                  style: GoogleFonts.inter(fontSize: 12, color: textGrey),
                ),
                Text(
                  delivery['amount'],
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? const Color(0xFF10B981) : textGrey,
                  ),
                ),
              ],
            ),
            
            // Show "Tap to continue" for in-progress orders
            if (isInProgress) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _s.tapToContinueTracking,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Show waiting message for pending confirmation
            if (isPendingConfirmation) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: statusColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _s.waitingForCustomerConfirmation,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text, Color textGrey) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: textGrey),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textGrey,
          ),
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
        border: Border(top: BorderSide(color: primaryColor.withOpacity(0.08))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                          color: primaryColor.withOpacity(0.08),
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
