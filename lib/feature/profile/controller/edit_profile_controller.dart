import 'package:dio/dio.dart';

import '../../../core/network/api_service/token_meneger.dart';
import '../../../core/network/api_service/user_api_service.dart';
import '../model/edit_profile_form_data.dart';
import '../model/profile_action_result.dart';

class EditProfileController {
  EditProfileController({UserApiService? userApi})
    : _userApi = userApi ?? UserApiService();

  final UserApiService _userApi;

  Future<EditProfileFormData> loadFormData({Map<String, dynamic>? initial}) async {
    if (initial != null && initial.isNotEmpty) {
      return formDataFromMap(initial);
    }
    final res = await _userApi.getProfile();
    final rawData = res['data'];
    final data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};
    return formDataFromMap(data);
  }

  EditProfileFormData formDataFromMap(Map<String, dynamic> data) {
    final bodyDetails = data['personalBodyDetails'] is Map
        ? Map<String, dynamic>.from(data['personalBodyDetails'] as Map)
        : data['bodyDetails'] is Map
        ? Map<String, dynamic>.from(data['bodyDetails'] as Map)
        : data['healthProfile'] is Map
        ? Map<String, dynamic>.from(data['healthProfile'] as Map)
        : <String, dynamic>{};

    return EditProfileFormData(
      rawProfile: data,
      name: _pickString(data, <String>['name']),
      phone: _pickString(data, <String>['phone', 'contact']),
      email: _pickString(data, <String>['email']),
      address: _pickString(data, <String>['address', 'shippingAddress', 'location']),
      memberId: _pickString(data, <String>['_id', 'id', 'memberId']),
      currentWeight: _pickString(bodyDetails, <String>['currentWeight']),
      targetWeight: _pickString(bodyDetails, <String>['targetWeight']),
      recentWeightChanges: _pickString(bodyDetails, <String>['recentWeightChanges']),
      bodyType: _pickString(bodyDetails, <String>['bodyType']),
      currentHeight: _pickString(bodyDetails, <String>['currentHeight', 'height']),
      sleepPatterns: _pickString(bodyDetails, <String>['sleepPatterns', 'sleep']),
      appetiteHunger: _pickString(bodyDetails, <String>['appetiteHunger']),
      typicalDailyMeals: _pickString(bodyDetails, <String>['typicalDailyMeals', 'typicalMeals']),
      waterFluidIntake: _pickString(bodyDetails, <String>['waterFluidIntake', 'waterIntake']),
      surgicalHistory: _pickString(bodyDetails, <String>['surgicalHistory']),
      currentPhysicalPains: _pickString(bodyDetails, <String>['currentPhysicalPains', 'physicalPains']),
      digestionGutHealth: _pickString(bodyDetails, <String>['digestionGutHealth', 'digestionGut']),
      supplementsCurrentlyUsed: _pickString(bodyDetails, <String>['supplementsCurrentlyUsed', 'supplements']),
    );
  }

  Future<ProfileActionResult> saveProfile({
    required EditProfileFormData form,
    String? avatarPath,
  }) async {
    final name = form.name.trim();
    if (name.isEmpty) {
      return const ProfileActionResult(
        success: false,
        message: 'Username is required',
      );
    }

    try {
      final res = await _userApi.updateProfile(
        name: name,
        phone: form.phone.trim(),
        email: form.email.trim(),
        address: form.address.trim(),
        avatarPath: avatarPath,
        personalBodyDetails: form.personalBodyDetails,
      );

      await TokenManager.saveUserName(name);
      if (form.email.trim().isNotEmpty) {
        await TokenManager.saveEmail(form.email.trim());
      }

      final message = (res['message'] ?? 'Profile updated successfully').toString();
      return ProfileActionResult(success: true, message: message);
    } on DioException catch (e) {
      final payload = e.response?.data;
      final message = payload is Map && payload['message'] != null
          ? payload['message'].toString()
          : 'Profile update failed';
      return ProfileActionResult(success: false, message: message);
    } catch (_) {
      return const ProfileActionResult(
        success: false,
        message: 'Profile update failed',
      );
    }
  }

  String parseLoadError(Object error, {required String fallback}) {
    if (error is DioException) {
      final payload = error.response?.data;
      if (payload is Map && payload['message'] != null) {
        return payload['message'].toString();
      }
    }
    return fallback;
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
}
