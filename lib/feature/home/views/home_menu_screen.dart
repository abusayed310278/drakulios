import 'package:flutter/material.dart';

import '../../../core/constants/assets.dart';
import '../../shop/views/shop_screen.dart';
import 'health_profile_screen.dart';
import 'qr_home_screen.dart';

class HomeMenuScreen extends StatelessWidget {
  const HomeMenuScreen({super.key});

  void _showTrainingDialog(BuildContext context) {
    showDialog<void>(context: context, barrierColor: Colors.black.withOpacity(0.6), builder: (context) => const _TrainingInfoDialog());
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
                    child: SizedBox(width: 160, height: 60, child: Image.asset(Images.proFactoryImage, fit: BoxFit.contain)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _MenuTile(
                          title: 'QR',
                          asset: Images.qrcodeImage,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QrHomeScreen()));
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: _MenuTile(title: 'Messages', asset: Images.whatsappImage),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _MenuTile(title: 'Trainings', asset: Images.traningImage, onTap: () => _showTrainingDialog(context)),
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2B31A),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Log out',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.2, color: Color(0xFFFFFFFF)),
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

class _TrainingInfoDialog extends StatelessWidget {
  const _TrainingInfoDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: 343,
        height: 220,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(16),
                  child: const Icon(Icons.close, size: 18, color: Colors.black54),
                ),
              ],
            ),
            const Spacer(),
            const Text(
              'To help us build the best possible plan for you, please tell us a little bit about your body and goals',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF222222), fontSize: 12, height: 1.3, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            SizedBox(
              height: 40,
              width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HealthProfileScreen(),
                      ),
                    );
                  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2B31A),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Continue',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFFFFFFF)),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.title, this.asset, this.icon, this.onTap});

  final String title;
  final String? asset;
  final IconData? icon;
  final VoidCallback? onTap;

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
                Image.asset(asset!, width: 65, height: 65, color: const Color(0xFFF2B31A))
              else
                Icon(icon, size: 65, color: const Color(0xFFF2B31A)),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 24, fontWeight: FontWeight.w600, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
