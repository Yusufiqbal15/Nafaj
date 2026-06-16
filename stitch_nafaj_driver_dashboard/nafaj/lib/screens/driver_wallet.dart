import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/order_service.dart';

class DriverWalletScreen extends StatefulWidget {
  const DriverWalletScreen({super.key});

  @override
  State<DriverWalletScreen> createState() => _DriverWalletScreenState();
}

class _DriverWalletScreenState extends State<DriverWalletScreen> {
  bool _isLoading = false;
  Map<String, dynamic> _wallet = {};
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _deliveredOrders = [];
  int _activeTab = 0; // 0 = Transactions, 1 = Deliveries

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    setState(() => _isLoading = true);
    final result = await OrderService.getDriverWallet();
    if (result['success'] == true && mounted) {
      final data = Map<String, dynamic>.from(result['data'] ?? {});
      setState(() {
        _wallet = data;
        _transactions = _parseList(data['transactions']);
        _deliveredOrders = _parseList(data['deliveredOrders']);
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

  double get _walletBalance => double.tryParse(_wallet['walletBalance']?.toString() ?? '0') ?? 0;
  double get _weekEarnings => double.tryParse(_wallet['weekEarnings']?.toString() ?? '0') ?? 0;
  double get _totalEarnings => double.tryParse(_wallet['totalEarnings']?.toString() ?? '0') ?? 0;
  int get _weekDeliveries => int.tryParse(_wallet['weekDeliveries']?.toString() ?? '0') ?? 0;
  int get _totalDeliveries => int.tryParse(_wallet['totalDeliveries']?.toString() ?? '0') ?? 0;

  String _formatSDG(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) {
      final str = v.toStringAsFixed(0);
      final buf = StringBuffer();
      for (int i = 0; i < str.length; i++) {
        if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
        buf.write(str[i]);
      }
      return buf.toString();
    }
    return v.toStringAsFixed(0);
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
      return raw ?? '';
    }
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : RefreshIndicator(
                onRefresh: _loadWallet,
                color: primaryColor,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Padding(
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
                                  border: Border.all(color: primaryColor.withOpacity(0.12)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8, offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.arrow_back_rounded, color: darkSlate, size: 20),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text('My Wallet',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 22, fontWeight: FontWeight.bold, color: darkSlate)),
                            ),
                            GestureDetector(
                              onTap: _loadWallet,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: primaryColor.withOpacity(0.12)),
                                ),
                                child: Icon(Icons.refresh_rounded, color: primaryColor, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Balance Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFCC5500), Color(0xFFE67322)],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Available Balance',
                                      style: GoogleFonts.inter(
                                          fontSize: 14, fontWeight: FontWeight.w500,
                                          color: Colors.white.withOpacity(0.8))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.account_balance_rounded, color: Colors.white, size: 14),
                                        const SizedBox(width: 4),
                                        Text('SDG',
                                            style: GoogleFonts.inter(
                                                fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _formatSDG(_walletBalance),
                                style: GoogleFonts.inter(
                                    fontSize: 40, fontWeight: FontWeight.w900,
                                    color: Colors.white, height: 1),
                              ),
                              Text('SDG',
                                  style: GoogleFonts.inter(
                                      fontSize: 16, fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.7))),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Center(
                                        child: Text('Withdraw',
                                            style: GoogleFonts.inter(
                                                fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                                      ),
                                      child: Center(
                                        child: Text('History',
                                            style: GoogleFonts.inter(
                                                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 20)),

                    // Delivery Stats Row
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _buildStatCard('500 SDG', 'Per Delivery', Icons.local_shipping_rounded, primaryColor, darkSlate, textGrey),
                            const SizedBox(width: 12),
                            _buildStatCard('$_totalDeliveries', 'Total Done', Icons.check_circle_rounded, const Color(0xFF10B981), darkSlate, textGrey),
                            const SizedBox(width: 12),
                            _buildStatCard('$_weekDeliveries', 'This Week', Icons.calendar_today_rounded, const Color(0xFF3B82F6), darkSlate, textGrey),
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 20)),

                    // Weekly Earnings Summary
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: primaryColor.withOpacity(0.08)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10, offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("This Week's Earnings",
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16, fontWeight: FontWeight.bold, color: darkSlate)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildEarningsItem('Deliveries', _formatSDG(_weekEarnings), primaryColor, darkSlate, textGrey),
                                  const SizedBox(width: 16),
                                  _buildEarningsItem('Total All-Time', _formatSDG(_totalEarnings), const Color(0xFF8B5CF6), darkSlate, textGrey),
                                  const SizedBox(width: 16),
                                  _buildEarningsItem('Per Order', '500', const Color(0xFFF59E0B), darkSlate, textGrey),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(height: 1, color: primaryColor.withOpacity(0.06)),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Week Deliveries',
                                          style: GoogleFonts.inter(fontSize: 12, color: textGrey)),
                                      Text('$_weekDeliveries × 500 SDG',
                                          style: GoogleFonts.inter(
                                              fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('Week Earnings',
                                          style: GoogleFonts.inter(fontSize: 12, color: textGrey)),
                                      Text('${_formatSDG(_weekEarnings)} SDG',
                                          style: GoogleFonts.inter(
                                              fontSize: 18, fontWeight: FontWeight.bold,
                                              color: const Color(0xFF10B981))),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    // Tab selector: Transactions | Delivered Orders
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              _buildTab(0, 'Earnings (${_transactions.length})', primaryColor, darkSlate),
                              _buildTab(1, 'Deliveries (${_deliveredOrders.length})', primaryColor, darkSlate),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 12)),

                    // Tab content
                    if (_activeTab == 0) ...[
                      _transactions.isEmpty
                          ? SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.account_balance_wallet_outlined,
                                          size: 48, color: textGrey.withOpacity(0.4)),
                                      const SizedBox(height: 12),
                                      Text('No transactions yet',
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16, fontWeight: FontWeight.w600, color: darkSlate)),
                                      const SizedBox(height: 4),
                                      Text('Complete deliveries to earn 500 SDG each',
                                          style: GoogleFonts.inter(fontSize: 13, color: textGrey)),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) =>
                                    _buildTransactionItem(_transactions[index], darkSlate, textGrey, primaryColor),
                                childCount: _transactions.length,
                              ),
                            ),
                    ] else ...[
                      _deliveredOrders.isEmpty
                          ? SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.local_shipping_outlined,
                                          size: 48, color: textGrey.withOpacity(0.4)),
                                      const SizedBox(height: 12),
                                      Text('No deliveries yet',
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16, fontWeight: FontWeight.w600, color: darkSlate)),
                                      const SizedBox(height: 4),
                                      Text('Your completed deliveries will appear here',
                                          style: GoogleFonts.inter(fontSize: 13, color: textGrey)),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) =>
                                    _buildDeliveredOrderItem(_deliveredOrders[index], darkSlate, textGrey, primaryColor),
                                childCount: _deliveredOrders.length,
                              ),
                            ),
                    ],

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _buildDriverBottomNav(context, 2),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color, Color darkSlate, Color textGrey) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: darkSlate)),
            Text(label, style: GoogleFonts.inter(fontSize: 10, color: textGrey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsItem(String label, String amount, Color color, Color darkSlate, Color textGrey) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              label == 'Deliveries' || label.contains('Week')
                  ? Icons.local_shipping_rounded
                  : label == 'Per Order'
                      ? Icons.payments_rounded
                      : Icons.show_chart_rounded,
              color: color, size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(amount,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: darkSlate)),
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: textGrey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx, Color darkSlate, Color textGrey, Color primaryColor) {
    final type = tx['transaction_type']?.toString() ?? 'delivery_fee';
    final amount = double.tryParse(tx['amount']?.toString() ?? '0') ?? 0;
    final balanceAfter = double.tryParse(tx['balance_after']?.toString() ?? '0') ?? 0;
    final description = tx['description']?.toString() ?? 'Delivery Payment';
    final orderNumber = tx['order_number']?.toString() ?? '';
    final date = _formatDate(tx['created_at']?.toString());

    Color amountColor;
    IconData icon;
    Color iconBg;
    final bool isCredit = type == 'delivery_fee' || type == 'bonus';

    switch (type) {
      case 'delivery_fee':
        amountColor = const Color(0xFF10B981);
        icon = Icons.local_shipping_rounded;
        iconBg = const Color(0xFF10B981);
        break;
      case 'bonus':
        amountColor = const Color(0xFF8B5CF6);
        icon = Icons.star_rounded;
        iconBg = const Color(0xFF8B5CF6);
        break;
      case 'withdrawal':
        amountColor = const Color(0xFFEF4444);
        icon = Icons.arrow_upward_rounded;
        iconBg = const Color(0xFFEF4444);
        break;
      default:
        amountColor = const Color(0xFF3B82F6);
        icon = Icons.swap_horiz_rounded;
        iconBg = const Color(0xFF3B82F6);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: iconBg.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconBg, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type == 'delivery_fee' ? 'Delivery Fee' : type == 'bonus' ? 'Bonus' : 'Withdrawal',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: darkSlate),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    orderNumber.isNotEmpty ? '$orderNumber • $description' : description,
                    style: GoogleFonts.inter(fontSize: 11, color: textGrey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Balance: ${_formatSDG(balanceAfter)} SDG',
                    style: GoogleFonts.inter(fontSize: 10, color: textGrey.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'}${_formatSDG(amount)} SDG',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: amountColor),
                ),
                const SizedBox(height: 2),
                Text(date, style: GoogleFonts.inter(fontSize: 10, color: textGrey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label, Color primaryColor, Color darkSlate) {
    final isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? primaryColor : darkSlate.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveredOrderItem(Map<String, dynamic> order, Color darkSlate, Color textGrey, Color primaryColor) {
    final orderNumber = order['order_number']?.toString() ?? 'N/A';
    final vendorName = order['vendor_name']?.toString() ?? 'Unknown Vendor';
    final customerName = order['customer_name']?.toString().trim() ?? '';
    final finalAmount = double.tryParse(order['final_amount']?.toString() ?? '0') ?? 0;
    final driverEarnings = double.tryParse(order['driver_earnings']?.toString() ?? '500') ?? 500;
    final address = order['delivery_address']?.toString() ?? '';
    final date = _formatDate((order['updated_at'] ?? order['created_at'])?.toString());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendorName,
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: darkSlate),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('DELIVERED',
                            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    orderNumber,
                    style: GoogleFonts.inter(fontSize: 11, color: primaryColor, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  if (customerName.isNotEmpty)
                    Text('Customer: $customerName',
                        style: GoogleFonts.inter(fontSize: 11, color: textGrey)),
                  if (address.isNotEmpty)
                    Text(
                      address,
                      style: GoogleFonts.inter(fontSize: 11, color: textGrey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(date, style: GoogleFonts.inter(fontSize: 10, color: textGrey.withOpacity(0.7))),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+${_formatSDG(driverEarnings)} SDG',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                          ),
                          Text(
                            'Order: ${_formatSDG(finalAmount)} SDG',
                            style: GoogleFonts.inter(fontSize: 10, color: textGrey),
                          ),
                        ],
                      ),
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

  Widget _buildDriverBottomNav(BuildContext context, int currentIndex) {
    const Color primaryColor = Color(0xFFCC5500);
    const Color inactiveGrey = Color(0xFF94A3B8);

    final items = [
      {'icon': Icons.map_rounded, 'label': 'Map', 'route': '/driver_dashboard_animated_3d'},
      {'icon': Icons.format_list_bulleted_rounded, 'label': 'History', 'route': '/driver_delivery_history'},
      {'icon': Icons.account_balance_wallet_rounded, 'label': 'Wallet', 'route': '/driver_wallet'},
      {'icon': Icons.person_rounded, 'label': 'Profile', 'route': '/driver_profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: primaryColor.withOpacity(0.08))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -4))],
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
                  if (!isActive) Navigator.pushReplacementNamed(context, items[index]['route'] as String);
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: isActive
                      ? BoxDecoration(
                          color: primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                        )
                      : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(items[index]['icon'] as IconData,
                          color: isActive ? primaryColor : inactiveGrey, size: 24),
                      const SizedBox(height: 2),
                      Text(items[index]['label'] as String,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                              color: isActive ? primaryColor : inactiveGrey)),
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
