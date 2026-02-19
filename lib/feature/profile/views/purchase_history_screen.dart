import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/assets.dart';

class PurchaseHistoryScreen extends StatelessWidget {
  const PurchaseHistoryScreen({super.key});

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
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFFC9CDD3)),
                          splashRadius: 18,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        ),
                      ),
                      Text(
                        'Purchase History',
                        style: GoogleFonts.outfit(color: Colors.grey, fontSize: 30 / 2, fontWeight: FontWeight.w500, height: 1.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: const Color(0xFF2A2F39),
                        child: ClipOval(child: Image.asset(Images.profileImage, width: 70, height: 70, fit: BoxFit.cover)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stella Jacobs',
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 34 / 2, fontWeight: FontWeight.w700, height: 1.2),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Member ID : 1212',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFD8DCE2),
                              fontSize: 25 / 2,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Purchase Status',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 30 / 2, fontWeight: FontWeight.w600, height: 1.2),
                  ),
                  const SizedBox(height: 10),
                  const _StatusTile(text: 'Pending Orders: 0'),
                  const SizedBox(height: 8),
                  const _StatusTile(text: 'Last Purchase: 30 December 2025'),
                  const SizedBox(height: 18),
                  Text(
                    'Purchase List',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 30 / 2, fontWeight: FontWeight.w600, height: 1.2),
                  ),
                  const SizedBox(height: 10),
                  const _PurchaseCard(),
                  const SizedBox(height: 10),
                  const _PurchaseCard(),
                  const SizedBox(height: 10),
                  const _PurchaseCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E234D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2C6CFF), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_filled, color: Color(0xFFF3B41A), size: 22),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.outfit(color: const Color(0xFFF2F4F8), fontSize: 13, fontWeight: FontWeight.w400, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _PurchaseCard extends StatelessWidget {
  const _PurchaseCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3B2D08),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFF3B41A), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.asset(Images.gym1Image, width: 102, height: 82, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order ID: #PFC-7721',
                  style: GoogleFonts.outfit(color: const Color(0xFFE3E6EC), fontSize: 13, fontWeight: FontWeight.w400, height: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  'GT5s Motorized\nTreadmill',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 34 / 2, fontWeight: FontWeight.w500, height: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  r'$1200',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 40 / 2, fontWeight: FontWeight.w700, height: 1.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
