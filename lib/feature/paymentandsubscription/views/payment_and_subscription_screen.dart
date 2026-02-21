import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/assets.dart';
import '../../home/views/terms_conditions_screen.dart';
import 'payment_flow_destination.dart';
import 'payment_method_screen.dart';

class PaymentAndSubscriptionScreen extends StatefulWidget {
  const PaymentAndSubscriptionScreen({super.key});

  @override
  State<PaymentAndSubscriptionScreen> createState() =>
      _PaymentAndSubscriptionScreenState();
}

class _PaymentAndSubscriptionScreenState
    extends State<PaymentAndSubscriptionScreen> {
  int? _selectedPlan;

  void _goToPaymentMethod() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PaymentMethodScreen(
          flowDestination: PaymentFlowDestination.homeMenu,
        ),
      ),
    );
  }

  Future<void> _openTermsFlow() async {
    final accepted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const TermsConditionsScreen()),
    );
    if (!mounted) return;
    if (accepted == true) {
      _goToPaymentMethod();
    }
  }

  Future<void> _showTermsDialog() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 34),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(dialogContext).pop(),
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(
                        Icons.close,
                        size: 22,
                        color: Color(0xFF1F222A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'By accepting this you agree with our',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1E2024),
                  fontSize: 24 / 2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _openTermsFlow();
                },
                child: Text(
                  'Terms And Conditions.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFF2B31A),
                    fontSize: 24 / 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFF2B31A),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Deny',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFF2B31A),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _goToPaymentMethod();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2B31A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Accept',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFFFFF),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plans = <_PlanModel>[
      const _PlanModel(
        title: 'Daily Pass',
        markerColor: Color(0xFFF3B41A),
        borderColor: Color(0xFFF3B41A),
        background: LinearGradient(
          colors: [Color(0xFF073447), Color(0xFF073447)],
        ),
        bullets: [
          'Access for one day',
          'Full access to the gym between 6:00 and 23:00',
        ],
        priceMain: '€10',
      ),
      const _PlanModel(
        title: 'Monthly Plan',
        markerColor: Color(0xFF4BCDC0),
        borderColor: Color(0xFF6A8C87),
        background: LinearGradient(
          colors: [Color(0xFF142733), Color(0xFF124331)],
        ),
        bullets: [
          'Full access to the gym',
          'Renewable subscription with no commitment until cancellation',
        ],
        priceMain: '€40',
        priceAccent: '/ Month',
        accentColor: Color(0xFF4BCDC0),
      ),
      const _PlanModel(
        title: '6-Month Plan',
        markerColor: Color(0xFFB45CFF),
        borderColor: Color(0xFF7A5D9A),
        background: LinearGradient(
          colors: [Color(0xFF2E1C44), Color(0xFF39214D)],
        ),
        bullets: [
          'Gift: 1 Pro Factory T-shirt',
          'Full access to the gym',
          'Renewable subscription with a minimum commitment period of 6 months',
        ],
        priceMain: '€35',
        priceAccent: '/ Month',
        accentColor: Color(0xFFB45CFF),
      ),
      const _PlanModel(
        title: '12-Month Plan',
        markerColor: Color(0xFFF39DB8),
        borderColor: Color(0xFF8D6675),
        background: LinearGradient(
          colors: [Color(0xFF4A2D39), Color(0xFF4A3139)],
        ),
        bullets: [
          'Gift: 1 Pro Factory hoodie',
          'Full access to the gym',
          'Renewable subscription with a minimum commitment period of 12 months',
        ],
        priceMain: '€30',
        priceAccent: '/ Month',
        accentColor: Color(0xFFF39DB8),
      ),
      const _PlanModel(
        title: '12-Month Plan Single\nPayment',
        markerColor: Color(0xFFF0C13F),
        borderColor: Color(0xFF8A7B4A),
        background: LinearGradient(
          colors: [Color(0xFF3A2E08), Color(0xFF433308)],
        ),
        bullets: [
          'Gift: 1 Pro Factory hoodie',
          'Full access to the gym',
          'Renewable subscription for 12 months with no commitment.',
        ],
        priceMain: '€330/',
        note: 'Subscription with discount\nfor upfront payment',
      ),
      const _PlanModel(
        title: 'Off-Peak 12-Month Plan',
        markerColor: Color(0xFFA7A7A7),
        borderColor: Color(0xFF626B76),
        background: LinearGradient(
          colors: [Color(0xFF191E2B), Color(0xFF20222D)],
        ),
        bullets: [
          'Gift: 1 Pro Factory T-shirt',
          'Renewable subscription with a minimum commitment period of 12 months',
          'Access to the gym at the following times:\nMonday to Friday: From 6:00 to 8:30 From 13:00 to 16:00 From 21:30 to 23:00\nWeekends: Full access to the gym',
        ],
        priceMain: '€25',
        priceAccent: '/ Month',
        accentColor: Color(0xFFA7A7A7),
      ),
      const _PlanModel(
        title: 'Youth Off-Peak\n12-Month Plan',
        markerColor: Color(0xFF45C83C),
        borderColor: Color(0xFF5A8755),
        background: LinearGradient(
          colors: [Color(0xFF15270E), Color(0xFF1C3112)],
        ),
        bullets: [
          'Gift: 1 Pro Factory T-shirt',
          'For young people between 16 and 23 years of age',
          'Renewable subscription with a minimum commitment period of 12 months.',
          'Access to the gym at the following times:\nMonday to Friday: From 6:00 to 8:30 From 13:00 to 16:00 From 21:30 to 23:00\nWeekends: Full access to the gym',
        ],
        priceMain: '€20',
        priceAccent: '/ Month',
        accentColor: Color(0xFF45C83C),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 60, 18, 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 343),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 2),
                      Center(
                        child: Image.asset(
                          Images.appLogo,
                          width: 60,
                          height: 53,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 343,
                        child: Text(
                          'Choose Your Plan',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFFFFF),
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 343,
                        child: Text(
                          'All Features, No Limit',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFB1B1B1),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const _RulesCard(),
                      const SizedBox(height: 10),
                      ...List.generate(plans.length, (index) {
                        final p = plans[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == plans.length - 1 ? 0 : 12,
                          ),
                          child: _MembershipPlanCard(
                            plan: p,
                            selected: _selectedPlan == index,
                            onTap: () async {
                              setState(() => _selectedPlan = index);
                              await _showTermsDialog();
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _showTermsDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3B41A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Make Payment',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFFFFF),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 346,
                        child: Text(
                          'You can cancel subscription anytime',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFB1B1B1),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RulesCard extends StatelessWidget {
  const _RulesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 373),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(37, 99, 235, 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromRGBO(255, 255, 255, 0.19),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                Images.membershipImage,
                width: 16,
                height: 16,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Membership Rules',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFFFFF),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _RuleLine(
            iconPath: Images.switchingImage,
            title: 'Switching:',
            body: 'Change plans anytime;\ncommitment plans must upgrade',
          ),
          const SizedBox(height: 10),
          const _RuleLine(
            iconPath: Images.timelinessImage,
            title: 'Timelines:',
            body: 'New commitment starts\nafter the old one ends.',
          ),
          const SizedBox(height: 10),
          const _RuleLine(
            iconPath: Images.freezeImage,
            title: 'Freeze:',
            body: 'Pause once for up to 1 month\nper year',
          ),
          const SizedBox(height: 10),
          const _RuleLine(
            iconPath: Images.cancelImage,
            title: 'Cancel:',
            body: 'Cancel anytime for a 100€ fee.',
          ),
          const SizedBox(height: 10),
          const _RuleLine(
            iconPath: Images.lockImage,
            title: 'Off-Peak:',
            body: 'Access limited to authorized\nhours.',
          ),
          const SizedBox(height: 10),
          const _RuleLine(
            iconPath: Images.lockImage,
            title: 'Refunds:',
            body: 'All sales are final.',
          ),
        ],
      ),
    );
  }
}

class _RuleLine extends StatelessWidget {
  const _RuleLine({
    required this.iconPath,
    required this.title,
    required this.body,
  });

  final String iconPath;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = GoogleFonts.outfit(
      color: const Color(0xFFFFFFFF),
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.35,
      letterSpacing: 0,
    );
    final titleStyle = GoogleFonts.outfit(
      color: const Color(0xFFFFFFFF),
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.35,
      letterSpacing: 0,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Image.asset(
            iconPath,
            width: 16,
            height: 16,
            fit: BoxFit.contain,
            color: const Color(0xFFF3B41A),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: title.replaceAll(':', ''), style: titleStyle),
                TextSpan(text: ': ', style: bodyStyle),
                TextSpan(text: body, style: bodyStyle),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MembershipPlanCard extends StatelessWidget {
  const _MembershipPlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final _PlanModel plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          decoration: BoxDecoration(
            gradient: plan.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: plan.borderColor,
              width: selected ? 2.1 : 1.15,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: plan.borderColor.withValues(alpha: 0.32),
                      blurRadius: 10,
                      spreadRadius: 0.5,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: plan.markerColor, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      plan.title,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFF2F4F8),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ...plan.bullets.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '•',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFFFFFF),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 249),
                          child: Text(
                            b,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFFFFFF),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              if (plan.note == null)
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFFFFF),
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(text: plan.priceMain),
                      if (plan.priceAccent != null)
                        TextSpan(
                          text: plan.priceAccent,
                          style: TextStyle(
                            color: plan.accentColor ?? const Color(0xFFFFFFFF),
                          ),
                        ),
                    ],
                  ),
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.priceMain,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFFFFF),
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: SizedBox(
                        width: 165,
                        height: 34,
                        child: Text(
                          plan.note!,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFF3B41A),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanModel {
  const _PlanModel({
    required this.title,
    required this.markerColor,
    required this.borderColor,
    required this.background,
    required this.bullets,
    required this.priceMain,
    this.priceAccent,
    this.accentColor,
    this.note,
  });

  final String title;
  final Color markerColor;
  final Color borderColor;
  final Gradient background;
  final List<String> bullets;
  final String priceMain;
  final String? priceAccent;
  final Color? accentColor;
  final String? note;
}
