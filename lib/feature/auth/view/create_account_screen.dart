import 'package:flutter/material.dart';

import '../../../core/language/translated_text.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/constants/assets.dart';
import '../controller/create_account_controller.dart';
import '../widgets/auth_text_field.dart';
import 'login_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  bool _acceptedTerms = false;
  bool _isLoading = false;
  bool _obscureCreatePassword = true;
  bool _obscureConfirmPassword = true;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final CreateAccountController _controller;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _controller = CreateAccountController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    18,
                    0,
                    18,
                    12 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
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
                              child: Image.asset(
                                Images.appLogo,
                                fit: BoxFit.contain,
                              ),
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
                          AuthTextField(
                            hint: 'Full Name',
                            icon: Icons.person_outline,
                            controller: _nameController,
                          ),
                          const SizedBox(height: 12),
                          AuthTextField(
                            hint: 'Email address',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                          ),
                          const SizedBox(height: 12),
                          AuthTextField(
                            hint: 'Address',
                            icon: Icons.location_on_outlined,
                            controller: _addressController,
                          ),
                          const SizedBox(height: 12),
                          AuthTextField(
                            hint: 'Create password',
                            icon: Icons.lock_outline,
                            obscureText: _obscureCreatePassword,
                            controller: _passwordController,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureCreatePassword =
                                      !_obscureCreatePassword;
                                });
                              },
                              icon: Icon(
                                _obscureCreatePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: const Color(0xFFA8ADB3),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AuthTextField(
                            hint: 'Confirm password',
                            icon: Icons.lock_outline,
                            obscureText: _obscureConfirmPassword,
                            controller: _confirmPasswordController,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: const Color(0xFFA8ADB3),
                              ),
                            ),
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
                                child: TranslatedText(
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
                              onPressed: _isLoading
                                  ? null
                                  : _handleCreateAccount,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF3B41A),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : TranslatedText(
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
                                TranslatedText(
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
                                  child: TranslatedText(
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
          },
        ),
      ),
    );
  }

  Future<void> _handleCreateAccount() async {
    setState(() => _isLoading = true);
    try {
      final result = await _controller.createAccount(
        name: _nameController.text,
        email: _emailController.text,
        address: _addressController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        acceptedTerms: _acceptedTerms,
      );
      CustomSnackbar.show(result.message);
      if (!result.success) return;

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
