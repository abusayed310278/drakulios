import 'package:flutter/material.dart';

import '../../../core/language/translated_text.dart';

import '../../../core/constants/assets.dart';
import '../controller/qr_home_controller.dart';

class QrHomeScreen extends StatelessWidget {
  const QrHomeScreen({super.key});

  static final QrHomeController _controller = QrHomeController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 50, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFFC9CDD3)),
                        splashRadius: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TranslatedText(
                            'Good Morning 🔥',
                            style: TextStyle(color: Color(0xFFC9CDD3), fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          FutureBuilder<String>(
                            future: _controller.getDisplayName(),
                            builder: (context, snapshot) {
                              final displayName = (snapshot.data ?? '').trim().isNotEmpty
                                  ? snapshot.data!.trim()
                                  : 'Member';
                              return TranslatedText(
                                displayName,
                                style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 16, fontWeight: FontWeight.w600),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    decoration: BoxDecoration(color: const Color(0xFF2A2B2F), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            TranslatedText(
                              'Scan to Enter / Exit',
                              style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Row(
                              children: [
                                Icon(Icons.hourglass_empty, size: 14, color: Color(0xFF9B9FA6)),
                                SizedBox(width: 6),
                                TranslatedText(
                                  '00:20 seconds',
                                  style: TextStyle(color: Color(0xFF9B9FA6), fontSize: 12, fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 220,
                          child: Center(
                            child: Image.asset(
                              Images.qrcodeImage,
                              fit: BoxFit.contain,
                              width: 220,
                              height: 220,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
