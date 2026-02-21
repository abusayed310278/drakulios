import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/network/api_service/token_meneger.dart';
import '../../../core/network/api_service/user_api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, this.initialProfile});

  final Map<String, dynamic>? initialProfile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserApiService _userApi = UserApiService();
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
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
  Map<String, dynamic> _profile = const {};

  @override
  void initState() {
    super.initState();
    final initial = widget.initialProfile;
    if (initial != null && initial.isNotEmpty) {
      _applyProfileData(initial);
      _isLoading = false;
    }
    _prefillProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
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

  String _pickString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  void _applyProfileData(Map<String, dynamic> data) {
    final bodyDetails = data['personalBodyDetails'] is Map
        ? Map<String, dynamic>.from(data['personalBodyDetails'] as Map)
        : data['bodyDetails'] is Map
        ? Map<String, dynamic>.from(data['bodyDetails'] as Map)
        : data['healthProfile'] is Map
        ? Map<String, dynamic>.from(data['healthProfile'] as Map)
        : <String, dynamic>{};

    _profile = data;
    _nameController.text = _pickString(data, ['name']);
    _phoneController.text = _pickString(data, ['phone', 'contact']);
    _emailController.text = _pickString(data, ['email']);
    _memberIdController.text = _pickString(data, ['_id', 'id', 'memberId']);

    _currentWeightController.text = _pickString(bodyDetails, ['currentWeight']);
    _targetWeightController.text = _pickString(bodyDetails, ['targetWeight']);
    _recentWeightChangesController.text = _pickString(bodyDetails, [
      'recentWeightChanges',
    ]);
    _bodyTypeController.text = _pickString(bodyDetails, ['bodyType']);
    _currentHeightController.text = _pickString(bodyDetails, [
      'currentHeight',
      'height',
    ]);
    _sleepPatternsController.text = _pickString(bodyDetails, [
      'sleepPatterns',
      'sleep',
    ]);
    _appetiteHungerController.text = _pickString(bodyDetails, [
      'appetiteHunger',
    ]);
    _typicalMealsController.text = _pickString(bodyDetails, [
      'typicalDailyMeals',
      'typicalMeals',
    ]);
    _waterIntakeController.text = _pickString(bodyDetails, [
      'waterFluidIntake',
      'waterIntake',
    ]);
    _surgicalHistoryController.text = _pickString(bodyDetails, [
      'surgicalHistory',
    ]);
    _physicalPainsController.text = _pickString(bodyDetails, [
      'currentPhysicalPains',
      'physicalPains',
    ]);
    _digestionGutController.text = _pickString(bodyDetails, [
      'digestionGutHealth',
      'digestionGut',
    ]);
    _supplementsController.text = _pickString(bodyDetails, [
      'supplementsCurrentlyUsed',
      'supplements',
    ]);
  }

  Future<void> _prefillProfile() async {
    try {
      final res = await _userApi.getProfile();
      final data = Map<String, dynamic>.from((res['data'] ?? {}) as Map);

      if (!mounted) return;
      _applyProfileData(data);

      setState(() => _isLoading = false);
    } on DioException catch (e) {
      final payload = e.response?.data;
      final msg = payload is Map && payload['message'] != null
          ? payload['message'].toString()
          : 'Failed to load profile';
      CustomSnackbar.show(msg);
      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      CustomSnackbar.show('Failed to load profile');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      CustomSnackbar.show('Username is required');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final res = await _userApi.updateProfile(
        name: name,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        avatarPath: _selectedAvatar?.path,
        personalBodyDetails: {
          'currentWeight': _currentWeightController.text.trim(),
          'targetWeight': _targetWeightController.text.trim(),
          'recentWeightChanges': _recentWeightChangesController.text.trim(),
          'bodyType': _bodyTypeController.text.trim(),
          'currentHeight': _currentHeightController.text.trim(),
          'sleepPatterns': _sleepPatternsController.text.trim(),
          'appetiteHunger': _appetiteHungerController.text.trim(),
          'typicalDailyMeals': _typicalMealsController.text.trim(),
          'waterFluidIntake': _waterIntakeController.text.trim(),
          'surgicalHistory': _surgicalHistoryController.text.trim(),
          'currentPhysicalPains': _physicalPainsController.text.trim(),
          'digestionGutHealth': _digestionGutController.text.trim(),
          'supplementsCurrentlyUsed': _supplementsController.text.trim(),
        },
      );

      await TokenManager.saveUserName(name);
      if (_emailController.text.trim().isNotEmpty) {
        await TokenManager.saveEmail(_emailController.text.trim());
      }

      final message = (res['message'] ?? 'Profile updated successfully')
          .toString();
      CustomSnackbar.show(message);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on DioException catch (e) {
      final payload = e.response?.data;
      final msg = payload is Map && payload['message'] != null
          ? payload['message'].toString()
          : 'Profile update failed';
      CustomSnackbar.show(msg);
    } catch (_) {
      CustomSnackbar.show('Profile update failed');
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
    final avatarUrl = (_profile['avatar']?['url'] ?? '').toString();

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
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFB1B1B1),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: _Avatar(
                      imageUrl: avatarUrl,
                      localImagePath: _selectedAvatar?.path,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: InkWell(
                      onTap: _pickAvatar,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.edit,
                            size: 12,
                            color: Color(0xFFB1B1B1),
                          ),
                          const SizedBox(width: 4),
                          Text(
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
                  _InputField(controller: _nameController),
                  const SizedBox(height: 10),
                  _FieldLabel(text: 'Contact Number'),
                  _InputField(controller: _phoneController),
                  const SizedBox(height: 10),
                  _FieldLabel(text: 'Email'),
                  _InputField(controller: _emailController),
                  const SizedBox(height: 10),
                  _FieldLabel(text: 'Member ID'),
                  _InputField(controller: _memberIdController),
                  const SizedBox(height: 18),
                  _SectionHeading(
                    text: 'Personal Body Details :',
                    color: const Color(0xFFF3B41A),
                  ),
                  const SizedBox(height: 8),

                  _SectionHeading(text: 'Weight :'),
                  _FieldLabel(text: 'Current Weight'),
                  _InputField(controller: _currentWeightController),
                  const SizedBox(height: 10),
                  _FieldLabel(text: 'Target Weight'),
                  _InputField(controller: _targetWeightController),
                  const SizedBox(height: 10),
                  _FieldLabel(text: 'Recent Weight Changes (if any)'),
                  _InputField(
                    controller: _recentWeightChangesController,
                    minLines: 3,
                  ),
                  const SizedBox(height: 14),

                  _SectionHeading(text: 'Body :'),
                  _FieldLabel(text: 'Body Type'),
                  _InputField(controller: _bodyTypeController, minLines: 3),
                  const SizedBox(height: 10),
                  _FieldLabel(text: 'Current Height'),
                  _InputField(controller: _currentHeightController),
                  const SizedBox(height: 14),

                  _SectionHeading(text: 'Sleep :'),
                  _FieldLabel(text: 'Sleep Patterns'),
                  _InputField(controller: _sleepPatternsController),
                  const SizedBox(height: 14),

                  _SectionHeading(text: 'Nutrition Assessment :'),
                  _FieldLabel(text: 'Appetite & Hunger'),
                  _InputField(
                    controller: _appetiteHungerController,
                    minLines: 3,
                  ),
                  const SizedBox(height: 10),
                  _FieldLabel(text: 'Typical Daily Meals'),
                  _InputField(controller: _typicalMealsController),
                  const SizedBox(height: 10),
                  _FieldLabel(text: 'Water & Fluid Intake'),
                  _InputField(controller: _waterIntakeController, minLines: 2),
                  const SizedBox(height: 14),

                  _SectionHeading(text: 'Other Information:'),
                  _FieldLabel(text: 'Surgical History (if any)'),
                  _InputField(
                    controller: _surgicalHistoryController,
                    minLines: 3,
                  ),
                  const SizedBox(height: 10),
                  _FieldLabel(text: 'Current Physical Pains (if any)'),
                  _InputField(
                    controller: _physicalPainsController,
                    minLines: 2,
                  ),
                  const SizedBox(height: 10),
                  _FieldLabel(text: 'Digestion & Gut Health'),
                  _InputField(controller: _digestionGutController, minLines: 2),
                  const SizedBox(height: 10),
                  _FieldLabel(text: 'Supplements Currently Used'),
                  _InputField(controller: _supplementsController, minLines: 2),
                  const SizedBox(height: 18),

                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3B41A),
                        disabledBackgroundColor: const Color(0xFF8A6A1A),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Update',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
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
    return Text(
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
