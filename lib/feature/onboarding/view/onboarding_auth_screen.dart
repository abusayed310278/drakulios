import 'package:flutter/material.dart';

import '../../../core/language/translated_text.dart';

import '../../../core/constants/assets.dart';
import '../../auth/view/create_account_screen.dart';
import '../../auth/view/login_screen.dart';

class OnboardingAuthScreen extends StatelessWidget {
  const OnboardingAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            children: [
              SizedBox(
                height: 480,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(Images.onboardingImage, fit: BoxFit.cover),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x73000000), Color(0x88000000)],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: 188,
                          child: Image.asset(
                            Images.proFactoryImage,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const Alignment(0, 0.9),
                      child: _PageDots(activeIndex: 1),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFF3F3F3),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 339,
                          height: 22,
                          child: TranslatedText(
                            'Join the Elite.',
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
                        const SizedBox(height: 16),
                        const SizedBox(
                          width: 339,
                          height: 60,
                          child: TranslatedText(
                            'Secure your spot in our community today. Your journey toward a more refined experience starts here.',
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
                        // const Spacer(),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 339,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF3B41A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: TranslatedText(
                              'Log in',
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 339,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const CreateAccountScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFF3B41A),
                                width: 1,
                              ),
                              padding: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: TranslatedText(
                              'Create Account',
                              style: TextStyle(
                                color: Color(0xFFF3B41A),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        _PageDot(
          active: activeIndex == 0,
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(width: 8),
        _PageDot(active: activeIndex == 1, onTap: () {}),
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
          shape: BoxShape.circle,
          color: active ? const Color(0xFFF2B31A) : const Color(0xFFE2E2E2),
        ),
      ),
    );
  }
}
