import 'package:flutter/material.dart';

import '../../../core/constants/assets.dart';
import 'payment_method_screen.dart';

class PaymentAndSubscriptionScreen extends StatefulWidget {
  const PaymentAndSubscriptionScreen({super.key});

  @override
  State<PaymentAndSubscriptionScreen> createState() =>
      _PaymentAndSubscriptionScreenState();
}

class _PaymentAndSubscriptionScreenState
    extends State<PaymentAndSubscriptionScreen> {
  int _selectedPlanIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
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
                        Expanded(
                          child: Center(
                            child: SizedBox(
                              width: 60,
                              height: 43,
                              child: Image.asset(
                                Images.appLogo,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Choose Your Plan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'All Features, No Limit',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFB1B1B1),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _PlanCard(
                    title: 'Training Plan',
                    price: '€89',
                    accent: const Color(0xFFF2B31A),
                    cardColor: const Color(0xFF3D3315),
                    bulletColor: const Color.fromARGB(255, 219, 218, 216),
                    subtitle: 'One-time',
                    items: const [
                      'Personalized workout plan',
                      'No revisions',
                      'No follow-ups',
                    ],
                    selected: _selectedPlanIndex == 0,
                    onTap: () => setState(() => _selectedPlanIndex = 0),
                  ),
                  const SizedBox(height: 14),
                  _PlanCard(
                    title: 'Online Coaching',
                    price: '€149 / Month',
                    accent: const Color(0xFFD07BFF),
                    cardColor: const Color(0xFF2E1F3D),
                    bulletColor: const Color.fromARGB(255, 219, 218, 216),
                    subtitle: 'Subscription',
                    items: const [
                      'Main Product',
                      'Includes training',
                      'Nutrition and continuous follow-up',
                    ],
                    priceWidget: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(text: '€149 '),
                          TextSpan(
                            text: '/ Month',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFD07BFF).withOpacity(0.9),
                            ),
                          ),
                        ],
                        style: const TextStyle(
                          color: Color(0xFFD07BFF),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    selected: _selectedPlanIndex == 1,
                    onTap: () => setState(() => _selectedPlanIndex = 1),
                  ),
                  const SizedBox(height: 14),
                  _PlanCard(
                    title: '1-to-1 Training',
                    price: 'Varies',
                    accent: const Color(0xFF45B3FF),
                    cardColor: const Color(0xFF0D1D3D),
                    bulletColor: const Color.fromARGB(255, 219, 218, 216),
                    subtitle: 'Session Packs',
                    items: const [
                      'In-person coaching sold in packs',
                      '4, 8, or 12 sessions',
                    ],
                    selected: _selectedPlanIndex == 2,
                    onTap: () => setState(() => _selectedPlanIndex = 2),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PaymentMethodScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2B31A),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Make Payment',
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
                  const Text(
                    'You can cancel subscription anytime',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFB1B1B1),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
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

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.price,
    this.priceWidget,
    required this.accent,
    required this.cardColor,
    required this.bulletColor,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final List<String> items;
  final String price;
  final Widget? priceWidget;
  final Color accent;
  final Color cardColor;
  final Color bulletColor;
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
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? accent : const Color(0xFF3F444C),
              width: 1.2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SelectionDot(color: accent, selected: selected),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFFF6F7F9),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Color(0xFFF6F7F9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '•',
                                style: TextStyle(
                                  color: bulletColor,
                                  fontSize: 16,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 231, 236, 244),
                                    fontSize: 13,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 10),
                priceWidget ??
                    Text(
                      price,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 231, 236, 244),
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
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

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.color, required this.selected});

  final Color color;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        color: selected ? color : Colors.transparent,
      ),
      child: selected
          ? const Center(
              child: CircleAvatar(radius: 2.4, backgroundColor: Colors.black),
            )
          : null,
    );
  }
}
