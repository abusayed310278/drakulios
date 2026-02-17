import 'package:flutter/material.dart';

import '../../core/constants/assets.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

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
                  const SizedBox(height: 24),
                  const SizedBox(
                    width: 344,
                    height: 23,
                    child: Text(
                      'Reset Your Password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF5F6F8),
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
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
                      'Enter the email address associated with your account.',
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
                  const _PasswordField(hint: 'New password'),
                  const SizedBox(height: 12),
                  const _PasswordField(hint: 'Confirm password'),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3B41A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Continue',
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        obscureText: true,
        style: const TextStyle(color: Color(0xFFF5F6F8), fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFFA8ADB3),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.lock_outline,
            size: 18,
            color: Color(0xFFA8ADB3),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          filled: true,
          fillColor: const Color(0xFF090B0F),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFF3B41A), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFF3B41A), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFF3B41A), width: 1.2),
          ),
        ),
      ),
    );
  }
}
