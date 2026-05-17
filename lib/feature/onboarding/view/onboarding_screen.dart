import 'package:flutter/material.dart';

import '../../../core/language/translated_text.dart';

import '../../../core/constants/assets.dart';
import 'onboarding_auth_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          final double height = constraints.maxHeight;
          final double widthFactor = (width / 393).clamp(0.85, 1.0);
          final double heightFactor = (height / 852).clamp(0.72, 1.0);
          final double scale = (widthFactor * heightFactor).clamp(0.72, 1.0);
          final double heroWidth = double.infinity;
          final double heroHeight = 486;
          const double heroTopSpacing = 14;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  SizedBox(
                    width: heroWidth,
                    height: heroHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const ColoredBox(color: Color(0xFF0A0A0A)),
                        Padding(
                          padding: const EdgeInsets.only(top: heroTopSpacing),
                          child: Image.asset(
                            Images.welcomeImage,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x22000000), Color(0x66000000)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SafeArea(
                      top: false,
                      child: Container(
                        color: const Color(0xFFF3F3F3),
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _PageDots(activeIndex: 0),
                              SizedBox(height: 22 * scale),
                              SizedBox(
                                width: 339,
                                height: 53,
                                child: Center(
                                  child: Text.rich(
                                    textAlign: TextAlign.center,
                                    TextSpan(
                                      style: TextStyle(
                                        color: const Color(0xFF2A2A2A),
                                        fontSize: 18 * scale,
                                        fontWeight: FontWeight.w500,
                                        height: 1.2,
                                      ),
                                      children: [
                                        TextSpan(text: 'Welcome To\n '),

                                        const TextSpan(
                                          text: 'Pro ',
                                          style: TextStyle(
                                            color: Color(0xFFF3B41A),
                                            letterSpacing: 0,
                                          ),
                                        ),

                                        TextSpan(
                                          text: 'Factory Club',
                                          style: TextStyle(
                                            color: const Color(0xFF242424),
                                            fontSize: 24 * scale,
                                            fontWeight: FontWeight.w600,
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16 * scale),
                              const SizedBox(
                                width: 339,
                                height: 22,
                                child: TranslatedText(
                                  'Curated Excellence',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF1E1E1E),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                    letterSpacing: 0,
                                  ),
                                  autoSize: true,
                                ),
                              ),
                              SizedBox(height: 10 * scale),
                              const SizedBox(
                                width: 339,
                                height: 60,
                                child: TranslatedText(
                                  'Access a hand-picked selection of premium services and professionals tailored specifically to your high standards.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF7D7D7D),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 1.4,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20 * scale),
                              SizedBox(
                                width: 339,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF3B41A),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.all(10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const OnboardingAuthScreen(),
                                      ),
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TranslatedText(
                                        'Get Started',
                                        style: TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          height: 1.2,
                                          letterSpacing: 0,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.arrow_forward,
                                        size: 16,
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ],
                                  ),
                                ),
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
        },
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.activeIndex});

  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PageDot(active: activeIndex == 0, onTap: () {}),
        const SizedBox(width: 8),
        _PageDot(
          active: activeIndex == 1,
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const OnboardingAuthScreen()),
            );
          },
        ),
        const SizedBox(width: 8),
        _PageDot(active: activeIndex == 2, onTap: () {}),
      ],
    );
  }
}

class _PageDot extends StatelessWidget {
  const _PageDot({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF2B31A) : const Color(0xFFE2E2E2),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
