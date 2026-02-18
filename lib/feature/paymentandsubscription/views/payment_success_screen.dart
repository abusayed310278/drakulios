import 'package:flutter/material.dart';

import '../../home/views/home_menu_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

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
              padding: const EdgeInsets.fromLTRB(18, 40, 18, 24),
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
                      const Text(
                        'Confirmation',
                        style: TextStyle(color: Color(0xFFE6E7EA), fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1B3F22)),
                        ),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF39C56B)),
                          child: const Icon(Icons.check, size: 36, color: Color(0xFF0F1B12)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Payment Successful',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF39C56B), fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your job is now live and visible to our\ncreative community',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFB1B1B1), fontSize: 12, height: 1.4),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeMenuScreen()));
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
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.2, color: Color(0xFFFFFFFF)),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18, color: Color(0xFFFFFFFF)),
                        ],
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
