import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_service/api_client.dart';
import '../model/auth_action_result.dart';

class ResetPasswordController {
  ResetPasswordController({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(ApiEndpoints.baseUrl);

  final ApiClient _apiClient;

  Future<AuthActionResult> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  }) async {
    if (password.isEmpty || confirmPassword.isEmpty) {
      return const AuthActionResult(
        success: false,
        message: 'Please enter both password fields',
      );
    }
    if (password != confirmPassword) {
      return const AuthActionResult(
        success: false,
        message: 'Password and confirm password do not match',
      );
    }

    try {
      final response = await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {'email': email, 'otp': otp, 'password': password},
      );
      final data = response.data;
      final message = (data['message'] ?? 'Password reset successfully').toString();
      return AuthActionResult(success: true, message: message);
    } on DioException catch (e) {
      final resData = e.response?.data;
      String message = 'Reset password failed';
      if (resData is Map && resData['message'] != null) {
        message = resData['message'].toString();
      } else if (e.message != null && e.message!.trim().isNotEmpty) {
        message = e.message!;
      }
      return AuthActionResult(success: false, message: message);
    } catch (_) {
      return const AuthActionResult(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }
}
