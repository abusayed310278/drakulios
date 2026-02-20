import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/assets.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 40, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: Color(0xFFC9CDD3),
                          ),
                          splashRadius: 18,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Center(
                          child: Image.asset(
                            Images.proFactoryImage,
                            width: 190,
                            height: 66,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 36),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pro factory Terms & Conditions',
                    style: GoogleFonts.nunito(
                      color: const Color(0xDEFFFFFF),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              style: GoogleFonts.nunito(
                                color: const Color(0xFFFFFFFF),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                height: 1.0,
                                letterSpacing: 0,
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      'Please read these terms and conditions ("terms and conditions"), carefully before using ',
                                ),
                                TextSpan(
                                  text: 'Beard Friends',
                                  style: GoogleFonts.nunito(
                                    color: const Color(0xFFFFFFFF),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    height: 1.0,
                                  ),
                                ),
                                const TextSpan(
                                  text:
                                      ' mobile application ("app", "service") operated by ',
                                ),
                                TextSpan(
                                  text: 'Beard Friends',
                                  style: GoogleFonts.nunito(
                                    color: const Color(0xFFFFFFFF),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    height: 1.0,
                                  ),
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          _Section(
                            title: '1. Conditions of use',
                            body:
                                'By using this app, you certify that you have read and reviewed this Agreement and that you agree to comply with its terms. If you do not want to be bound by the terms of this Agreement, you are advised to stop using the app accordingly. Beard Friends only grants use and access of this app, its products, and its services to those who have accepted its terms.',
                          ),
                          const SizedBox(height: 16),
                          _Section(
                            title: '2. Intellectual property',
                            body:
                                'You agree that all materials, products, and services provided on this app are the property of Beard Friends, its affiliates, directors, officers, employees, agents, suppliers, or licensors.',
                          ),
                          const SizedBox(height: 16),
                          _Section(
                            title: '3. Privacy policy',
                            body:
                                'Before you continue using our app, please read our privacy policy regarding user data collection. It will help you better understand our practices.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2B31A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Accept',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFFFFF),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ),
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            color: const Color(0xFFE6E7EA),
            fontSize: 50 / 2,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: GoogleFonts.nunito(
            color: const Color(0xFFFFFFFF),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.0,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
