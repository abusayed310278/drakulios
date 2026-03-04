import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/constants/assets.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/common/widgets/custom_snackbar.dart';
import '../../core/network/api_service/api_client.dart';
import '../../core/network/api_service/token_meneger.dart';
import 'code_verification_screen.dart';
import 'create_account_screen.dart';
import '../home/views/home_menu_screen.dart';
import '../paymentandsubscription/views/payment_and_subscription_screen.dart';

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
  late final ApiClient _apiClient;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _apiClient = ApiClient(ApiEndpoints.baseUrl);
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
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFFC9CDD3)),
                      splashRadius: 18,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: SizedBox(width: 60, height: 53, child: Image.asset(Images.appLogo, fit: BoxFit.contain)),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(
                    width: 344,
                    height: 23,
                    child: Text(
                      'Welcome Back',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFF5F6F8), fontSize: 19, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: 0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(
                    width: 344,
                    height: 14,
                    child: Text(
                      'Access your Pro Factory Club Account securely.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 12, fontWeight: FontWeight.w400, height: 1.2, letterSpacing: 0),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _AuthTextField(
                    hint: 'Email or Phone Number',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 12),
                  _AuthTextField(
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
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
                            await TokenManager.setRememberMe(remember);
                            if (!remember) {
                              await TokenManager.clearRememberedCredentials();
                            }
                          },
                          side: const BorderSide(color: Color(0xFF8B8F94), width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                          activeColor: const Color(0xFFF3B41A),
                          checkColor: Colors.black,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Remember me',
                        style: TextStyle(color: Color(0xFFBFC3C8), fontSize: 14, fontWeight: FontWeight.w400),
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
                        child: const Text('Forgot your password?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                          : const Text(
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
                  // Row(
                  //   children: const [
                  //     Expanded(
                  //       child: Divider(color: Color(0xFF4A4F58), thickness: 1),
                  //     ),
                  //     SizedBox(width: 10),
                  //     Text(
                  //       'Or continue with',
                  //       style: TextStyle(
                  //         color: Color(0xFFBFC3C8),
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.w400,
                  //       ),
                  //     ),
                  //     SizedBox(width: 10),
                  //     Expanded(
                  //       child: Divider(color: Color(0xFF4A4F58), thickness: 1),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 24),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     _SocialButton(asset: Images.googleIcon, onTap: () {}),
                  //     const SizedBox(width: 14),
                  //     _SocialButton(asset: Images.appleIcon, onTap: () {}),
                  //   ],
                  // ),
                  const Spacer(),
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Don’t have an account? ',
                          style: TextStyle(color: Color(0xFF9A9EA4), fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateAccountScreen()));
                          },
                          child: const Text(
                            'Sign up',
                            style: TextStyle(color: Color(0xFFF3B41A), fontSize: 14, fontWeight: FontWeight.w600),
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

  Future<void> _loadRememberedCredentials() async {
    final remember = await TokenManager.isRememberMeEnabled();
    if (!mounted) return;
    if (!remember) return;

    final email = await TokenManager.getRememberedEmail();
    final password = await TokenManager.getRememberedPassword();
    if (!mounted) return;

    setState(() {
      _rememberMe = true;
      _emailController.text = email ?? '';
      _passwordController.text = password ?? '';
    });
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter email and password');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.post(ApiEndpoints.login, data: {'email': email, 'password': password});
      final data = response.data;
      final success = data['success'] == true;
      final backendMessage = (data['message'] ?? '').toString();

      if (!success) {
        _showMessage(backendMessage.isEmpty ? 'Login failed' : backendMessage);
        return;
      }

      final payload = (data['data'] ?? {}) as Map<String, dynamic>;
      final accessToken = (payload['accessToken'] ?? '').toString();
      final refreshToken = (payload['refreshToken'] ?? '').toString();

      if (accessToken.isEmpty || refreshToken.isEmpty) {
        _showMessage('Login failed: missing token');
        return;
      }

      await TokenManager.save(
        access: accessToken,
        refresh: refreshToken,
        uid: (payload['_id'] ?? payload['user']?['_id'] ?? '').toString(),
        userName: (payload['user']?['name'] ?? '').toString(),
        userEmail: (payload['user']?['email'] ?? email).toString(),
        userRole: (payload['role'] ?? payload['user']?['role'] ?? '').toString(),
      );

      await TokenManager.setRememberMe(_rememberMe);
      if (_rememberMe) {
        await TokenManager.saveRememberedCredentials(email: email, password: password);
      } else {
        await TokenManager.clearRememberedCredentials();
      }

      if (backendMessage.isNotEmpty) {
        _showMessage(backendMessage);
      }

      if (!mounted) return;
      final hasActivePlan = await _resolveHasActivePlan();
      if (!mounted) return;
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => hasActivePlan ? const HomeMenuScreen() : const PaymentAndSubscriptionScreen()));
    } on DioException catch (e) {
      final resData = e.response?.data;
      String message = 'Login failed';
      if (resData is Map && resData['message'] != null) {
        message = resData['message'].toString();
      } else if (e.message != null && e.message!.trim().isNotEmpty) {
        message = e.message!;
      }
      _showMessage(message);
    } catch (_) {
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _resolveHasActivePlan() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.paymentHistory);
      final raw = res.data;
      if (raw is! Map) return false;
      final data = raw['data'];
      if (data is! Map) return false;

      final explicitFlag = data['hasActivePlan'];
      if (explicitFlag is bool) return explicitFlag;

      final purchases = data['purchases'];
      if (purchases is List) {
        return purchases.any((e) {
          if (e is! Map) return false;
          final title = (e['title'] ?? '').toString().toLowerCase();
          return title.contains('subscription');
        });
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Please enter your email first');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.post(ApiEndpoints.forgetPassword, data: {'email': email});
      final data = response.data;
      final message = (data['message'] ?? 'OTP sent to your email').toString();
      _showMessage(message);

      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => CodeVerificationScreen(email: email)));
    } on DioException catch (e) {
      final resData = e.response?.data;
      String message = 'Failed to send OTP';
      if (resData is Map && resData['message'] != null) {
        message = resData['message'].toString();
      } else if (e.message != null && e.message!.trim().isNotEmpty) {
        message = e.message!;
      }
      _showMessage(message);
    } catch (_) {
      _showMessage('Something went wrong. Please try again.');
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

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: Color(0xFFF5F6F8), fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFA8ADB3), fontSize: 14, fontWeight: FontWeight.w400),
          prefixIcon: Icon(icon, size: 18, color: const Color(0xFFA8ADB3)),
          suffixIcon: suffixIcon,
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

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.asset, required this.onTap});

  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 64,
        height: 48,
        // padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: SizedBox(width: 50, height: 50, child: Image.asset(asset, fit: BoxFit.contain)),
        ),
      ),
    );
  }
}
