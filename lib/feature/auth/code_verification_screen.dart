import 'package:flutter/material.dart';

import '../../core/constants/assets.dart';
import 'create_account_screen.dart';
import 'reset_password_screen.dart';

class CodeVerificationScreen extends StatefulWidget {
  const CodeVerificationScreen({super.key});

  @override
  State<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
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
                  const SizedBox(height: 10),
                  Center(
                    child: SizedBox(
                      width: 60,
                      height: 53,
                      child: Image.asset(Images.appLogo, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const SizedBox(
                    width: 344,
                    height: 23,
                    child: Text(
                      'Enter Verification Code',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF5F6F8),
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(
                    width: 344,
                    height: 14,
                    child: Text(
                      'We’ve sent a 6-digit code to your email.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 38,
                        height: 48,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            color: Color(0xFFD7D9DD),
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: const Color(0xFF090B0F),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFF3B41A),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFF3B41A),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFF3B41A),
                                width: 1.2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty &&
                                index < _focusNodes.length - 1) {
                              _focusNodes[index + 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ResetPasswordScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3B41A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Verify',
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
                  const SizedBox(height: 30),
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Didn’t get the verification code? ',
                          style: TextStyle(
                            color: Color(0xFF9A9EA4),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'Resend',
                            style: TextStyle(
                              color: Color(0xFFF3B41A),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Don’t have an account? ',
                          style: TextStyle(
                            color: Color(0xFF9A9EA4),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CreateAccountScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              color: Color(0xFFF3B41A),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
