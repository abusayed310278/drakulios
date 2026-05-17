import 'package:flutter/material.dart';

import '../../../core/language/translated_text.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/constants/assets.dart';
import '../controller/home_menu_controller.dart';
import '../../auth/view/login_screen.dart';
import '../../shop/view/shop_screen.dart';
import 'qr_home_screen.dart';
import 'training_entry_screen.dart';

class HomeMenuScreen extends StatelessWidget {
  const HomeMenuScreen({super.key});

  static const String _whatsAppNumber = '01623769661';
  static final HomeMenuController _controller = HomeMenuController();

  Future<void> _handleLogout(BuildContext context) async {
    final result = await _controller.logout();

    if (!context.mounted) return;
    CustomSnackbar.show(result.message);
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final result = await _controller.openWhatsApp(_whatsAppNumber);

    if (!context.mounted) return;
    if (!result.success) {
      CustomSnackbar.show(result.message);
    }
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
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: SizedBox(
                      width: 160,
                      height: 60,
                      child: Image.asset(
                        Images.proFactoryImage,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _MenuTile(
                          title: 'QR',
                          asset: Images.qrcodeImage,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const QrHomeScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _MenuTile(
                          title: 'Messages',
                          asset: Images.whatsappImage,
                          iconSize: 82,
                          onTap: () => _openWhatsApp(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _MenuTile(
                          title: 'Trainings',
                          asset: Images.traningImage,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TrainingEntryScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _MenuTile(
                          title: 'Shop',
                          asset: Images.cartImage,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ShopScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  // const Spacer(),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _handleLogout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2B31A),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: TranslatedText(
                        'Log out',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                          color: Color(0xFFFFFFFF),
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

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.title,
    this.asset,
    this.onTap,
    this.iconSize = 65,
  });

  final String title;
  final String? asset;
  final VoidCallback? onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 164,
          width: 158,
          decoration: BoxDecoration(
            color: const Color(0xFF1E2024),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF3A3F47), width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (asset != null)
                Image.asset(
                  asset!,
                  width: iconSize,
                  height: iconSize,
                  color: const Color(0xFFF2B31A),
                ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: TranslatedText(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    autoSize: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
