import 'package:flutter/material.dart';

import '../../../core/constants/assets.dart';
import 'health_profile_screen.dart';

class ChooseTrainingPlanScreen extends StatefulWidget {
  const ChooseTrainingPlanScreen({super.key});

  @override
  State<ChooseTrainingPlanScreen> createState() =>
      _ChooseTrainingPlanScreenState();
}

class _ChooseTrainingPlanScreenState extends State<ChooseTrainingPlanScreen> {
  int? _selectedIndex;

  Future<void> _showBodyGoalsDialog() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.all(2),
                      child: Icon(
                        Icons.close,
                        size: 22,
                        color: Color(0xFF83868E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'To help us build the best possible\nplan for you, please tell us a little bit\nabout your body and goals',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Color(0xFF1E2024),
                  fontSize: 27 / 2,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HealthProfileScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2B31A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 21 / 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Spacer(),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
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
              const Text(
                'By accepting this you agree with our',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1E2024),
                  fontSize: 24 / 2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Terms And Conditions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF2B31A),
                  fontSize: 24 / 2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFF2B31A),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Deny',
                          style: TextStyle(
                            color: Color(0xFFF2B31A),
                            fontSize: 21 / 2,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showBodyGoalsDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2B31A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(
                            fontSize: 21 / 2,
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
    final plans = <_PlanOption>[
      const _PlanOption(
        title: 'Online Coaching',
        borderColor: Color(0xFFF2B31A),
        backgroundColor: Color(0xFF25173B),
        iconColor: Color(0xFFA957FF),
        bullets: [
          'Monthly payment.',
          'This plan includes planning of a training plan personalized to their objectives, a personalized nutrition plan, weekly online reviews with their coach.',
          'When choosing this plan the user will access the objective questionnaire and from there to the payment gateway.',
          'After a period of 24/48 they will be able to see in their profile the following:',
          '1. Daily personalized training plan.',
          '2. Complete nutrition plan.',
          '3. Weekly online reviews to be agreed in calendar.',
        ],
      ),
      const _PlanOption(
        title: 'Training Plan',
        borderColor: Color(0xFF2FA8FF),
        backgroundColor: Color(0xFF102C42),
        iconColor: Color(0xFF2FA8FF),
        bullets: [
          'One-time payment product.',
          'This plan includes planning of a training plan personalized to their objectives elaborated for a determined time.',
          'When choosing this product the user will access the objectives questionnaire and from there to the payment gateway.',
          'After a period of 24/48 they will be able to see in their profile the following:',
          '1. Daily personalized training plan.',
        ],
      ),
      const _PlanOption(
        title: 'Personal Training',
        borderColor: Color(0xFFF2B31A),
        backgroundColor: Color(0xFF3B2B08),
        iconColor: Color(0xFFF2B31A),
        bullets: [
          'One-time payment product.',
          'This plan includes: 1 to 1 personal training sessions with a personal trainer.',
          'When choosing this product the user will access the objectives questionnaire and from there must choose one of the following packages:',
          '1. 4 training sessions.',
          '2. 8 training sessions.',
          '3. 12 training sessions.',
          'After acquiring one of the mentioned packages the user will be able to see a calendar where they will have to choose the days they want to carry out the personal training, and a counter of how many sessions they have left as credit.',
        ],
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
              padding: const EdgeInsets.fromLTRB(18, 40, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  const SizedBox(height: 2),
                  Center(
                    child: Image.asset(
                      Images.gymImage,
                      width: 38,
                      height: 38,
                      color: const Color(0xFFF2B31A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Choose Your Training Plan',
                      style: TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 28 / 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(plans.length, (index) {
                    final plan = plans[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == plans.length - 1 ? 0 : 10,
                      ),
                      child: _PlanCard(
                        title: plan.title,
                        borderColor: plan.borderColor,
                        backgroundColor: plan.backgroundColor,
                        iconColor: plan.iconColor,
                        bullets: plan.bullets,
                        selected: _selectedIndex == index,
                        onTap: () => setState(() => _selectedIndex = index),
                      ),
                    );
                  }),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _selectedIndex == null
                          ? null
                          : _showTermsDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2B31A),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFB1B1B1),
                        disabledForegroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
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
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.borderColor,
    required this.backgroundColor,
    required this.iconColor,
    required this.bullets,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final Color borderColor;
  final Color backgroundColor;
  final Color iconColor;
  final List<String> bullets;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: selected ? 2 : 1.2),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: borderColor.withValues(alpha: 0.32),
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
                  Icon(Icons.circle, size: 9, color: iconColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30 / 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ...bullets.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '•  $line',
                    style: const TextStyle(
                      color: Color(0xFFF1F1F1),
                      fontSize: 22 / 2,
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanOption {
  const _PlanOption({
    required this.title,
    required this.borderColor,
    required this.backgroundColor,
    required this.iconColor,
    required this.bullets,
  });

  final String title;
  final Color borderColor;
  final Color backgroundColor;
  final Color iconColor;
  final List<String> bullets;
}
