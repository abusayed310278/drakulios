import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

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
              padding: const EdgeInsets.fromLTRB(18, 50, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Transform.translate(
                        offset: const Offset(-12, 0),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFFC9CDD3)),
                          splashRadius: 18,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        ),
                      ),
                      Text(
                        'Personal Body Details :',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFE5E7EB),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const _SectionTitle(text: 'Weight :'),
                  const _FieldLabel(text: 'Current Weight'),
                  const _InputField(initialValue: '56 kg'),
                  const SizedBox(height: 8),
                  const _FieldLabel(text: 'Target Weight'),
                  const _InputField(initialValue: '65 kg'),
                  const SizedBox(height: 8),
                  const _FieldLabel(text: 'Recent Weight Changes (if any)'),
                  const _InputField(
                    initialValue: "I've gained 10 kg in the last 6 months due to a desk job",
                    minLines: 3,
                  ),
                  const SizedBox(height: 10),
                  const _SectionTitle(text: 'Body :'),
                  const _FieldLabel(text: 'Body Type'),
                  const _InputField(
                    initialValue: 'I have a heavy frame but carry most of my fat around the midsection',
                    minLines: 3,
                  ),
                  const SizedBox(height: 8),
                  const _FieldLabel(text: 'Current Height'),
                  const _InputField(initialValue: '5 ft'),
                  const SizedBox(height: 10),
                  const _SectionTitle(text: 'Sleep :'),
                  const _FieldLabel(text: 'Sleep Patterns'),
                  const _InputField(initialValue: '6-7 hours/day'),
                  const SizedBox(height: 10),
                  const _SectionTitle(text: 'Nutrition Assessment :'),
                  const _FieldLabel(text: 'Appetite & Hunger'),
                  const _InputField(
                    initialValue: "I'm never hungry in the morning, but I get intense sugar cravings at night.",
                    minLines: 3,
                  ),
                  const SizedBox(height: 8),
                  const _FieldLabel(text: 'Typical Daily Meals'),
                  const _InputField(initialValue: '3 meals per day'),
                  const SizedBox(height: 8),
                  const _FieldLabel(text: 'Water & Fluid Intake'),
                  const _InputField(initialValue: 'I drink 1.5L of water and 4 cups of black coffee daily'),
                  const SizedBox(height: 10),
                  const _SectionTitle(text: 'Other Information:'),
                  const _FieldLabel(text: 'Surgical History (if any)'),
                  const _InputField(initialValue: 'Appendectomy 3 years ago; hernia repair in 2021'),
                  const SizedBox(height: 8),
                  const _FieldLabel(text: 'Current Physical Pains (if any)'),
                  const _InputField(initialValue: 'Sharp pain in the right shoulder when doing overhead presses'),
                  const SizedBox(height: 8),
                  const _FieldLabel(text: 'Digestion & Gut Health'),
                  const _InputField(initialValue: 'Frequent bloating after eating dairy or heavy carbs'),
                  const SizedBox(height: 8),
                  const _FieldLabel(text: 'Supplements Currently Used'),
                  const _InputField(initialValue: 'I use Whey protein and Creatine from the gym shop'),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFF3B41A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, color: Colors.white, size: 15),
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
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.2,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({required this.initialValue, this.minLines = 1});

  final String initialValue;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      minLines: minLines,
      maxLines: minLines,
      style: GoogleFonts.outfit(
        color: const Color(0xFF3A3A3A),
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.2,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFEDEDED),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Color(0xFFF3B41A), width: 1),
        ),
      ),
    );
  }
}
