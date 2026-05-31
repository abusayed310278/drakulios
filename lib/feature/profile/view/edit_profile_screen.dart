import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/language/translated_text.dart';
import '../controller/edit_profile_controller.dart';
import '../model/edit_profile_form_data.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, this.initialProfile});

  final Map<String, dynamic>? initialProfile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final EditProfileController _controller = EditProfileController();
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _memberIdController = TextEditingController();

  final TextEditingController _currentWeightController =
      TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();
  final TextEditingController _recentWeightChangesController =
      TextEditingController();
  final TextEditingController _bodyTypeController = TextEditingController();
  final TextEditingController _currentHeightController =
      TextEditingController();
  final TextEditingController _sleepPatternsController =
      TextEditingController();
  final TextEditingController _appetiteHungerController =
      TextEditingController();
  final TextEditingController _typicalMealsController = TextEditingController();
  final TextEditingController _waterIntakeController = TextEditingController();
  final TextEditingController _surgicalHistoryController =
      TextEditingController();
  final TextEditingController _physicalPainsController =
      TextEditingController();
  final TextEditingController _digestionGutController = TextEditingController();
  final TextEditingController _supplementsController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  XFile? _selectedAvatar;
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _prefillProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _memberIdController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    _recentWeightChangesController.dispose();
    _bodyTypeController.dispose();
    _currentHeightController.dispose();
    _sleepPatternsController.dispose();
    _appetiteHungerController.dispose();
    _typicalMealsController.dispose();
    _waterIntakeController.dispose();
    _surgicalHistoryController.dispose();
    _physicalPainsController.dispose();
    _digestionGutController.dispose();
    _supplementsController.dispose();
    super.dispose();
  }

  void _applyFormData(EditProfileFormData form) {
    _avatarUrl = form.avatarUrl;
    _nameController.text = form.name;
    _phoneController.text = form.phone;
    _emailController.text = form.email;
    _addressController.text = form.address;
    _memberIdController.text = form.memberId;
    _currentWeightController.text = form.currentWeight;
    _targetWeightController.text = form.targetWeight;
    _recentWeightChangesController.text = form.recentWeightChanges;
    _bodyTypeController.text = form.bodyType;
    _currentHeightController.text = form.currentHeight;
    _sleepPatternsController.text = form.sleepPatterns;
    _appetiteHungerController.text = form.appetiteHunger;
    _typicalMealsController.text = form.typicalDailyMeals;
    _waterIntakeController.text = form.waterFluidIntake;
    _surgicalHistoryController.text = form.surgicalHistory;
    _physicalPainsController.text = form.currentPhysicalPains;
    _digestionGutController.text = form.digestionGutHealth;
    _supplementsController.text = form.supplementsCurrentlyUsed;
  }

  EditProfileFormData _collectFormData() {
    return EditProfileFormData(
      rawProfile: <String, dynamic>{'avatar': <String, dynamic>{'url': _avatarUrl}},
      name: _nameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      address: _addressController.text,
      memberId: _memberIdController.text,
      currentWeight: _currentWeightController.text,
      targetWeight: _targetWeightController.text,
      recentWeightChanges: _recentWeightChangesController.text,
      bodyType: _bodyTypeController.text,
      currentHeight: _currentHeightController.text,
      sleepPatterns: _sleepPatternsController.text,
      appetiteHunger: _appetiteHungerController.text,
      typicalDailyMeals: _typicalMealsController.text,
      waterFluidIntake: _waterIntakeController.text,
      surgicalHistory: _surgicalHistoryController.text,
      currentPhysicalPains: _physicalPainsController.text,
      digestionGutHealth: _digestionGutController.text,
      supplementsCurrentlyUsed: _supplementsController.text,
    );
  }

  Future<void> _prefillProfile() async {
    try {
      final form = await _controller.loadFormData(initial: widget.initialProfile);
      if (!mounted) return;
      _applyFormData(form);
      setState(() => _isLoading = false);
    } catch (error) {
      CustomSnackbar.show(
        _controller.parseLoadError(error, fallback: 'Failed to load profile'),
      );
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final result = await _controller.saveProfile(
        form: _collectFormData(),
        avatarPath: _selectedAvatar?.path,
      );
      CustomSnackbar.show(result.message);
      if (!result.success) return;
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      setState(() => _selectedAvatar = picked);
    } catch (e) {
      final msg = e.toString();
      if (msg.isEmpty) {
        CustomSnackbar.show('Unable to select photo');
      } else {
        CustomSnackbar.show(msg);
      }
    }
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 50, 18, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_isLoading)
                        const LinearProgressIndicator(
                          minHeight: 1.5,
                          color: Color(0xFFF3B41A),
                          backgroundColor: Colors.transparent,
                        ),
                      Row(
                        children: [
                          Transform.translate(
                            offset: const Offset(-12, 0),
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
                          TranslatedText(
                            'Edit Profile',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFB1B1B1),
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                            autoSize: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      18,
                      0,
                      18,
                      24 + MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: _FormContent(
                      avatarUrl: _avatarUrl,
                      selectedAvatarPath: _selectedAvatar?.path,
                      onPickAvatar: _pickAvatar,
                      nameController: _nameController,
                      phoneController: _phoneController,
                      emailController: _emailController,
                      addressController: _addressController,
                      memberIdController: _memberIdController,
                      currentWeightController: _currentWeightController,
                      targetWeightController: _targetWeightController,
                      recentWeightChangesController:
                          _recentWeightChangesController,
                      bodyTypeController: _bodyTypeController,
                      currentHeightController: _currentHeightController,
                      sleepPatternsController: _sleepPatternsController,
                      appetiteHungerController: _appetiteHungerController,
                      typicalMealsController: _typicalMealsController,
                      waterIntakeController: _waterIntakeController,
                      surgicalHistoryController: _surgicalHistoryController,
                      physicalPainsController: _physicalPainsController,
                      digestionGutController: _digestionGutController,
                      supplementsController: _supplementsController,
                      isSaving: _isSaving,
                      onSave: _saveProfile,
                    ),
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

class _FormContent extends StatelessWidget {
  const _FormContent({
    required this.avatarUrl,
    required this.selectedAvatarPath,
    required this.onPickAvatar,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.addressController,
    required this.memberIdController,
    required this.currentWeightController,
    required this.targetWeightController,
    required this.recentWeightChangesController,
    required this.bodyTypeController,
    required this.currentHeightController,
    required this.sleepPatternsController,
    required this.appetiteHungerController,
    required this.typicalMealsController,
    required this.waterIntakeController,
    required this.surgicalHistoryController,
    required this.physicalPainsController,
    required this.digestionGutController,
    required this.supplementsController,
    required this.isSaving,
    required this.onSave,
  });

  final String avatarUrl;
  final String? selectedAvatarPath;
  final VoidCallback onPickAvatar;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController memberIdController;
  final TextEditingController currentWeightController;
  final TextEditingController targetWeightController;
  final TextEditingController recentWeightChangesController;
  final TextEditingController bodyTypeController;
  final TextEditingController currentHeightController;
  final TextEditingController sleepPatternsController;
  final TextEditingController appetiteHungerController;
  final TextEditingController typicalMealsController;
  final TextEditingController waterIntakeController;
  final TextEditingController surgicalHistoryController;
  final TextEditingController physicalPainsController;
  final TextEditingController digestionGutController;
  final TextEditingController supplementsController;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        Center(
          child: _Avatar(
            imageUrl: avatarUrl,
            localImagePath: selectedAvatarPath,
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: InkWell(
            onTap: onPickAvatar,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.edit, size: 12, color: Color(0xFFB1B1B1)),
                const SizedBox(width: 4),
                TranslatedText(
                  'Change Photo',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFB1B1B1),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _FieldLabel(text: 'Username'),
        _InputField(controller: nameController),
        const SizedBox(height: 10),
        _FieldLabel(text: 'Contact Number'),
        _InputField(controller: phoneController),
        const SizedBox(height: 10),
        _FieldLabel(text: 'Email'),
        _InputField(controller: emailController),
        const SizedBox(height: 10),
        _FieldLabel(text: 'Address'),
        _InputField(controller: addressController, minLines: 2),
        const SizedBox(height: 10),
        _FieldLabel(text: 'Member ID'),
        _InputField(controller: memberIdController),
        const SizedBox(height: 18),
        _SectionHeading(
          text: 'Personal Body Details :',
          color: const Color(0xFFF3B41A),
        ),
        const SizedBox(height: 8),
        _SectionHeading(text: 'Weight :'),
        _FieldLabel(text: 'Current Weight'),
        _InputField(controller: currentWeightController),
        const SizedBox(height: 10),
        _FieldLabel(text: 'Target Weight'),
        _InputField(controller: targetWeightController),
        const SizedBox(height: 10),
        _FieldLabel(text: 'Recent Weight Changes (if any)'),
        _InputField(controller: recentWeightChangesController, minLines: 3),
        const SizedBox(height: 14),
        _SectionHeading(text: 'Body :'),
        _FieldLabel(text: 'Body Type'),
        _InputField(controller: bodyTypeController, minLines: 3),
        const SizedBox(height: 10),
        _FieldLabel(text: 'Current Height'),
        _InputField(controller: currentHeightController),
        const SizedBox(height: 14),
        _SectionHeading(text: 'Sleep :'),
        _FieldLabel(text: 'Sleep Patterns'),
        _InputField(controller: sleepPatternsController),
        const SizedBox(height: 14),
        _SectionHeading(text: 'Nutrition Assessment :'),
        _FieldLabel(text: 'Appetite & Hunger'),
        _InputField(controller: appetiteHungerController, minLines: 3),
        const SizedBox(height: 10),
        _FieldLabel(text: 'Typical Daily Meals'),
        _InputField(controller: typicalMealsController),
        const SizedBox(height: 10),
        _FieldLabel(text: 'Water & Fluid Intake'),
        _InputField(controller: waterIntakeController, minLines: 2),
        const SizedBox(height: 14),
        _SectionHeading(text: 'Other Information:'),
        _FieldLabel(text: 'Surgical History (if any)'),
        _InputField(controller: surgicalHistoryController, minLines: 3),
        const SizedBox(height: 10),
        _FieldLabel(text: 'Current Physical Pains (if any)'),
        _InputField(controller: physicalPainsController, minLines: 2),
        const SizedBox(height: 10),
        _FieldLabel(text: 'Digestion & Gut Health'),
        _InputField(controller: digestionGutController, minLines: 2),
        const SizedBox(height: 10),
        _FieldLabel(text: 'Supplements Currently Used'),
        _InputField(controller: supplementsController, minLines: 2),
        const SizedBox(height: 18),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: isSaving ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3B41A),
              disabledBackgroundColor: const Color(0xFF8A6A1A),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : TranslatedText(
                    'Update',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    autoSize: true,
                  ),
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl, this.localImagePath});

  final String imageUrl;
  final String? localImagePath;

  @override
  Widget build(BuildContext context) {
    final hasUrl = imageUrl.trim().isNotEmpty;
    return CircleAvatar(
      radius: 42,
      backgroundColor: const Color(0xFF2A2F39),
      child: ClipOval(
        child: localImagePath != null && localImagePath!.isNotEmpty
            ? Image.file(
                File(localImagePath!),
                width: 84,
                height: 84,
                fit: BoxFit.cover,
              )
            : hasUrl
            ? Image.network(
                imageUrl,
                width: 84,
                height: 84,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      width: 84,
      height: 84,
      color: const Color(0xFF2A2F39),
      alignment: Alignment.center,
      child: const Icon(Icons.person, size: 34, color: Color(0xFF9AA3B2)),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.text, this.color = Colors.white});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TranslatedText(
      text,
      style: GoogleFonts.outfit(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
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
      padding: const EdgeInsets.only(bottom: 6),
      child: TranslatedText(
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
  const _InputField({this.controller, this.minLines = 1});

  final TextEditingController? controller;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines == 1 ? 1 : minLines,
      style: GoogleFonts.outfit(
        color: const Color(0xFF4B4B4B),
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.2,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFE9E9EC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE9E9EC), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFF3B41A), width: 1.2),
        ),
      ),
    );
  }
}
