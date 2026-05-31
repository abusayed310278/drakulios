import 'package:flutter/material.dart';

import '../../../core/language/translated_text.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/constants/assets.dart';
import '../../shop/widgets/shop_badge_state.dart';
import '../controller/payment_method_controller.dart';
import '../model/payment_process_request.dart';
import 'payment_flow_destination.dart';
import 'payment_success_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({
    super.key,
    this.flowDestination = PaymentFlowDestination.homeMenu,
    this.amount = 49,
    this.subscriptionId,
    this.billingPeriod,
    this.shippingAddress,
  });

  final PaymentFlowDestination flowDestination;
  final double amount;
  final String? subscriptionId;
  final String? billingPeriod;
  final String? shippingAddress;

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final PaymentMethodController _controller = PaymentMethodController();
  int _selectedMethod = 0;
  bool _isPaying = false;
  bool _navigatedToSuccess = false;

  Future<void> _handlePay() async {
    if (_isPaying) {
      return;
    }

    setState(() => _isPaying = true);
    try {
      final result = await _controller.processPayment(
        PaymentProcessRequest(
          flowDestination: widget.flowDestination,
          amount: widget.amount,
          selectedMethod: _selectedMethod,
          subscriptionId: widget.subscriptionId,
          billingPeriod: widget.billingPeriod,
          shippingAddress: widget.shippingAddress,
        ),
      );

      if (!mounted) {
        return;
      }

      if (!result.success) {
        CustomSnackbar.show(result.message ?? 'Payment failed');
        return;
      }

      if (result.clearShopCart) {
        ShopBadgeState.setCartCount(0);
      }
      _goToSuccessScreen();
    } finally {
      if (mounted) {
        setState(() => _isPaying = false);
      }
    }
  }

  void _goToSuccessScreen() {
    if (!mounted || _navigatedToSuccess) {
      return;
    }

    _navigatedToSuccess = true;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PaymentSuccessScreen(flowDestination: widget.flowDestination),
      ),
    );
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
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
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
                        ),
                        const SizedBox(width: 6),
                        TranslatedText(
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
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TranslatedText(
                          'Total Amount',
                          style: TextStyle(
                            color: Color.fromARGB(255, 232, 235, 240),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TranslatedText(
                          '\$${widget.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
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
                        onPressed: _isPaying ? null : _handlePay,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2B31A),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isPaying
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : TranslatedText(
                                'Pay \$${widget.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                  color: Color(0xFFFFFFFF),
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
                        TranslatedText(
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
                      TranslatedText(
                        title,
                        style: const TextStyle(
                          color: Color(0xFFF4F5F7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      TranslatedText(
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
        child: TranslatedText(
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
