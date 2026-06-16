import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveSupportChatScreen extends StatelessWidget {
  const LiveSupportChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0F9F59);
    const Color bgColor = Color(0xFFF6F8F7);
    const Color darkSlate = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: primaryColor.withOpacity(0.1)),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: darkSlate,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 24,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Nafaj Support',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkSlate,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Pulse Effect representation
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'ONLINE',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.call_rounded,
                      color: primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Call Support',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              // Date Pill
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'TODAY',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Agent Message 1
              _buildMessage(
                isAgent: true,
                message:
                    'Hello! Welcome to Nafaj Support. How can I help you with your order today?',
                time: '10:42 AM',
                avatarUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuANo8ZsA61Q3Gx2aO8BhBRVbWjquCi2hTQF1WAIVHbRx7Nrm9XHuwc5t4nlDhK_RobmhPRycRpLeB-1c15WyyqCIJ-Yr-U_tJAlN3i2CiE4nkYda_HNV-JOIhTfm0kozVjo1HLhBWHmnmrau-y4hFAycrCgyMn_wp_E5aSTDrQuODNGW_4p3pWIdCdCFRe0t8wWcNG64qBFpSaa-O3zxG57TBILfv6s0iKYmsNk6-v7ZmM_8VufvkZOt0VN_6VGnbUpDFYBuJp9iiI',
                primaryColor: primaryColor,
              ),

              // User Message 1
              _buildMessage(
                isAgent: false,
                message:
                    'I\'m having an issue with my last grocery delivery. Some items are missing from the bag.',
                time: '10:44 AM',
                avatarUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAoEWkJlzCRq9wtp6KkEZ9gNG78DdTbtWovbC60ltbVR6p8Qkk_aJwiia6WCGxz88domxs0Rgc54tCDkTEFAbAM0lBbDSuH7w0AS5DRpVdBPBUZ4c0k9IFGAw4K4ei9FKyYHnjtO00vMwFsmwheHzo40hnajT8Ic7rt5IVrZZzlm70f7oDIOy1aOB157l60vujfvBfODUgRV28qCikl3v78gSAiZF6Uurrgx5xq7_MD5_k3NU9BoHlFnlp0IjwDrdtw4po2idqZKeE',
                primaryColor: primaryColor,
              ),

              // Agent Message 2
              _buildMessage(
                isAgent: true,
                message:
                    'I\'m very sorry to hear that. Could you please send a screenshot of the order receipt and a photo of the received items?',
                time: '10:45 AM',
                avatarUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAJs_aKXm1EQyujQonIcm38WynLAE638nAtoC1cXvEw3656fbT1UsdOrOKdqUU0wDwalu4Vt2AAf0y2Anu5ibJcFLBK1W9mxSZf0RHU4Turi15cgyq9i7vhw1Qn4Cc2hZCrg1bFymaL0vruuPoTK4R9dPzqinobDd4smcfr5ExGAKNl5TfNJlrMGd6obO5L_kQ47m0Jfp-gFsyWeYPcCDYutnnJL_DmRc7jpZgzIjFfyK8oy9zDFbh8twZg0_klevhJRvosIK0rT1I',
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 8),

              // Typing Indicator
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 52), // Align left under avatar
                  Row(
                    children: [
                      _buildTypingDot(),
                      const SizedBox(width: 4),
                      _buildTypingDot(),
                      const SizedBox(width: 4),
                      _buildTypingDot(),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Agent is typing...',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Input Area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: primaryColor.withOpacity(0.1)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.add_photo_alternate_rounded,
                        color: Colors.grey[600],
                      ),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.inter(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildMessage({
    required bool isAgent,
    required String message,
    required String time,
    required String avatarUrl,
    required Color primaryColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: isAgent
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isAgent) ...[
            _buildAvatar(avatarUrl, true, primaryColor),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isAgent
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: isAgent ? 4 : 0,
                    right: isAgent ? 0 : 4,
                    bottom: 4,
                  ),
                  child: Text(
                    isAgent ? 'SUPPORT AGENT' : 'YOU',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isAgent ? const Color(0xFF64748B) : primaryColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isAgent ? Colors.grey[100] : primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isAgent
                          ? Radius.zero
                          : const Radius.circular(16),
                      bottomRight: isAgent
                          ? const Radius.circular(16)
                          : Radius.zero,
                    ),
                  ),
                  child: Text(
                    message,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: isAgent ? const Color(0xFF0F172A) : Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: isAgent ? 4 : 0,
                    right: isAgent ? 0 : 4,
                    top: 4,
                  ),
                  child: Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isAgent) ...[
            const SizedBox(width: 12),
            _buildAvatar(avatarUrl, false, primaryColor),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(String url, bool isAgent, Color primaryColor) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isAgent ? primaryColor.withOpacity(0.1) : primaryColor,
        shape: BoxShape.circle,
        border: isAgent
            ? Border.all(color: primaryColor.withOpacity(0.2))
            : null,
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }
}
