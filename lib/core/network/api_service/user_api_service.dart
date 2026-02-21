import 'package:dio/dio.dart';

import '../../constants/api_endpoints.dart';
import 'api_client.dart';

class UserApiService {
  UserApiService({ApiClient? client})
    : _client = client ?? ApiClient(ApiEndpoints.baseUrl);

  final ApiClient _client;

  Future<Map<String, dynamic>> getProfile() async {
    final Response response = await _client.get(ApiEndpoints.getProfile);
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? phone,
    String? email,
    String? gender,
    String? dob,
    String? age,
    String? address,
    String? avatarPath,
    Map<String, String>? personalBodyDetails,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone,
      if (email != null && email.trim().isNotEmpty) 'email': email,
      if (gender != null && gender.trim().isNotEmpty) 'gender': gender,
      if (dob != null && dob.trim().isNotEmpty) 'dob': dob,
      if (age != null && age.trim().isNotEmpty) 'age': age,
      if (address != null && address.trim().isNotEmpty) 'address': address,
      if (personalBodyDetails != null) ...personalBodyDetails,
      if (avatarPath != null && avatarPath.trim().isNotEmpty)
        'avatar': await MultipartFile.fromFile(avatarPath),
    });
    final Response response = await _client.patch(
      ApiEndpoints.updateProfile,
      data: formData,
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final Response response = await _client.post(
      ApiEndpoints.profileChangePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    final Response response = await _client.delete(ApiEndpoints.deleteAccount);
    return Map<String, dynamic>.from(response.data as Map);
  }
}
