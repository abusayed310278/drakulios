import 'package:flutter/material.dart';

import '../../core/constants/assets.dart';

class HomeMenuScreen extends StatelessWidget {
  const HomeMenuScreen({super.key});

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
                      child:
                          Image.asset(Images.proFactoryImage, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: const [
                      Expanded(
                        child: _MenuTile(
                          title: 'QR',
                          asset: Images.qrcodeImage,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _MenuTile(
                          title: 'Messages',
                          asset: Images.whatsappImage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Expanded(
                        child: _MenuTile(
                          title: 'Trainings',
                          asset: Images.traningImage,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _MenuTile(
                          title: 'Shop',
                          asset: Images.cartImage,
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
                        backgroundColor: const Color(0xFFF2B31A),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
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
    this.icon,
  });

  final String title;
  final String? asset;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
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
              width: 36,
              height: 36,
              color: const Color(0xFFF2B31A),
            )
          else
            Icon(
              icon,
              size: 36,
              color: const Color(0xFFF2B31A),
            ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
