import 'package:flutter/material.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import 'training_nutrition_screen.dart';

class HealthProfileScreen extends StatelessWidget {
  const HealthProfileScreen({super.key});

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
                        'Personal Body Details',
                        style: TextStyle(color: Color(0xFFE6E7EA), fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const _SectionTitle(text: 'Weight :'),
                  const _FieldLabel(text: 'Current Weight'),
                  const SizedBox(height: 6),
                  const _InputField(hintText: '56 kg'),
                  const SizedBox(height: 10),
                  const _FieldLabel(text: 'Target Weight'),
                  const SizedBox(height: 6),
                  const _InputField(hintText: '65 kg'),
                  const SizedBox(height: 10),
                  const _FieldLabel(text: 'Recent Weight Changes (if any)'),
                  const SizedBox(height: 6),
                  const _InputField(hintText: 'I’ve gained 10kg in the last 6 months due to a desk job', maxLines: 3),
                  const SizedBox(height: 14),
                  const _SectionTitle(text: 'Body :'),
                  const _FieldLabel(text: 'Body Type'),
                  const SizedBox(height: 6),
                  const _InputField(hintText: 'I have a heavy frame but carry most of my fat around the midsection', maxLines: 3),
                  const SizedBox(height: 10),
                  const _FieldLabel(text: 'Current Height'),
                  const SizedBox(height: 6),
                  const _InputField(hintText: '5 ft'),
                  const SizedBox(height: 14),
                  const _SectionTitle(text: 'Sleep :'),
                  const _FieldLabel(text: 'Sleep Patterns'),
                  const SizedBox(height: 6),
                  const _InputField(hintText: '6-7 hours/day'),
                  const SizedBox(height: 14),
                  const _SectionTitle(text: 'Nutrition Assessment :'),
                  const _FieldLabel(text: 'Appetite & Hunger'),
                  const SizedBox(height: 6),
                  const _InputField(hintText: 'I’m never hungry in the morning, but I get intense sugar cravings at night', maxLines: 3),
                  const SizedBox(height: 10),
                  const _FieldLabel(text: 'Typical Daily Meals'),
                  const SizedBox(height: 6),
                  const _InputField(hintText: '3 meals per day'),
                  const SizedBox(height: 10),
                  const _FieldLabel(text: 'Water & Fluid Intake'),
                  const SizedBox(height: 6),
                  const _InputField(hintText: 'I drink 1.5L of water and 4 cups of black coffee daily', maxLines: 2),
                  const SizedBox(height: 14),
                  const _SectionTitle(text: 'Other Information'),
                  const _FieldLabel(text: 'Surgical History (if any)'),
                  const SizedBox(height: 6),
                  const _InputField(hintText: 'Appendectomy 3 years ago; hernia repair in 2021', maxLines: 2),
                  const SizedBox(height: 10),
                  const _FieldLabel(text: 'Current Physical Pains (if any)'),
                  const SizedBox(height: 6),
                  const _InputField(hintText: 'Sharp pain in the right shoulder when doing overhead press', maxLines: 2),
                  const SizedBox(height: 10),
                  const _FieldLabel(text: 'Digestion & Gut Health'),
                  const SizedBox(height: 6),
                  const _InputField(hintText: 'Frequent bloating after eating dairy or heavy carbs', maxLines: 2),
                  const SizedBox(height: 10),
                  const _FieldLabel(text: 'Supplements Currently Used'),
                  const SizedBox(height: 6),
                  const _InputField(hintText: 'I use whey protein and creatine from the gym shop', maxLines: 2),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        CustomSnackbar.show('Personal Body Details created successfully');
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TrainingNutritionScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2B31A),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Continue',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.2, color: Color(0xFFFFFFFF)),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18, color: Colors.white),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(color: Color.fromARGB(255, 230, 233, 243), fontSize: 12, fontWeight: FontWeight.w600),
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
      style: const TextStyle(color: Color.fromARGB(255, 219, 229, 241), fontSize: 11, fontWeight: FontWeight.w500),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({required this.hintText, this.maxLines = 1});

  final String hintText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: maxLines,
      style: const TextStyle(color: Color(0xFF1B1B1B), fontSize: 12),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color.fromARGB(255, 20, 22, 25), fontSize: 11),
        filled: true,
        fillColor: const Color.fromARGB(255, 185, 192, 210), //
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2A2F39), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3A4860), width: 1.2),
        ),
      ),
    );
  }
}
