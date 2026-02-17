import 'package:flutter/material.dart';

import '../../core/constants/assets.dart';
import 'login_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _acceptedTerms = false;

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
                  const SizedBox(height: 14),
                  const SizedBox(
                    width: 360,
                    height: 104,
                    child: Center(
                      child: Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          style: TextStyle(
                            color: Color(0xFFF5F6F8),
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                            letterSpacing: 0,
                          ),
                          children: [
                            TextSpan(text: 'Create your\n'),
                            TextSpan(
                              text: 'Pro Factory Club',
                              style: TextStyle(
                                color: Color(0xFFF3B41A),
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                fontStyle: FontStyle.normal,
                                height: 1.2,
                                letterSpacing: 0,
                              ),
                            ),
                            TextSpan(text: '\nAccount'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const _AuthTextField(
                    hint: 'Full Name',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  const _AuthTextField(
                    hint: 'Email address',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  const _AuthTextField(
                    hint: 'Create password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  const _AuthTextField(
                    hint: 'Confirm password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _acceptedTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptedTerms = value ?? false;
                            });
                          },
                          side: const BorderSide(
                            color: Color(0xFF8B8F94),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          activeColor: const Color(0xFFF3B41A),
                          checkColor: Colors.black,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'By using this app, you agree to follow all guidelines, use the content responsibly, and accept any future updates to our policies.',
                          style: TextStyle(
                            color: Color(0xFF9A9EA4),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
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
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Color(0xFF9A9EA4),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                              color: Color(0xFFF3B41A),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
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

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
  });

  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: Color(0xFFF5F6F8), fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFFA8ADB3),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, size: 18, color: const Color(0xFFA8ADB3)),
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
