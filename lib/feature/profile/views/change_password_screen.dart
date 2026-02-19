import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/network/api_service/token_meneger.dart';
import '../../../core/network/api_service/user_api_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final UserApiService _userApi = UserApiService();
  late final TextEditingController _emailController;
  late final TextEditingController _currentController;
  late final TextEditingController _newController;
  late final TextEditingController _confirmController;
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _currentController = TextEditingController();
    _newController = TextEditingController();
    _confirmController = TextEditingController();
    _loadEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _loadEmail() async {
    final email = await TokenManager.getEmail();
    if (!mounted) return;
    _emailController.text = (email ?? '').trim();
  }

  @override
  Widget build(BuildContext context) {
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Transform.translate(
                        offset: const Offset(-12, 0),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF2C6CFF)),
                          splashRadius: 18,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        ),
                      ),
                      Text(
                        'Change password',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFE5E7EB),
                          fontSize: 30 / 2,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _Label(text: 'Email address'),
                  const SizedBox(height: 8),
                  _Field(
                    hint: 'you@gmail.com',
                    obscure: false,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 14),
                  const _Label(text: 'Current password'),
                  const SizedBox(height: 8),
                  _Field(
                    hint: '••••••',
                    obscure: _obscureCurrent,
                    controller: _currentController,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureCurrent = !_obscureCurrent;
                        });
                      },
                      icon: Icon(
                        _obscureCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18,
                        color: const Color(0xFF8C919A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _Label(text: 'New password'),
                  const SizedBox(height: 8),
                  _Field(
                    hint: '••••••',
                    obscure: _obscureNew,
                    controller: _newController,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureNew = !_obscureNew;
                        });
                      },
                      icon: Icon(
                        _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18,
                        color: const Color(0xFF8C919A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _Label(text: 'Confirm password'),
                  const SizedBox(height: 8),
                  _Field(
                    hint: '••••••',
                    obscure: _obscureConfirm,
                    controller: _confirmController,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirm = !_obscureConfirm;
                        });
                      },
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 18,
                        color: const Color(0xFF8C919A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _savePassword,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFF3B41A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                            )
                          : Text(
                              'Save',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 28 / 2,
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

  Future<void> _savePassword() async {
    final current = _currentController.text.trim();
    final next = _newController.text.trim();
    final confirm = _confirmController.text.trim();
    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      CustomSnackbar.show('Please fill all password fields');
      return;
    }
    if (next != confirm) {
      CustomSnackbar.show('New password and confirm password do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await _userApi.changePassword(
        currentPassword: current,
        newPassword: next,
        confirmPassword: confirm,
      );
      CustomSnackbar.show((res['message'] ?? 'Password changed successfully').toString());
      if (!mounted) return;
      Navigator.of(context).pop();
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map && data['message'] != null ? data['message'].toString() : 'Failed to change password';
      CustomSnackbar.show(msg);
    } catch (_) {
      CustomSnackbar.show('Failed to change password');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        color: const Color(0xFFD6D8DD),
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.2,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.hint, required this.obscure, this.controller, this.suffixIcon});

  final String hint;
  final bool obscure;
  final TextEditingController? controller;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.2,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: GoogleFonts.outfit(
            color: const Color(0xFF8C919A),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: const Color(0xFF050608),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFF3B41A), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFF3B41A), width: 1.2),
          ),
        ),
      ),
    );
  }
}
