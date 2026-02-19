import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import 'training_nutrition_screen.dart';

class HealthProfileScreen extends StatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  State<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  final TrainingShopApiService _api = TrainingShopApiService();

  final TextEditingController _currentWeight = TextEditingController();
  final TextEditingController _targetWeight = TextEditingController();
  final TextEditingController _recentWeightChanges = TextEditingController();
  final TextEditingController _bodyType = TextEditingController();
  final TextEditingController _currentHeight = TextEditingController();
  final TextEditingController _sleepPatterns = TextEditingController();
  final TextEditingController _appetiteHunger = TextEditingController();
  final TextEditingController _typicalDailyMeals = TextEditingController();
  final TextEditingController _waterFluidIntake = TextEditingController();
  final TextEditingController _surgicalHistory = TextEditingController();
  final TextEditingController _currentPhysicalPains = TextEditingController();
  final TextEditingController _digestionGutHealth = TextEditingController();
  final TextEditingController _supplementsCurrentlyUsed = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentWeight.dispose();
    _targetWeight.dispose();
    _recentWeightChanges.dispose();
    _bodyType.dispose();
    _currentHeight.dispose();
    _sleepPatterns.dispose();
    _appetiteHunger.dispose();
    _typicalDailyMeals.dispose();
    _waterFluidIntake.dispose();
    _surgicalHistory.dispose();
    _currentPhysicalPains.dispose();
    _digestionGutHealth.dispose();
    _supplementsCurrentlyUsed.dispose();
    super.dispose();
  }

  Future<void> _submitTrainingDetails() async {
    setState(() => _isSubmitting = true);
    try {
      final payload = {
        'currentWeight': _currentWeight.text.trim(),
        'targetWeight': _targetWeight.text.trim(),
        'recentWeightChanges': _recentWeightChanges.text.trim(),
        'bodyType': _bodyType.text.trim(),
        'currentHeight': _currentHeight.text.trim(),
        'sleepPatterns': _sleepPatterns.text.trim(),
        'appetiteHunger': _appetiteHunger.text.trim(),
        'typicalDailyMeals': _typicalDailyMeals.text.trim(),
        'waterFluidIntake': _waterFluidIntake.text.trim(),
        'surgicalHistory': _surgicalHistory.text.trim(),
        'currentPhysicalPains': _currentPhysicalPains.text.trim(),
        'digestionGutHealth': _digestionGutHealth.text.trim(),
        'supplementsCurrentlyUsed': _supplementsCurrentlyUsed.text.trim(),
      };

      final res = await _api.createTraining(payload);
      final message = (res['message'] ?? 'Personal Body Details created successfully').toString();
      CustomSnackbar.show(message);

      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TrainingNutritionScreen()));
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map && data['message'] != null ? data['message'].toString() : 'Failed to save training details';
      CustomSnackbar.show(msg);
    } catch (_) {
      CustomSnackbar.show('Failed to save training details');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

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
                  _InputField(controller: _currentWeight),
                  const SizedBox(height: 10),
                  const _FieldLabel(text: 'Target Weight'),
                  const SizedBox(height: 6),
                  _InputField(controller: _targetWeight),
                  const SizedBox(height: 10),
                  const _FieldLabel(text: 'Recent Weight Changes (if any)'),
                  const SizedBox(height: 6),
                  _InputField(controller: _recentWeightChanges, maxLines: 3),
                  const SizedBox(height: 14),
                  const _SectionTitle(text: 'Body :'),
                  const _FieldLabel(text: 'Body Type'),
                  const SizedBox(height: 6),
                  _InputField(controller: _bodyType, maxLines: 3),
                  const SizedBox(height: 10),
                  const _FieldLabel(text: 'Current Height'),
                  const SizedBox(height: 6),
                  _InputField(controller: _currentHeight),
                  const SizedBox(height: 14),
                  const _SectionTitle(text: 'Sleep :'),
                  const _FieldLabel(text: 'Sleep Patterns'),
                  const SizedBox(height: 6),
                  _InputField(controller: _sleepPatterns),
                  const SizedBox(height: 14),
                  const _SectionTitle(text: 'Nutrition Assessment :'),
                  const _FieldLabel(text: 'Appetite & Hunger'),
                  const SizedBox(height: 6),
                  _InputField(controller: _appetiteHunger, maxLines: 3),
                  const SizedBox(height: 10),
                  const _FieldLabel(text: 'Typical Daily Meals'),
                  const SizedBox(height: 6),
                  _InputField(controller: _typicalDailyMeals),
                  const SizedBox(height: 10),
                  const _FieldLabel(text: 'Water & Fluid Intake'),
                  const SizedBox(height: 6),
                  _InputField(controller: _waterFluidIntake, maxLines: 2),
                  const SizedBox(height: 14),
                  const _SectionTitle(text: 'Other Information'),
                  const _FieldLabel(text: 'Surgical History (if any)'),
                  const SizedBox(height: 6),
                  _InputField(controller: _surgicalHistory, maxLines: 2),
                  const SizedBox(height: 10),
                  const _FieldLabel(text: 'Current Physical Pains (if any)'),
                  const SizedBox(height: 6),
                  _InputField(controller: _currentPhysicalPains, maxLines: 2),
                  const SizedBox(height: 10),
                  const _FieldLabel(text: 'Digestion & Gut Health'),
                  const SizedBox(height: 6),
                  _InputField(controller: _digestionGutHealth, maxLines: 2),
                  const SizedBox(height: 10),
                  const _FieldLabel(text: 'Supplements Currently Used'),
                  const SizedBox(height: 6),
                  _InputField(controller: _supplementsCurrentlyUsed, maxLines: 2),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitTrainingDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2B31A),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Row(
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
  const _InputField({required this.controller, this.maxLines = 1});

  final TextEditingController controller;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Color(0xFF1B1B1B), fontSize: 12),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 185, 192, 210),
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
