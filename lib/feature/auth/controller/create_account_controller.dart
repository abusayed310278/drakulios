import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_service/api_client.dart';
import '../model/auth_action_result.dart';

class CreateAccountController {
  CreateAccountController({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(ApiEndpoints.baseUrl);

  final ApiClient _apiClient;

  Future<AuthActionResult> createAccount({
    required String name,
    required String email,
    required String address,
    required String password,
    required String confirmPassword,
    required bool acceptedTerms,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim();
    final cleanAddress = address.trim();

    if (cleanName.isEmpty ||
        cleanEmail.isEmpty ||
        cleanAddress.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return const AuthActionResult(
        success: false,
        message: 'Please fill in all fields',
      );
    }
    if (!acceptedTerms) {
      return const AuthActionResult(
        success: false,
        message: 'Please accept the terms and conditions',
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
        ApiEndpoints.register,
        data: {
          'name': cleanName,
          'email': cleanEmail,
          'address': cleanAddress,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );
      final data = response.data;
      final success = data['success'] == true;
      final backendMessage = (data['message'] ?? '').toString();

      return AuthActionResult(
        success: success,
        message: backendMessage.isEmpty
            ? (success ? 'Registration completed' : 'Registration failed')
            : backendMessage,
      );
    } on DioException catch (e) {
      final resData = e.response?.data;
      String message = 'Registration failed';
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
