import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/constants/assets.dart';
import 'change_password_screen.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  static const String _supportPhone = '8801623769661';

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
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: Color(0xFF2C6CFF),
                          ),
                          splashRadius: 18,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
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
                      child: Image.asset(
                        Images.passowrdImage,
                        width: 20,
                        height: 20,
                        color: Colors.white,
                      ),
                    ),
                    chevronColor: const Color(0xFFB58A12),
                    background: const Color(0x3DF3B41A),
                    borderColor: const Color(0xFFF3B41A),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _SecurityTile(
                    label: 'Cancel Membership',
                    labelColor: Colors.white,
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 2, top: 1),
                      child: Image.asset(
                        Images.cancelImage,
                        width: 20,
                        height: 20,
                        color: Colors.white,
                      ),
                    ),
                    chevronColor: const Color(0xFFF3B41A),
                    background: const Color(0x2C13441E),
                    borderColor: const Color(0xFFF3B41A),
                    onTap: () => _openCancelMembership(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCancelMembership(BuildContext context) async {
    const message =
        'CANCEL_MEMBERSHIP\n'
        'Hello, I want to cancel my membership.\n'
        'Please send the cancellation information and connect me directly with support on WhatsApp.';
    final encodedMessage = Uri.encodeComponent(message);
    final uri = Uri.parse('https://wa.me/$_supportPhone?text=$encodedMessage');

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      CustomSnackbar.show('Unable to open WhatsApp');
    }
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
                  style: GoogleFonts.outfit(
                    color: labelColor,
                    fontSize: 24 / 2,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
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
