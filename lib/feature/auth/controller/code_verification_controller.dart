import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_service/api_client.dart';
import '../model/auth_action_result.dart';

class CodeVerificationController {
  CodeVerificationController({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(ApiEndpoints.baseUrl);

  final ApiClient _apiClient;

  Future<AuthActionResult> verifyOtp({
    required String email,
    required String otp,
  }) async {
    if (otp.length != 6) {
      return const AuthActionResult(
        success: false,
        message: 'Please enter 6-digit OTP',
      );
    }

    try {
      final response = await _apiClient.post(
        ApiEndpoints.verifyOtp,
        data: {'email': email, 'otp': otp},
      );
      final data = response.data;
      final message = (data['message'] ?? 'OTP verified successfully').toString();
      return AuthActionResult(success: true, message: message);
    } on DioException catch (e) {
      final resData = e.response?.data;
      String message = 'OTP verification failed';
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

  Future<AuthActionResult> resendOtp({required String email}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.forgetPassword,
        data: {'email': email},
      );
      final data = response.data;
      final message = (data['message'] ?? 'OTP resent to your email').toString();
      return AuthActionResult(success: true, message: message);
    } on DioException catch (e) {
      final resData = e.response?.data;
      String message = 'Failed to resend OTP';
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
