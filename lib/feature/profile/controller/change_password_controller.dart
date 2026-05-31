import 'package:dio/dio.dart';

import '../../../core/network/api_service/token_meneger.dart';
import '../../../core/network/api_service/user_api_service.dart';
import '../model/change_password_request.dart';
import '../model/profile_action_result.dart';

class ChangePasswordController {
  ChangePasswordController({UserApiService? userApi})
    : _userApi = userApi ?? UserApiService();

  final UserApiService _userApi;

  Future<String> loadEmail() async {
    final email = await TokenManager.getEmail();
    return (email ?? '').trim();
  }

  Future<ProfileActionResult> savePassword(ChangePasswordRequest request) async {
    final current = request.currentPassword.trim();
    final next = request.newPassword.trim();
    final confirm = request.confirmPassword.trim();

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      return const ProfileActionResult(
        success: false,
        message: 'Please fill all password fields',
      );
    }
    if (next != confirm) {
      return const ProfileActionResult(
        success: false,
        message: 'New password and confirm password do not match',
      );
    }

    try {
      final res = await _userApi.changePassword(
        currentPassword: current,
        newPassword: next,
        confirmPassword: confirm,
      );
      return ProfileActionResult(
        success: true,
        message: (res['message'] ?? 'Password changed successfully').toString(),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map && data['message'] != null
          ? data['message'].toString()
          : 'Failed to change password';
      return ProfileActionResult(success: false, message: msg);
    } catch (_) {
      return const ProfileActionResult(
        success: false,
        message: 'Failed to change password',
      );
    }
  }
}
