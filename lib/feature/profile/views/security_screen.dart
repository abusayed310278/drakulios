import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/assets.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

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
                        'Security',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFE5E7EB),
                          fontSize: 30 / 2,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SecurityTile(
                    label: 'Change password',
                    labelColor: Colors.white,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 2, top: 1),
                      child: Image.asset(Images.passowrdImage, width: 20, height: 20, color: Colors.white),
                    ),
                    chevronColor: const Color(0xFFB58A12),
                    background: const Color(0x3DF3B41A),
                    borderColor: const Color(0xFFF3B41A),
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  _SecurityTile(
                    label: 'Delete Account',
                    labelColor: const Color(0xFFFF3B30),
                    leading: Image.asset(Images.deleteImage, width: 20, height: 20, color: const Color(0xFFFF3B30)),
                    chevronColor: const Color(0xFFFF3B30),
                    background: Colors.transparent,
                    borderColor: const Color(0xFFF3B41A),
                    onTap: () {},
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

class _SecurityTile extends StatelessWidget {
  const _SecurityTile({
    required this.label,
    required this.labelColor,
    required this.leading,
    required this.chevronColor,
    required this.background,
    required this.borderColor,
    required this.onTap,
  });

  final String label;
  final Color labelColor;
  final Widget leading;
  final Color chevronColor;
  final Color background;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(color: labelColor, fontSize: 24 / 2, fontWeight: FontWeight.w500, height: 1.2),
                ),
              ),
              Icon(Icons.chevron_right, size: 16, color: chevronColor),
            ],
          ),
        ),
      ),
    );
  }
}
