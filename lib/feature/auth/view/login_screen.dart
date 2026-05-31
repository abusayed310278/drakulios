import 'package:flutter/material.dart';

import '../../../core/language/translated_text.dart';

import '../../../core/constants/assets.dart';
import '../../../core/common/widgets/custom_snackbar.dart';
import '../controller/login_controller.dart';
import '../model/login_route_target.dart';
import '../widgets/auth_text_field.dart';
import 'code_verification_screen.dart';
import 'create_account_screen.dart';
import '../../navigation/view/app_shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final LoginController _loginController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _loginController = LoginController();
    _loadRememberedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                18,
                0,
                18,
                24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                  const SizedBox(height: 20),
                  const SizedBox(
                    width: 344,
                    height: 23,
                    child: TranslatedText(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFF5F6F8),
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        letterSpacing: 0,
                      ),
                      autoSize: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(
                    width: 344,
                    height: 14,
                    child: TranslatedText(
                      'Access your Pro Factory Club Account securely.',
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
                  AuthTextField(
                    hint: 'Email or Phone Number',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 12),
                  AuthTextField(
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    controller: _passwordController,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: const Color(0xFFA8ADB3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (value) async {
                            final remember = value ?? false;
                            setState(() {
                              _rememberMe = remember;
                            });
                            await _loginController.updateRememberMePreference(
                              rememberMe: remember,
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
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
                      const SizedBox(width: 8),
                      TranslatedText(
                        'Remember me',
                        style: TextStyle(
                          color: Color(0xFFBFC3C8),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _isLoading ? null : _handleForgotPassword,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFBFC3C8),
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: TranslatedText(
                          'Forgot your password?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
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
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TranslatedText(
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
                          child: TranslatedText(
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadRememberedCredentials() async {
    final credentials = await _loginController.loadRememberedCredentials();
    if (!mounted || credentials == null) return;

    setState(() {
      _rememberMe = true;
      _emailController.text = credentials.email;
      _passwordController.text = credentials.password;
    });
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final result = await _loginController.login(
        email: _emailController.text,
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );
      _showMessage(result.message);
      if (!result.success || result.routeTarget == null) return;
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(
        MaterialPageRoute(builder: (_) => _buildShell(result.routeTarget!)),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildShell(LoginRouteTarget routeTarget) {
    return const AppShellScreen(initialTab: AppShellTab.home);
  }

  Future<void> _handleForgotPassword() async {
    setState(() => _isLoading = true);
    try {
      final result = await _loginController.requestPasswordResetOtp(
        _emailController.text,
      );
      _showMessage(result.message);
      if (!result.success) return;
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              CodeVerificationScreen(email: _emailController.text.trim()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    CustomSnackbar.show(message);
  }
}
