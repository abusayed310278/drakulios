import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/assets.dart';

class MemberProfileDetailsScreen extends StatelessWidget {
  const MemberProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileInfoStyle = GoogleFonts.outfit(color: const Color(0xFFF4F4F5), fontSize: 14, fontWeight: FontWeight.w400, height: 1.45);

    final sectionTitleStyle = GoogleFonts.outfit(color: const Color(0xFFF4F4F5), fontSize: 14, fontWeight: FontWeight.w700, height: 1.2);

    final sectionBodyStyle = GoogleFonts.outfit(color: const Color(0xFFF4F4F5), fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);

    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 50, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Transform.translate(
                        offset: const Offset(-10, 0),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFFC9CDD3)),
                          splashRadius: 18,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        ),
                      ),
                      Text(
                        'View Details',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFE5E7EB),
                          fontSize: 29 / 2,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFF2A2F39),
                        child: ClipOval(child: Image.asset(Images.profileImage, width: 80, height: 80, fit: BoxFit.cover)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stella Jacobs',
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 34 / 2, fontWeight: FontWeight.w700, height: 1.2),
                            ),
                            const SizedBox(height: 4),
                            Text('Member ID : 1212', style: profileInfoStyle),
                            Text('Contact no. : 0000000000', style: profileInfoStyle),
                            Text('Email : stella1212@gmail.com', style: profileInfoStyle),
                            Text('Member Since : 5th January 2026', style: profileInfoStyle),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Personal Body Details :',
                    style: GoogleFonts.outfit(color: const Color(0xFFF3B41A), fontSize: 34 / 2, fontWeight: FontWeight.w700, height: 1.2),
                  ),
                  const SizedBox(height: 12),
                  _DetailSection(
                    title: '1. Physical Metrics & Body Composition\n',
                    content:
                        'Current Weight: 56 kg.\n'
                        'Target Weight: 65 kg.\n'
                        'Height: 5 ft.\n'
                        'Body Type Description: Heavy frame with fat\n'
                        'concentrated around the midsection.\n'
                        'Weight Trends: Gained 10 kg in the last 6 months due to a desk job.\n'
                        'Current Height: 5ft\n'
                        'Sleep: Averages 6-7 hours per day.',
                    titleStyle: sectionTitleStyle,
                    bodyStyle: sectionBodyStyle,
                  ),
                  const SizedBox(height: 22),
                  _DetailSection(
                    title: '2. Health & Medical History\n',
                    content:
                        'Surgical History: Appendectomy (3 years ago) and Hernia repair (2021).\n'
                        'Joint & Muscle Pain: Experiences sharp pain in the right shoulder specifically during overhead presses.\n'
                        'Digestive Health: Frequent bloating after consuming dairy or heavy carbohydrates.',
                    titleStyle: sectionTitleStyle,
                    bodyStyle: sectionBodyStyle,
                  ),
                  const SizedBox(height: 22),
                  _DetailSection(
                    title: '3. Nutritional Habits & Supplementation\n',
                    content:
                        'Meal Frequency: 3 meals per day.\n'
                        'Hunger Patterns: No appetite in the morning, but experiences intense sugar cravings at night.\n'
                        'Hydration & Stimulants: Drinks 1.5L of water and 4 cups of black coffee daily.\n'
                        'Supplements: Currently uses Whey protein and Creatine purchased from the gym shop.',
                    titleStyle: sectionTitleStyle,
                    bodyStyle: sectionBodyStyle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.content, required this.titleStyle, required this.bodyStyle});

  final String title;
  final String content;
  final TextStyle titleStyle;
  final TextStyle bodyStyle;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '$title ', style: titleStyle),
          TextSpan(text: content, style: bodyStyle),
        ],
      ),
    );
  }
}
