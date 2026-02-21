import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/assets.dart';
import 'health_profile_screen.dart';
import 'terms_conditions_screen.dart';

class ChooseTrainingPlanScreen extends StatefulWidget {
  const ChooseTrainingPlanScreen({super.key});

  @override
  State<ChooseTrainingPlanScreen> createState() => _ChooseTrainingPlanScreenState();
}

class _ChooseTrainingPlanScreenState extends State<ChooseTrainingPlanScreen> {
  int? _selectedPlan = 0;

  int get _selectedPlanIndex => _selectedPlan ?? 0;

  Future<void> _openTermsFlow() async {
    final accepted = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const TermsConditionsScreen()));
    if (!mounted) return;
    if (accepted == true) {
      await _showBodyGoalsDialog();
    }
  }

  Future<void> _showBodyGoalsDialog() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 34),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16)),
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
                      child: Icon(Icons.close, size: 20, color: Color(0xFF1F222A)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'To help us build the best possible plan for you, please tell us a little bit about your body and goals',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: const Color(0xFF1E2024), fontSize: 12, fontWeight: FontWeight.w500, height: 1.35),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    await Future<void>.delayed(Duration.zero);
                    if (!mounted) return;
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HealthProfileScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2B31A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: GoogleFonts.outfit(color: const Color(0xFFFFFFFF), fontSize: 18, fontWeight: FontWeight.w500, height: 1.2),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18, color: Color(0xFFFFFFFF)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(8)),
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
                      child: Icon(Icons.close, size: 22, color: Color(0xFF1F222A)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'By accepting this you agree with our',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: const Color(0xFF1E2024), fontSize: 12, fontWeight: FontWeight.w500),
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
                  style: GoogleFonts.outfit(color: const Color(0xFFF2B31A), fontSize: 12, fontWeight: FontWeight.w500),
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
                          side: const BorderSide(color: Color(0xFFF2B31A), width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'Deny',
                          style: GoogleFonts.outfit(color: const Color(0xFFF2B31A), fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          await Future<void>.delayed(Duration.zero);
                          if (!mounted) return;
                          _showBodyGoalsDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2B31A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'Accept',
                          style: GoogleFonts.outfit(color: const Color(0xFFFFFFFF), fontSize: 16, fontWeight: FontWeight.w500),
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
    final plans = <_TrainingPlanModel>[
      const _TrainingPlanModel(
        title: 'Online Coaching',
        markerColor: Color(0xFFB45CFF),
        borderColor: Color(0xFFF2B31A),
        backgroundColor: Color(0xFF28195F),
        bullets: [
          'Monthly payment.',
          'This plan includes: Planning of a training plan personalized to their objectives, a personalized nutrition plan, weekly online reviews with their coach.',
          'When choosing this plan the user will access the objectives questionnaire and from there to the payment gateway.',
          'After a period of 24/48 they will be able to see in their profile the following:',
        ],
        numberedItems: ['Daily personalized training plan.', 'Complete nutrition plan.', 'Weekly online reviews to be agreed in calendar.'],
      ),
      const _TrainingPlanModel(
        title: 'Training Plan',
        markerColor: Color(0xFF08BBFF),
        borderColor: Color(0xFF1D8CB4),
        backgroundColor: Color(0xFF072B46),
        bullets: [
          'One-time payment product.',
          'This plan includes: Planning of a training plan personalized to their objectives elaborated for a determined time.',
          'When choosing this product the user will access the objectives questionnaire and from there to the payment gateway.',
          'After a period of 24/48 they will be able to see in their profile the following:',
        ],
        numberedItems: ['Daily personalized training plan.'],
      ),
      const _TrainingPlanModel(
        title: 'Personal Training',
        markerColor: Color(0xFFF2B31A),
        borderColor: Color(0xFF88660B),
        backgroundColor: Color(0xFF3A2B05),
        bullets: [
          'One-time payment product.',
          'This plan includes: 1 to 1 personal training sessions with a personal trainer.',
          'When choosing this product the user will access the objectives questionnaire and from there must choose one of the following packages:',
        ],
        numberedItems: [
          '4 training sessions.',
          '8 training sessions.',
          '12 training sessions.',
          'After acquiring one of the mentioned packages the user will be able to see a calendar where they will have to choose the days they want to carry out the personal training, and a counter of how many sessions they have left as credit.',
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(17, 5, 17, 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 343),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            splashRadius: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                            icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFFE4E6EB)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Center(child: Image.asset(Images.appLogo, width: 60, height: 53, fit: BoxFit.contain)),
                      const SizedBox(height: 12),
                      Text(
                        'Choose Your Training Plan',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFF3F5F9),
                          fontSize: 31 / 2,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      // const SizedBox(height: 8),
                      // Text(
                      //   'All Features, No Limit',
                      //   textAlign: TextAlign.center,
                      //   style: GoogleFonts.outfit(
                      //     color: const Color(0xFFB0B6C0),
                      //     fontSize: 10,
                      //     fontWeight: FontWeight.w500,
                      //     height: 1.0,
                      //   ),
                      // ),
                      const SizedBox(height: 14),
                      ...List.generate(plans.length, (index) {
                        final plan = plans[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: index == plans.length - 1 ? 0 : 10),
                          child: _TrainingPlanCard(
                            plan: plan,
                            selected: _selectedPlanIndex == index,
                            onTap: () => setState(() => _selectedPlan = index),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            _showTermsDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF2B31A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue',
                                style: GoogleFonts.outfit(color: const Color(0xFFFFFFFF), fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 16, color: Color(0xFFFFFFFF)),
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
        ),
      ),
    );
  }
}

class _TrainingPlanCard extends StatelessWidget {
  const _TrainingPlanCard({required this.plan, required this.selected, required this.onTap});

  final _TrainingPlanModel plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: plan.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? plan.borderColor : plan.borderColor.withValues(alpha: 0.75), width: selected ? 2.1 : 1.1),
            boxShadow: selected ? [BoxShadow(color: plan.borderColor.withValues(alpha: 0.22), blurRadius: 12, spreadRadius: 0.6)] : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: plan.markerColor, width: 2),
                    ),
                    child: selected
                        ? Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: plan.markerColor),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      plan.title,
                      style: GoogleFonts.outfit(color: const Color(0xFFFFFFFF), fontSize: 24, fontWeight: FontWeight.w600, height: 1.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...plan.bullets.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: _LineText(leading: '•', text: item),
                ),
              ),
              ...List.generate(plan.numberedItems.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: _LineText(leading: '${index + 1}.', text: plan.numberedItems[index]),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineText extends StatelessWidget {
  const _LineText({required this.leading, required this.text});

  final String leading;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 16,
          child: Text(
            leading,
            style: GoogleFonts.outfit(color: const Color(0xFFFFFFFF), fontSize: 14, fontWeight: FontWeight.w500, height: 1.5),
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.outfit(color: const Color(0xFFFFFFFF), fontSize: 14, fontWeight: FontWeight.w500, height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _TrainingPlanModel {
  const _TrainingPlanModel({
    required this.title,
    required this.markerColor,
    required this.borderColor,
    required this.backgroundColor,
    required this.bullets,
    required this.numberedItems,
  });

  final String title;
  final Color markerColor;
  final Color borderColor;
  final Color backgroundColor;
  final List<String> bullets;
  final List<String> numberedItems;
}
