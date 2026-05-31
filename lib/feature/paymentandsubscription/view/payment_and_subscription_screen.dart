import 'package:flutter/material.dart';

import '../../../core/language/translated_text.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/constants/assets.dart';
import '../controller/payment_and_subscription_controller.dart';
import '../model/default_subscription_plans.dart';
import '../model/subscription_plan_model.dart';
import '../../home/view/terms_conditions_screen.dart';
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
  final PaymentAndSubscriptionController _controller =
      PaymentAndSubscriptionController();
  int? _selectedPlan;
  PlanModel? _selectedPlanData;
  List<PlanModel> _apiPlans = <PlanModel>[];
  bool _loadingPlans = false;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionPlans();
  }

  Future<void> _fetchSubscriptionPlans() async {
    setState(() => _loadingPlans = true);
    try {
      final mappedPlans = await _controller.fetchPlans();
      if (!mounted) return;
      setState(() {
        _apiPlans = mappedPlans;
        if (_selectedPlan != null && _selectedPlan! >= mappedPlans.length) {
          _selectedPlan = null;
          _selectedPlanData = null;
        }
      });
    } catch (_) {
      if (!mounted) return;
      CustomSnackbar.show('Failed to load subscription plans from API');
    } finally {
      if (mounted) setState(() => _loadingPlans = false);
    }
  }

  void _goToPaymentMethod({PlanModel? selectedPlan}) {
    final plan = selectedPlan ?? _selectedPlanData;
    if (plan == null) {
      CustomSnackbar.show('Please select a subscription plan first');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentMethodScreen(
          flowDestination: PaymentFlowDestination.homeMenu,
          amount: plan.amount ?? 49,
          subscriptionId: plan.subscriptionId,
          billingPeriod: plan.billingPeriod,
        ),
      ),
    );
  }

  Future<void> _openTermsFlow({PlanModel? selectedPlan}) async {
    final accepted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const TermsConditionsScreen()),
    );
    if (!mounted) return;
    if (accepted == true) {
      _goToPaymentMethod(selectedPlan: selectedPlan);
    }
  }

  Future<void> _showTermsDialog({PlanModel? selectedPlan}) async {
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
              TranslatedText(
                'By accepting this you agree with our',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1E2024),
                  fontSize: 24 / 2,
                  fontWeight: FontWeight.w500,
                ),
                autoSize: true,
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _openTermsFlow(selectedPlan: selectedPlan);
                },
                child: TranslatedText(
                  'Terms And Conditions.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFF2B31A),
                    fontSize: 24 / 2,
                    fontWeight: FontWeight.w500,
                  ),
                  autoSize: true,
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
                        child: TranslatedText(
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
                          _goToPaymentMethod(selectedPlan: selectedPlan);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2B31A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: TranslatedText(
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
    final plans = _apiPlans.isNotEmpty ? _apiPlans : defaultSubscriptionPlans;

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
                        child: TranslatedText(
                          'Choose Your Plan',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFFFFF),
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          autoSize: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 343,
                        child: TranslatedText(
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
                      if (_loadingPlans)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: LinearProgressIndicator(
                            minHeight: 2,
                            backgroundColor: Color(0xFF1A1D24),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFF3B41A),
                            ),
                          ),
                        ),
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
                              setState(() {
                                _selectedPlan = index;
                                _selectedPlanData = p;
                              });
                              await _showTermsDialog(selectedPlan: p);
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
                          child: TranslatedText(
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
                        child: TranslatedText(
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
                child: TranslatedText(
                  'Membership Rules',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFFFFFF),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  autoSize: true,
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

  final PlanModel plan;
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
                    child: TranslatedText(
                      plan.title,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFF2F4F8),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      autoSize: true,
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
                      TranslatedText(
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
                          child: TranslatedText(
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
                    TranslatedText(
                      plan.priceMain,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFFFFFFF),
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      autoSize: true,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: SizedBox(
                        width: 165,
                        height: 34,
                        child: TranslatedText(
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
