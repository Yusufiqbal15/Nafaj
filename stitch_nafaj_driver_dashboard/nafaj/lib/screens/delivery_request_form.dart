import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliveryRequestFormScreen extends StatefulWidget {
  const DeliveryRequestFormScreen({super.key});

  @override
  State<DeliveryRequestFormScreen> createState() =>
      _DeliveryRequestFormScreenState();
}

class _DeliveryRequestFormScreenState extends State<DeliveryRequestFormScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  String _selectedSize = 'Medium';
  double _distance = 5.0;
  int _quantity = 1;

  final _productNameController = TextEditingController(
    text: 'Premium Sudanese Coffee',
  );
  final _descriptionController = TextEditingController(
    text: 'High quality coffee beans from Khartoum',
  );
  final _pickupController = TextEditingController(
    text: 'Al-Madina Market, Khartoum',
  );
  final _dropoffController = TextEditingController(
    text: 'Al Riyadh District, Khartoum',
  );

  final List<String> _sizes = ['Small', 'Medium', 'Large', 'Extra Large'];

  double get _baseFee => 500;
  double get _perKmRate => 200;
  double get _deliveryFee => _baseFee + (_distance * _perKmRate);
  double get _productCost => 2450.0 * _quantity;
  double get _totalCost => _productCost + _deliveryFee;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _productNameController.dispose();
    _descriptionController.dispose();
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFCC5500);
    const Color darkSlate = Color(0xFF0F172A);
    const Color textGrey = Color(0xFF475569);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SlideTransition(
        position: _slideAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFCC5500), Color(0xFFE67322)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Icon(
                      Icons.local_shipping_rounded,
                      color: Colors.white.withOpacity(0.9),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Request Delivery',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Details Section
                    _buildSectionHeader(
                      'Product Details',
                      Icons.inventory_2_rounded,
                      primaryColor,
                      darkSlate,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Product Name',
                      _productNameController,
                      Icons.label_rounded,
                      primaryColor,
                      darkSlate,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Description',
                      _descriptionController,
                      Icons.description_rounded,
                      primaryColor,
                      darkSlate,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Size Selection
                    Text(
                      'Size / Package',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: darkSlate,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: _sizes.map((size) {
                        bool isSelected = _selectedSize == size;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedSize = size),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryColor : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryColor
                                      : const Color(0xFFE2E8F0),
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  size,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : textGrey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Quantity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Quantity',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: darkSlate,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (_quantity > 1) {
                                    setState(() => _quantity--);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.remove_rounded,
                                    color: _quantity > 1
                                        ? primaryColor
                                        : Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ),
                              Container(
                                width: 40,
                                alignment: Alignment.center,
                                child: Text(
                                  '$_quantity',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: darkSlate,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _quantity++),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: primaryColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Addresses
                    _buildSectionHeader(
                      'Delivery Route',
                      Icons.route_rounded,
                      primaryColor,
                      darkSlate,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Pickup Address',
                      _pickupController,
                      Icons.my_location_rounded,
                      primaryColor,
                      darkSlate,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Drop-off Address',
                      _dropoffController,
                      Icons.location_on_rounded,
                      primaryColor,
                      darkSlate,
                    ),
                    const SizedBox(height: 16),

                    // Distance Slider
                    Text(
                      'Estimated Distance',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: darkSlate,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_distance.toStringAsFixed(1)} km',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          'Delivery: SDG ${_deliveryFee.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textGrey,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: primaryColor,
                        inactiveTrackColor: primaryColor.withOpacity(0.15),
                        thumbColor: primaryColor,
                        overlayColor: primaryColor.withOpacity(0.1),
                        trackHeight: 6,
                      ),
                      child: Slider(
                        value: _distance,
                        min: 1.0,
                        max: 30.0,
                        onChanged: (v) => setState(() => _distance = v),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1 km',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: textGrey,
                          ),
                        ),
                        Text(
                          '30 km',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: textGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Payment Summary
                    _buildSectionHeader(
                      'Payment Summary',
                      Icons.receipt_long_rounded,
                      primaryColor,
                      darkSlate,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildPriceRow(
                            'Product Cost',
                            'SDG ${_productCost.toStringAsFixed(0)}',
                            textGrey,
                            darkSlate,
                          ),
                          const SizedBox(height: 8),
                          _buildPriceRow(
                            'Delivery Fee (${_distance.toStringAsFixed(1)} km)',
                            'SDG ${_deliveryFee.toStringAsFixed(0)}',
                            textGrey,
                            darkSlate,
                          ),
                          const SizedBox(height: 8),
                          _buildPriceRow(
                            'Size Surcharge ($_selectedSize)',
                            _selectedSize == 'Small'
                                ? 'Free'
                                : _selectedSize == 'Medium'
                                ? 'SDG 100'
                                : _selectedSize == 'Large'
                                ? 'SDG 250'
                                : 'SDG 500',
                            textGrey,
                            darkSlate,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: darkSlate,
                                ),
                              ),
                              Text(
                                'SDG ${_totalCost.toStringAsFixed(0)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Confirm Button
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/delivery_tracking',
                arguments: {
                  'product': _productNameController.text,
                  'pickup': _pickupController.text,
                  'dropoff': _dropoffController.text,
                  'distance': _distance,
                  'total': _totalCost,
                  'quantity': _quantity,
                  'size': _selectedSize,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC5500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Confirm & Pay',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'SDG ${_totalCost.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    Color accent,
    Color dark,
  ) {
    return Row(
      children: [
        Icon(icon, color: accent, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: dark,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl,
    IconData icon,
    Color accent,
    Color dark, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: GoogleFonts.inter(fontSize: 14, color: dark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          color: const Color(0xFF94A3B8),
        ),
        prefixIcon: Icon(icon, color: accent, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: labelColor)),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
