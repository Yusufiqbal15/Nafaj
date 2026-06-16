import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/order_service.dart';

class VendorSalesReportScreen extends StatefulWidget {
  const VendorSalesReportScreen({super.key});

  @override
  State<VendorSalesReportScreen> createState() =>
      _VendorSalesReportScreenState();
}

class _VendorSalesReportScreenState extends State<VendorSalesReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Period selector: maps display label → API param
  static const _periods = {
    'Today': 'today',
    'This Week': 'week',
    'This Month': 'month',
    'All Time': 'all_time',
  };
  String _selectedPeriodLabel = 'This Week';

  bool _isLoading = false;
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> _topProducts = [];
  List<Map<String, dynamic>> _dailySales = [];
  Map<String, dynamic> _stats = {
    'totalOrders': 0,
    'totalRevenue': 0,
    'completedOrders': 0,
    'cancelledOrders': 0,
    'pendingOrders': 0,
    'growthPct': null,
    'prevRevenue': 0,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    final period = _periods[_selectedPeriodLabel] ?? 'week';
    final result = await OrderService.getVendorSalesReport(period);
    if (result['success'] == true && mounted) {
      final data = Map<String, dynamic>.from(result['data'] ?? {});
      setState(() {
        _orders = _parseList(data['orders']);
        _topProducts = _parseList(data['topProducts']);
        _dailySales = _parseList(data['dailySales']);
        _stats = Map<String, dynamic>.from(data['stats'] ?? _stats);
        _isLoading = false;
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _parseList(dynamic raw) {
    if (raw is List) return raw.map((e) => Map<String, dynamic>.from(e)).toList();
    return [];
  }

  // ─── Getters ───────────────────────────────────────────────────────────────
  double get _totalRevenue => double.tryParse(_stats['totalRevenue']?.toString() ?? '0') ?? 0;
  int get _totalOrders => int.tryParse(_stats['totalOrders']?.toString() ?? '0') ?? 0;
  int get _completedOrders => int.tryParse(_stats['completedOrders']?.toString() ?? '0') ?? 0;
  int get _cancelledOrders => int.tryParse(_stats['cancelledOrders']?.toString() ?? '0') ?? 0;
  int get _pendingOrders => int.tryParse(_stats['pendingOrders']?.toString() ?? '0') ?? 0;
  int? get _growthPct => _stats['growthPct'] != null ? int.tryParse(_stats['growthPct'].toString()) : null;

  List<Map<String, dynamic>> _getDailyBars() {
    final List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final Map<String, double> byDate = {};
    for (final d in _dailySales) {
      final dateStr = d['sale_date']?.toString().split('T')[0] ?? '';
      byDate[dateStr] = double.tryParse(d['daily_sales']?.toString() ?? '0') ?? 0;
    }
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      final ds = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      return {'day': dayNames[date.weekday - 1], 'amount': byDate[ds] ?? 0.0};
    });
  }

  // ─── Formatters ────────────────────────────────────────────────────────────
  String _formatSDG(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M SDG';
    if (v >= 1000) {
      final str = v.toStringAsFixed(0);
      final buf = StringBuffer();
      for (int i = 0; i < str.length; i++) {
        if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
        buf.write(str[i]);
      }
      return '${buf.toString()} SDG';
    }
    return '${v.toStringAsFixed(0)} SDG';
  }

  String _formatDate(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final d = DateTime(dt.year, dt.month, dt.day);
      final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      if (d == today) return 'Today, $timeStr';
      if (d == today.subtract(const Duration(days: 1))) return 'Yesterday, $timeStr';
      return '${dt.day}/${dt.month}, $timeStr';
    } catch (_) {
      return raw;
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
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
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: primaryColor.withOpacity(0.06))),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryColor.withOpacity(0.1)),
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: darkSlate, size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Sales Report',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22, fontWeight: FontWeight.bold, color: darkSlate,
                          ),
                        ),
                      ),
                      if (_isLoading)
                        const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2),
                        )
                      else
                        GestureDetector(
                          onTap: _loadReport,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: primaryColor.withOpacity(0.1)),
                            ),
                            child: Icon(Icons.refresh_rounded, color: primaryColor, size: 20),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Period filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _periods.keys.map((label) {
                        final isActive = _selectedPeriodLabel == label;
                        return GestureDetector(
                          onTap: () {
                            if (_selectedPeriodLabel != label) {
                              setState(() => _selectedPeriodLabel = label);
                              _loadReport();
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive ? primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isActive ? primaryColor : primaryColor.withOpacity(0.12),
                              ),
                            ),
                            child: Text(
                              label,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isActive ? Colors.white : textGrey,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: _isLoading && _orders.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: primaryColor))
                  : RefreshIndicator(
                      onRefresh: _loadReport,
                      color: primaryColor,
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          const SliverToBoxAdapter(child: SizedBox(height: 20)),

                          // Revenue Summary Card
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFFCC5500), Color(0xFFE67322)],
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.25),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total Revenue',
                                      style: GoogleFonts.inter(
                                        fontSize: 14, color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatSDG(_totalRevenue),
                                      style: GoogleFonts.inter(
                                        fontSize: 34, fontWeight: FontWeight.w900,
                                        color: Colors.white, height: 1,
                                      ),
                                    ),
                                    if (_growthPct != null) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${_growthPct! >= 0 ? '↑' : '↓'} ${_growthPct!.abs()}% vs previous period',
                                          style: GoogleFonts.inter(
                                            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        _buildRevenueStat('Orders', '$_totalOrders', Icons.receipt_rounded),
                                        const SizedBox(width: 10),
                                        _buildRevenueStat('Completed', '$_completedOrders', Icons.check_circle_rounded),
                                        const SizedBox(width: 10),
                                        _buildRevenueStat('Pending', '$_pendingOrders', Icons.hourglass_top_rounded),
                                        const SizedBox(width: 10),
                                        _buildRevenueStat('Cancelled', '$_cancelledOrders', Icons.cancel_rounded),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SliverToBoxAdapter(child: SizedBox(height: 20)),

                          // Weekly Chart (last 7 days, always)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: primaryColor.withOpacity(0.06)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Last 7 Days',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16, fontWeight: FontWeight.bold, color: darkSlate,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Builder(builder: (_) {
                                      final bars = _getDailyBars();
                                      final maxAmt = bars.map((b) => b['amount'] as double).fold(0.0, (a, b) => a > b ? a : b);
                                      return SizedBox(
                                        height: 130,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: bars.map((b) {
                                            final h = maxAmt > 0
                                                ? ((b['amount'] as double) / maxAmt).clamp(0.05, 1.0)
                                                : 0.05;
                                            return _buildBar(b['day'] as String, h, primaryColor, textGrey);
                                          }).toList(),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SliverToBoxAdapter(child: SizedBox(height: 20)),

                          // Tabs: All Orders / Top Products
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  onTap: (_) => setState(() {}),
                                  indicator: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  labelColor: Colors.white,
                                  unselectedLabelColor: textGrey,
                                  labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                                  unselectedLabelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                                  dividerColor: Colors.transparent,
                                  indicatorPadding: const EdgeInsets.all(4),
                                  tabs: [
                                    Tab(text: 'All Orders ($_totalOrders)'),
                                    Tab(text: 'Top Products'),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SliverToBoxAdapter(child: SizedBox(height: 16)),

                          // Tab content
                          if (_tabController.index == 0)
                            _orders.isEmpty
                                ? SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 32),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Icon(Icons.receipt_long_outlined, size: 48, color: textGrey.withOpacity(0.4)),
                                            const SizedBox(height: 12),
                                            Text('No orders for this period',
                                                style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 16, fontWeight: FontWeight.w600, color: darkSlate)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) => _buildOrderRow(
                                          _orders[index], primaryColor, darkSlate, textGrey),
                                      childCount: _orders.length,
                                    ),
                                  )
                          else
                            _topProducts.isEmpty
                                ? SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 32),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Icon(Icons.inventory_2_outlined, size: 48, color: textGrey.withOpacity(0.4)),
                                            const SizedBox(height: 12),
                                            Text('No product sales yet',
                                                style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 16, fontWeight: FontWeight.w600, color: darkSlate)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) => _buildTopProductRow(
                                          index, _topProducts[index], primaryColor, darkSlate, textGrey),
                                      childCount: _topProducts.length,
                                    ),
                                  ),

                          // Summary Footer
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: primaryColor.withOpacity(0.1)),
                                ),
                                child: Column(
                                  children: [
                                    _buildSummaryRow('Total Orders', '$_totalOrders', darkSlate),
                                    _buildSummaryRow('Completed Orders', '$_completedOrders', const Color(0xFF10B981)),
                                    _buildSummaryRow('Cancelled Orders', '$_cancelledOrders', const Color(0xFFEF4444)),
                                    _buildSummaryRow(
                                      'Avg. Order Value',
                                      _completedOrders > 0
                                          ? _formatSDG(_totalRevenue / _completedOrders)
                                          : '0 SDG',
                                      const Color(0xFF3B82F6),
                                    ),
                                    Container(
                                      height: 1,
                                      margin: const EdgeInsets.symmetric(vertical: 10),
                                      color: const Color(0xFFF1F5F9),
                                    ),
                                    _buildSummaryRow('Gross Revenue', _formatSDG(_totalRevenue), primaryColor, isBold: true),
                                    _buildSummaryRow('Platform Fee (15%)', '-${_formatSDG(_totalRevenue * 0.15)}', const Color(0xFFEF4444)),
                                    _buildSummaryRow('Net Earnings', _formatSDG(_totalRevenue * 0.85), const Color(0xFF10B981), isBold: true),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SliverToBoxAdapter(child: SizedBox(height: 30)),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Component Builders ────────────────────────────────────────────────────
  Widget _buildRevenueStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.8), size: 16),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 10, color: Colors.white.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String label, double height, Color primaryColor, Color textGrey) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: 100 * height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [primaryColor, primaryColor.withOpacity(0.5)],
            ),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildOrderRow(
    Map<String, dynamic> order,
    Color primaryColor,
    Color darkSlate,
    Color textGrey,
  ) {
    final status = order['order_status']?.toString() ?? 'pending';
    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'pending':
      case 'pending_vendor_confirmation':
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case 'preparing':
      case 'vendor_confirmed':
      case 'confirmed':
        statusColor = const Color(0xFF3B82F6);
        statusIcon = Icons.restaurant_rounded;
        break;
      case 'cancelled':
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.cancel_rounded;
        break;
      case 'delivered':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle_rounded;
        break;
      default:
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.local_shipping_rounded;
    }

    final amount = double.tryParse(order['final_amount']?.toString() ?? '0') ?? 0;
    final customer = order['customer_name']?.toString().trim() ?? order['user_email']?.toString() ?? 'Customer';
    final items = order['items_summary']?.toString() ?? '';
    final orderId = order['order_number']?.toString() ?? '#${order['id']}';
    final payment = order['payment_method']?.toString() ?? 'cash';
    final date = _formatDate(order['created_at']?.toString());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(statusIcon, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(orderId,
                            style: GoogleFonts.inter(
                                fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(_formatSDG(amount),
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${customer.isNotEmpty ? customer : 'Customer'}${items.isNotEmpty ? ' • $items' : ''}',
                    style: GoogleFonts.inter(fontSize: 12, color: textGrey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status.toUpperCase().replaceAll('_', ' '),
                              style: GoogleFonts.inter(
                                  fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              payment.toUpperCase(),
                              style: GoogleFonts.inter(
                                  fontSize: 10, fontWeight: FontWeight.w600, color: textGrey),
                            ),
                          ),
                        ],
                      ),
                      Text(date,
                          style: GoogleFonts.inter(fontSize: 11, color: textGrey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductRow(
    int index,
    Map<String, dynamic> product,
    Color primaryColor,
    Color darkSlate,
    Color textGrey,
  ) {
    final colors = [
      primaryColor,
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
    ];
    final color = colors[index % colors.length];
    final revenue = double.tryParse(product['totalRevenue']?.toString() ?? '0') ?? 0;
    final sold = int.tryParse(product['totalSold']?.toString() ?? '0') ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '#${index + 1}',
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name']?.toString() ?? 'Product',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 15, fontWeight: FontWeight.bold, color: darkSlate),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.shopping_bag_rounded, size: 14, color: textGrey),
                      const SizedBox(width: 4),
                      Text('$sold sold',
                          style: GoogleFonts.inter(fontSize: 12, color: textGrey)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatSDG(revenue),
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.bold, color: primaryColor),
                ),
                const SizedBox(height: 2),
                Text('Revenue',
                    style: GoogleFonts.inter(fontSize: 11, color: textGrey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: const Color(0xFF475569))),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: valueColor)),
        ],
      ),
    );
  }
}
