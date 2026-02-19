import 'package:flutter/material.dart';

import '../../../core/constants/assets.dart';
import '../../paymentandsubscription/views/payment_method_screen.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  final List<int> _quantities = List<int>.filled(4, 2);

  void _incrementQuantity(int index) {
    setState(() {
      _quantities[index] += 1;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (_quantities[index] > 1) {
        _quantities[index] -= 1;
      }
    });
  }

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
              padding: const EdgeInsets.fromLTRB(18, 40, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Transform.translate(
                        offset: const Offset(-15, 0),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFFC9CDD3)),
                          splashRadius: 18,
                          padding: EdgeInsets.zero,

                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Shopping Cart',
                        style: TextStyle(color: Color(0xFFB1B1B1), fontSize: 18, fontWeight: FontWeight.w400, height: 1.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  GridView.builder(
                    padding: const EdgeInsets.only(top: 6),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 220,
                    ),
                    itemCount: _quantities.length,
                    itemBuilder: (context, index) {
                      return _CartItemCard(
                        image: Images.gym1Image,
                        quantity: _quantities[index],
                        onDecrease: () => _decrementQuantity(index),
                        onIncrease: () => _incrementQuantity(index),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const _SummaryRow(label: 'Subtotal', value: r'$449'),
                  const SizedBox(height: 4),
                  const _SummaryRow(label: 'Estimated Tax', value: r'$449'),
                  const SizedBox(height: 6),
                  const _SummaryRow(label: 'Total', value: r'$449', bold: true),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentMethodScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2B31A),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text(
                        'Make Payment',
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

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.image, required this.quantity, required this.onDecrease, required this.onIncrease});

  final String image;
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x52F3B41A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF3B41A), width: 0.48),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(image, height: 90, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'GT5s Motorized Treadmill',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text(
                  r'$1200',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0x33F3B41A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF3B41A), width: 1),
                      ),
                      child: Center(child: Image.asset(Images.deleteImage, width: 14, height: 14, color: Colors.white)),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 116,
                      height: 28,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0x33F3B41A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFF3B41A), width: 1),
                        ),
                        child: Row(
                          children: [
                            const Text('Quantity:', style: TextStyle(color: Colors.white, fontSize: 10)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Row(
                                  children: [
                                    _QtyButton(icon: Icons.remove, onTap: onDecrease),
                                    const SizedBox(width: 6),
                                    Text('$quantity', style: const TextStyle(color: Colors.white, fontSize: 10)),
                                    const SizedBox(width: 6),
                                    _QtyButton(icon: Icons.add, onTap: onIncrease),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
        child: Icon(icon, size: 12, color: Colors.black),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(color: Colors.white, fontSize: bold ? 14 : 12, fontWeight: bold ? FontWeight.w600 : FontWeight.w400);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
