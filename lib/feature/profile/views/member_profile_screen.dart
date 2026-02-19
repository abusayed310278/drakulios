import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/assets.dart';
import 'member_profile_details_screen.dart';
import 'security_screen.dart';

class MemberProfileScreen extends StatelessWidget {
  const MemberProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 50, 0, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Transform.translate(
                          offset: const Offset(-15, 0),
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFFC9CDD3)),
                            splashRadius: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Member Profile',
                          style: TextStyle(color: Color(0xFFB1B1B1), fontSize: 18, fontWeight: FontWeight.w400, height: 1.2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: const Color(0xFF2A2F39),
                          child: ClipOval(child: Image.asset(Images.profileImage, width: 64, height: 64, fit: BoxFit.cover)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Flexible(
                                    child: Text(
                                      'Stella Jacobs',
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(width: 120),
                                  Icon(Icons.edit, size: 24, color: Color(0xFF2C6CFF)),
                                ],
                              ),

                              const SizedBox(height: 6),
                              const Text('Member ID : 1212', style: TextStyle(color: Colors.white, fontSize: 12, height: 1.3)),
                              const Text('Contact no. : 0000000000', style: TextStyle(color: Colors.white, fontSize: 12, height: 1.3)),
                              const Text('Email : stella1212@gmail.com', style: TextStyle(color: Colors.white, fontSize: 12, height: 1.3)),
                              const Text(
                                'Member Since : 5th January 2026',
                                style: TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const MemberProfileDetailsScreen()),
                                  );
                                },
                                child: Text(
                                  'View Details',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFF3B41A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C224E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2C6CFF), width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(Images.whatsappImage, width: 24, height: 24, color: const Color(0xFF21C063)),
                          const SizedBox(width: 8),
                          const Text(
                            'Contact Admin',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Plan Name: Online Coaching \nPrice : €149/ Month',
                                  style: TextStyle(color: Color(0xFF263451), fontSize: 16, fontWeight: FontWeight.w500, height: 1.2),
                                ),
                              ),
                              Container(
                                width: 64,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: const Color(0xFF47AD2A), borderRadius: BorderRadius.circular(100)),
                                child: Text(
                                  'Active',
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w400, height: 1.2),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF1E1E1E),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                              ),
                              children: const [
                                TextSpan(text: 'Renewal Date: March 1st, 2026.\nPayment Method : Credit Card '),
                                TextSpan(
                                  text: '(paid)',
                                  style: TextStyle(color: Color(0xFF47AD2A)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _MenuRow(title: 'View Attendance'),
                    const SizedBox(height: 10),
                    _MenuRow(title: 'View Purchase History'),
                    const SizedBox(height: 10),
                    _MenuRow(
                      title: 'Settings',
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SecurityScreen()));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2513),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF2B31A), width: 1.1),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
