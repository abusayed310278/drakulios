import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

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
                  const _Field(
                    hint: 'you@gmail.com',
                    obscure: false,
                  ),
                  const SizedBox(height: 14),
                  const _Label(text: 'Current password'),
                  const SizedBox(height: 8),
                  const _Field(
                    hint: '••••••',
                    obscure: true,
                  ),
                  const SizedBox(height: 14),
                  const _Label(text: 'New password'),
                  const SizedBox(height: 8),
                  const _Field(
                    hint: '••••••',
                    obscure: true,
                  ),
                  const SizedBox(height: 14),
                  const _Label(text: 'Confirm password'),
                  const SizedBox(height: 8),
                  const _Field(
                    hint: '••••••',
                    obscure: true,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFF3B41A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
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
  const _Field({required this.hint, required this.obscure});

  final String hint;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextFormField(
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
