import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

class NafajBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NafajBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFCC5500);
    const Color unselectedColor = Color(0xFFA9A9A9);

    final List<_NavItem> items = [
      _NavItem(
        icon: Icons.home_rounded,
        label: 'Home',
        route: '/nafaj_home_exact_header_match',
      ),
      _NavItem(
        icon: Icons.receipt_long_rounded,
        label: 'Orders',
        route: '/user_orders',
      ),
      _NavItem(
        icon: Icons.grid_view_rounded,
        label: 'Categories',
        route: '/nafaj_category_grid_blinkit_style',
      ),
      _NavItem(
        icon: Icons.work_rounded,
        label: 'Jobs',
        route: '/nafaj_job_portal_selection',
      ),
      _NavItem(
        icon: Icons.person_rounded,
        label: 'Profile',
        route: '/nafaj_profile_management',
      ),
    ];

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (index) {
              final isSelected = index == currentIndex;
              return GestureDetector(
                onTap: () {
                  if (!isSelected) {
                    onTap(index);
                    Navigator.pushReplacementNamed(context, items[index].route);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 16 : 0,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        transform: Matrix4.translationValues(
                          0,
                          isSelected ? -4 : 0,
                          0,
                        ),
                        child: Icon(
                          items[index].icon,
                          color: isSelected ? primaryColor : unselectedColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[index].label,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected ? primaryColor : unselectedColor,
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

class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  _NavItem({required this.icon, required this.label, required this.route});
}
