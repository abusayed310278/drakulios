import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/assets.dart';
import 'shopping_cart_screen.dart';
import 'widgets/shop_header.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 50, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ShopHeader(title: 'Product Details'),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(Images.gym1Image, height: 200, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 62,
                    child: Row(
                      children: [
                        const _ThumbNavButton(icon: Icons.chevron_left),
                        const SizedBox(width: 6),
                        _Thumb(image: Images.gym1Image, selected: true),
                        const SizedBox(width: 6),
                        _Thumb(image: Images.gym2Image),
                        const SizedBox(width: 6),
                        _Thumb(image: Images.gym3Image),
                        const SizedBox(width: 6),
                        _Thumb(image: Images.gym1Image),
                        const SizedBox(width: 6),
                        const _ThumbNavButton(icon: Icons.chevron_right),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(
                    width: 343,
                    height: 29,
                    child: Text(
                      'GT5s Motorized Treadmill',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600, height: 1.2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    r'$1200',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, height: 1.0),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'This treadmill is a beast—',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1.2),
                        ),
                        TextSpan(
                          text:
                              'perfect for a “Pro” gym. For your Product Detail Page, you need specific technical data to make it look professional.\nHere are the full details for the Daily Youth GT5s Motorized Treadmill formatted for your design:',
                          style: TextStyle(color: Color(0xFFB7B7B7), fontSize: 14, fontWeight: FontWeight.w400, height: 1.2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _SectionTitle(text: 'Product Overview'),
                  const _Bullet(text: 'Price: \$1,200 (approx. 115,000 - 125,000 BDT)'),
                  const _Bullet(text: 'Model: GT5s Commercial Series'),
                  const _Bullet(text: 'Target: Commercial Gyms / Professional Home Setup'),
                  const SizedBox(height: 10),
                  const _SectionTitle(text: 'Technical Specifications'),
                  const _Bullet(text: 'Motor: 4.0 HP AC Motor (High-torque for heavy commercial use).'),
                  const _Bullet(text: 'Speed Range: 1.0 - 18.0 km/h (Perfect for everything from walking to high-intensity sprints).'),
                  const _Bullet(text: 'Incline: 20% & 15% (optional).'),
                  const _Bullet(text: 'Dimensions: 200 x 80 x 150 cm.'),
                  const _Bullet(text: 'Machine Weight: Net Weight (NW) 112 kg / Gross Weight (GW) 135 kg.'),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShoppingCartScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2B31A),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Go to cart',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.2, color: Colors.white),
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

class _Thumb extends StatelessWidget {
  const _Thumb({required this.image, this.selected = false});

  final String image;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E2024),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? const Color(0xFFF2B31A) : const Color(0xFF3A3F47), width: 1.1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(image, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _ThumbNavButton extends StatelessWidget {
  const _ThumbNavButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2024),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3A3F47), width: 1.1),
      ),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.white, fontSize: 12)),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3)),
          ),
        ],
      ),
    );
  }
}
