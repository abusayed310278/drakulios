import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_service/api_client.dart';
import '../../../core/network/api_service/token_meneger.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../navigation/view/app_shell_screen.dart';
import '../../paymentandsubscription/view/payment_flow_destination.dart';
import '../model/auth_action_result.dart';
import '../model/login_result.dart';
import '../model/login_route_target.dart';
import '../model/remembered_credentials.dart';

class LoginController {
  LoginController({ApiClient? apiClient, TrainingShopApiService? trainingApi})
    : _apiClient = apiClient ?? ApiClient(ApiEndpoints.baseUrl),
      _trainingApi = trainingApi ?? TrainingShopApiService();

  final ApiClient _apiClient;
  final TrainingShopApiService _trainingApi;

  Future<RememberedCredentials?> loadRememberedCredentials() async {
    final remember = await TokenManager.isRememberMeEnabled();
    if (!remember) return null;

    final email = await TokenManager.getRememberedEmail();
    final password = await TokenManager.getRememberedPassword();

    return RememberedCredentials(email: email ?? '', password: password ?? '');
  }

  Future<void> updateRememberMePreference({
    required bool rememberMe,
    String? email,
    String? password,
  }) async {
    await TokenManager.setRememberMe(rememberMe);
    if (rememberMe) {
      if ((email ?? '').trim().isNotEmpty || (password ?? '').isNotEmpty) {
        await TokenManager.saveRememberedCredentials(
          email: (email ?? '').trim(),
          password: password ?? '',
        );
      }
      return;
    }
    await TokenManager.clearRememberedCredentials();
  }

  Future<LoginResult> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || password.isEmpty) {
      return const LoginResult(
        success: false,
        message: 'Please enter email and password',
      );
    }

    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: {'email': cleanEmail, 'password': password},
      );
      final data = response.data;
      final success = data['success'] == true;
      final backendMessage = (data['message'] ?? '').toString();

      if (!success) {
        return LoginResult(
          success: false,
          message: backendMessage.isEmpty ? 'Login failed' : backendMessage,
        );
      }

      final payload = (data['data'] ?? {}) as Map<String, dynamic>;
      final accessToken = (payload['accessToken'] ?? '').toString();
      final refreshToken = (payload['refreshToken'] ?? '').toString();

      if (accessToken.isEmpty || refreshToken.isEmpty) {
        return const LoginResult(
          success: false,
          message: 'Login failed: missing token',
        );
      }

      await TokenManager.save(
        access: accessToken,
        refresh: refreshToken,
        uid: (payload['_id'] ?? payload['user']?['_id'] ?? '').toString(),
        userName: (payload['user']?['name'] ?? '').toString(),
        userEmail: (payload['user']?['email'] ?? cleanEmail).toString(),
        userRole: (payload['role'] ?? payload['user']?['role'] ?? '').toString(),
      );

      await updateRememberMePreference(
        rememberMe: rememberMe,
        email: cleanEmail,
        password: password,
      );

      final routeTarget = await _resolveNextRoute();
      return LoginResult(
        success: true,
        message: backendMessage.isEmpty ? 'Login successful' : backendMessage,
        routeTarget: routeTarget,
      );
    } on DioException catch (e) {
      final resData = e.response?.data;
      String message = 'Login failed';
      if (resData is Map && resData['message'] != null) {
        message = resData['message'].toString();
      } else if (e.message != null && e.message!.trim().isNotEmpty) {
        message = e.message!;
      }
      return LoginResult(success: false, message: message);
    } catch (_) {
      return const LoginResult(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  Future<AuthActionResult> requestPasswordResetOtp(String email) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      return const AuthActionResult(
        success: false,
        message: 'Please enter your email first',
      );
    }

    try {
      final response = await _apiClient.post(
        ApiEndpoints.forgetPassword,
        data: {'email': cleanEmail},
      );
      final data = response.data;
      final message = (data['message'] ?? 'OTP sent to your email').toString();
      return AuthActionResult(success: true, message: message);
    } on DioException catch (e) {
      final resData = e.response?.data;
      String message = 'Failed to send OTP';
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

  Future<bool> _resolveHasActivePlan() async {
    try {
      final res = await _apiClient.get(ApiEndpoints.paymentHistory);
      final raw = res.data;
      if (raw is! Map) return false;
      final data = raw['data'];
      if (data is! Map) return false;

      final explicitFlag = data['hasActivePlan'];
      if (explicitFlag is bool) return explicitFlag;

      final purchases = data['purchases'];
      if (purchases is List) {
        return purchases.any((e) {
          if (e is! Map) return false;
          final title = (e['title'] ?? '').toString().toLowerCase();
          return title.contains('subscription');
        });
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<LoginRouteTarget> _resolveNextRoute() async {
    try {
      final membership = await _trainingApi.getMembershipSummary();
      final data = membership['data'];
      if (data is Map && data['hasActiveMembership'] == true) {
        final planName = (data['planName'] ?? '').toString();
        final destination = _destinationFromPlanName(planName);
        if (destination != null) {
          final tab = AppShellScreen.tabForFlowDestination(destination);
          return LoginRouteTarget(
            initialTab: tab,
            initialTrainingDestination: tab == AppShellTab.trainings
                ? destination
                : null,
          );
        }
        return const LoginRouteTarget(initialTab: AppShellTab.home);
      }
    } catch (_) {}

    final hasActivePlan = await _resolveHasActivePlan();
    if (hasActivePlan) {
      return const LoginRouteTarget(initialTab: AppShellTab.home);
    }
    return const LoginRouteTarget(initialTab: AppShellTab.trainings);
  }

  PaymentFlowDestination? _destinationFromPlanName(String planName) {
    final name = planName.toLowerCase();
    if (name.contains('personal training') || name.contains('personal')) {
      return PaymentFlowDestination.personalTraining;
    }
    if (name.contains('online coaching') || name.contains('coaching')) {
      return PaymentFlowDestination.onlineCoaching;
    }
    if (name.contains('training plan') || name.contains('daily training')) {
      return PaymentFlowDestination.trainingPlan;
    }
    return null;
  }
}
