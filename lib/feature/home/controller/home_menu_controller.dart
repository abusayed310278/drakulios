import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_service/api_client.dart';
import '../../../core/network/api_service/token_meneger.dart';
import '../../profile/model/profile_action_result.dart';

class HomeMenuController {
  HomeMenuController({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(ApiEndpoints.baseUrl);

  final ApiClient _apiClient;

  Future<ProfileActionResult> logout() async {
    String message = 'Logged out successfully';

    try {
      final response = await _apiClient.post(ApiEndpoints.logout);
      final data = response.data;
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }
    } on DioException catch (e) {
      final resData = e.response?.data;
      if (resData is Map && resData['message'] != null) {
        message = resData['message'].toString();
      } else {
        message = 'Session cleared locally';
      }
    } catch (_) {
      message = 'Session cleared locally';
    }

    await TokenManager.clearToken();
    await TokenManager.clearRole();
    await TokenManager.clearUid();
    await TokenManager.clearUserName();
    await TokenManager.clearServiceType();

    return ProfileActionResult(success: true, message: message);
  }

  Future<ProfileActionResult> openWhatsApp(String rawPhone) async {
    final phone = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    final appUri = Uri.parse('whatsapp://send?phone=$phone');
    final webUri = Uri.parse('https://wa.me/$phone');

    final openedApp = await launchUrl(
      appUri,
      mode: LaunchMode.externalApplication,
    );
    if (openedApp) return const ProfileActionResult(success: true, message: 'Opened');

    final openedWeb = await launchUrl(
      webUri,
      mode: LaunchMode.externalApplication,
    );
    if (openedWeb) return const ProfileActionResult(success: true, message: 'Opened');

    return const ProfileActionResult(
      success: false,
      message: 'Unable to open WhatsApp',
    );
  }
}
