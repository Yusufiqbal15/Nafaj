import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuickOrderVehicleTypeScreen extends StatefulWidget {
  const QuickOrderVehicleTypeScreen({super.key});

  @override
  State<QuickOrderVehicleTypeScreen> createState() =>
      _QuickOrderVehicleTypeScreenState();
}

class _QuickOrderVehicleTypeScreenState
    extends State<QuickOrderVehicleTypeScreen> {
  String _selectedVehicle = 'motorcycle';

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFCC5500);
    const Color bgColor = Color(0xFFF8F7F6);
    const Color darkSlate = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: darkSlate,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Quick Order',
          style: GoogleFonts.plusJakartaSans(
            color: darkSlate,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STEP 2 OF 3',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF64748B),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Vehicle Selection',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkSlate,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '66%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.66,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Selection Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Vehicle Type',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkSlate,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildVehicleOption(
                      id: 'motorcycle',
                      name: 'Motorcycle',
                      price: 'SDG 1,500',
                      description: 'Fast, small items',
                      time: '15-20 mins',
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAP9h1i953Yy4Rc-Ugi4OvXVPHz6jiW9_LwPAZ-qLoFhDKfg3RiONJprDwBnWsbptySj7EKHdQDtBBGqPs9xXoEL063BfuYzG7nCZkaxh2l6TBfBqHAAwQlHngmQCrkzP5OimW4zBp4WC_zRQR9dbGTA14LCsoHexL4Q6J-65TFn1aNhl04BFvPSxVGigbK7rY8shBZ9AMQELPVSLJfZPKESnFNC9QCZY55NGvfAHCYzgEdAjrn01IiwnJtv9JmZ27pn37iTcI63SM',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 16),

                    _buildVehicleOption(
                      id: 'rickshaw',
                      name: 'Rickshaw / Raksha',
                      price: 'SDG 2,800',
                      description: 'Medium items',
                      time: '20-30 mins',
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAWNuyJpP8Xmy1zpql1s-8627PomdEFPtOotLzRsdcwasaylWrKHD2FiqooF5J5PEoJNXcbmN-5aU3L7uvzoaZfEGCw-kSgFpRw2cMAdqgQMpn5wCQVN8CVYxij5XkV-z8vq1l_Ak_wnRzURTG4-eaEjOt3bwDfaiVkpQ95LBcFD4deNhmfEKzNlF2F6iTK-zkbEb0QNDzUjbiPuW6unLslu-wjF35NV84tZMgkjfrGIKoCa-ZLwBuDTFJHFhWsZ6hbjyEJmpAw3-E',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 16),

                    _buildVehicleOption(
                      id: 'small_car',
                      name: 'Small Car',
                      price: 'SDG 4,500',
                      description: 'Large/Fragile items',
                      time: '35-45 mins',
                      imageUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBg2UJ_BLEQ3ndVTsJ1I8vh9iqPj6m6PeK0THI0WXhjyj8A34kHSbzwl8j06D7d2YJlWosofqP4R0kHqHXQlAfA0Tl0S9pf58nzSRL9WbJ-Cza1cscLVpZNkNKd7fKNknANWBttyPUwScVviPxHIUSAz04hOookaWDtUtJz6Ag1G6ROEhJwB-SXyq06SddiJVRww9w_gIbKkJkdivEPxEExzrMXKAQAbTHRVoxqT7n6e65o-scq4nw_6kzXu52VHjNFQbdr4mEoNJA',
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 24),

                    // Helper Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_rounded,
                            color: Colors.blue[600],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Vehicle availability depends on your current location in Khartoum. Prices include local taxes and standard delivery insurance.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: Colors.blue[800],
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: const Color(0xFFF1F5F9))),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/quick_order_final_summary',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Confirm Vehicle',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleOption({
    required String id,
    required String name,
    required String price,
    required String description,
    required String time,
    required String imageUrl,
    required Color primaryColor,
  }) {
    bool isSelected = _selectedVehicle == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVehicle = id;
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? primaryColor : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor.withOpacity(0.1)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            price,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? primaryColor
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            color: Color(0xFF94A3B8),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
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
          if (isSelected)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
