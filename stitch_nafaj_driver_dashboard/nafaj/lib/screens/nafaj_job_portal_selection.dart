import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/nafaj_bottom_nav.dart';

class NafajJobPortalSelectionScreen extends StatelessWidget {
  const NafajJobPortalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFCC5500);
    const Color bgColor = Color(0xFFF8F7F5);
    const Color darkSlate = Color(0xFF0F172A);
    const Color textSlate = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: darkSlate),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nafaj Jobs',
          style: GoogleFonts.inter(
            color: darkSlate,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: primaryColor.withOpacity(0.1), height: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Hero Section
            Padding(
              padding: const EdgeInsets.only(
                top: 40,
                bottom: 24,
                left: 24,
                right: 24,
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.work_history_rounded,
                      color: primaryColor,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to Nafaj Jobs',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: darkSlate,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select your path to start exploring opportunities in Sudan',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 16, color: textSlate),
                  ),
                ],
              ),
            ),

            // Selection Cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildSelectionCard(
                      context,
                      title: 'I am a Job Seeker',
                      description:
                          'Discover your next career move. Browse thousands of jobs across Khartoum and beyond.',
                      imgUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDAK7QwLOG4YqBMP14vgpJgxuXBGkvzlTihTa3ap3ZL5-vg0K5Rf73aind7ejCLf3PPUkWuMlig3TIi05BWeEZHbl8gKS-33IFZbA2B_uO8UV8h8GCI_fWt_CvzSFOKRhudmlqRUuWrmKrzpD4roMdl17XsbaygNVSuHpq5JrX40HhOEyjW7Lvq_wZ2o2HKfiY1lQK0jYID-rQ_nDtg4v03sniciK6OY2i4nfd2tGvIBscGPTKeskerV17JJ09VVTM-um2mCGxePCc',
                      icon: Icons.work_rounded,
                      onTap: () {
                        Navigator.pushNamed(context, '/job_seeker_categories');
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSelectionCard(
                      context,
                      title: 'I am an Employer',
                      description:
                          'Find the best talent for your business. Post jobs and manage applications seamlessly.',
                      imgUrl:
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuA0FAQvMtxHyMc_GWmqAPekODTV-Ex0ybVjRPHsV3X7i79g3BydzKplIuXkgkunOIZyOASKYwslZowg-EgxHAJLG_-fj-U_cbRyFyYNrMBW3anfNndVlN321caCK2v8PP7mwNMtrIpXMw5ecDUF4kknhJqaFISxhicFPXSZNWn2btF572QmOGgL9X3N96BRUtKiYllaXMTbYD9jQbm8_FY56XOVl_mZvP_raGrc1J-whsPlY0YfMgx4gaR28rCrVuvqV0fe8TK5RZ0',
                      icon: Icons.campaign_rounded,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/job_creator_my_listings',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Need help? ',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  Text(
                    'Contact Support',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NafajBottomNav(currentIndex: 3, onTap: (index) {}),
    );
  }

  Widget _buildSelectionCard(
    BuildContext context, {
    required String title,
    required String description,
    required String imgUrl,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.transparent, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imgUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFFCC5500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
