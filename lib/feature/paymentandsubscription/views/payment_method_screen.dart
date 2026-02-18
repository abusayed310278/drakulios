import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/assets.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int _selectedMethod = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: Color(0xFFC9CDD3),
                          ),
                          splashRadius: 18,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Choose Payment Method',
                          style: TextStyle(
                            color: Color(0xFFE6E7EA),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _PaymentMethodCard(
                      title: 'Debit / Credit Card',
                      subtitle: 'Visa, Mastercard',
                      leading: const _CardIcon(),
                      selected: _selectedMethod == 0,
                      onTap: () => setState(() => _selectedMethod = 0),
                    ),
                    const SizedBox(height: 12),
                    _PaymentMethodCard(
                      title: 'Stripe',
                      subtitle: 'Pay with Stripe',
                      leading: const _StripeBadge(),
                      selected: _selectedMethod == 1,
                      onTap: () => setState(() => _selectedMethod = 1),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Card Details',
                      style: TextStyle(
                        color: Color(0xFFF5F6F8),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _FieldLabel(text: 'Card Number'),
                    const SizedBox(height: 8),
                    _DarkTextField(
                      hintText: '0000 0000 0000 0000',
                      suffixIcon: const Icon(
                        Icons.credit_card,
                        color: Color(0xFFE2E5EA),
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: const [
                        Expanded(child: _FieldLabel(text: 'Expiry Date')),
                        SizedBox(width: 12),
                        Expanded(child: _FieldLabel(text: 'CW')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Expanded(
                          child: _DarkTextField(hintText: 'MM/YY'),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: _DarkTextField(hintText: '123')),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            color: Color.fromARGB(255, 232, 235, 240),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          r'$49.00',
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
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
                          r'Pay $49.00',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          Images.protectImage,
                          width: 14,
                          height: 14,
                          color: const Color(0xFFB1B1B1),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Your payment is encrypted and secure',
                          style: TextStyle(
                            color: Color(0xFFB1B1B1),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget leading;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0C11),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFFF2B31A)
                  : const Color(0xFF2A2F39),
              width: 1.2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFFF4F5F7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF9EA3AA),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardIcon extends StatelessWidget {
  const _CardIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF1F7AE0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.credit_card, size: 16, color: Colors.white),
    );
  }
}

class _StripeBadge extends StatelessWidget {
  const _StripeBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Center(
        child: Text(
          'stripe',
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Color.fromARGB(255, 229, 235, 244),
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.0,
      ),
    );
  }
}

class _DarkTextField extends StatelessWidget {
  const _DarkTextField({required this.hintText, this.suffixIcon});

  final String hintText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        style: const TextStyle(color: Color(0xFFF5F6F8), fontSize: 13),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF7E838C), fontSize: 13),
          filled: true,
          fillColor: const Color(0xFF0A0C11),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF263141), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF3A4860), width: 1.2),
          ),
        ),
      ),
    );
  }
}
