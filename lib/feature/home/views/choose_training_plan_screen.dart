import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/assets.dart';

class ChooseTrainingPlanScreen extends StatefulWidget {
  const ChooseTrainingPlanScreen({super.key});

  @override
  State<ChooseTrainingPlanScreen> createState() =>
      _ChooseTrainingPlanScreenState();
}

class _ChooseTrainingPlanScreenState extends State<ChooseTrainingPlanScreen> {
  int? _selectedPlan;

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
        title: '12-Month Plan Single Payment',
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
        priceMain: '€330',
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
              padding: const EdgeInsets.fromLTRB(18, 36, 18, 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
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
                        ],
                      ),
                      const SizedBox(height: 2),
                      Center(
                        child: Image.asset(
                          Images.appLogo,
                          width: 44,
                          height: 39,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Choose Your Plan',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          color: const Color(0xFFEDEEF0),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'All Features, No Limit',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          color: const Color(0xFFB0B6C0),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
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
                            onTap: () => setState(() => _selectedPlan = index),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 34,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF2B31A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: Text(
                            'Make Payment',
                            style: GoogleFonts.nunito(
                              color: const Color(0xFFFFFFFF),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You can cancel subscription anytime',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF9AA1AE),
                          fontSize: 7.5,
                          fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
      decoration: BoxDecoration(
        color: const Color(0xFF23428A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF8EA2DC), width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.card_membership_rounded,
                color: Color(0xFFF3B41A),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                'Membership Rules',
                style: GoogleFonts.nunito(
                  color: const Color(0xFFEFF2F8),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const _RuleLine(
            icon: Icons.sync_alt_rounded,
            title: 'Switching:',
            body: 'Change plans anytime;\ncommitment plans must upgrade',
          ),
          const SizedBox(height: 5),
          const _RuleLine(
            icon: Icons.timelapse,
            title: 'Timelines:',
            body: 'New commitment starts\nafter the old one ends.',
          ),
          const SizedBox(height: 5),
          const _RuleLine(
            icon: Icons.pan_tool_alt,
            title: 'Freeze:',
            body: 'Pause once for up to 1 month\nper year',
          ),
          const SizedBox(height: 5),
          const _RuleLine(
            icon: Icons.cancel,
            title: 'Cancel:',
            body: 'Cancel anytime for a 100€ fee.',
          ),
          const SizedBox(height: 5),
          const _RuleLine(
            icon: Icons.lock,
            title: 'Off-Peak:',
            body: 'Access limited to authorized\nhours.',
          ),
          const SizedBox(height: 5),
          const _RuleLine(
            icon: Icons.lock_outline,
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
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 11, color: const Color(0xFFF3B41A)),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.nunito(
                color: const Color(0xFFEFF2F8),
                fontSize: 8.5,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
              children: [
                TextSpan(
                  text: '$title ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: body),
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
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: plan.markerColor, width: 2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      plan.title,
                      style: GoogleFonts.nunito(
                        color: const Color(0xFFF2F4F8),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
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
                        style: GoogleFonts.nunito(
                          color: const Color(0xFFFFFFFF),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          b,
                          style: GoogleFonts.nunito(
                            color: const Color(0xFFF2F4F8),
                            fontSize: 7.6,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
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
                    style: GoogleFonts.nunito(
                      color: const Color(0xFFFFFFFF),
                      fontSize: 8 * 2,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
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
                      style: GoogleFonts.nunito(
                        color: const Color(0xFFFFFFFF),
                        fontSize: 8 * 2,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        plan.note!,
                        style: GoogleFonts.nunito(
                          color: const Color(0xFFF3B41A),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
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
