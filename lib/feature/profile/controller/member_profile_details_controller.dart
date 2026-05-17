import 'package:dio/dio.dart';

import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../../core/network/api_service/user_api_service.dart';
import '../model/member_profile_details_data.dart';

class MemberProfileDetailsController {
  MemberProfileDetailsController({
    UserApiService? userApi,
    TrainingShopApiService? trainingApi,
  }) : _userApi = userApi ?? UserApiService(),
       _trainingApi = trainingApi ?? TrainingShopApiService();

  final UserApiService _userApi;
  final TrainingShopApiService _trainingApi;

  Future<MemberProfileDetailsData> loadDetails() async {
    final profileRes = await _userApi.getProfile();
    final trainings = await _trainingApi.getMyTrainings();

    final latest = trainings.isNotEmpty ? trainings.first : <String, dynamic>{};
    final profileData = Map<String, dynamic>.from((profileRes['data'] ?? {}) as Map);

    final healthFromProfile = profileData['personalBodyDetails'] is Map
        ? Map<String, dynamic>.from(profileData['personalBodyDetails'] as Map)
        : <String, dynamic>{};

    final healthFromTraining = latest['healthProfile'] is Map
        ? Map<String, dynamic>.from(latest['healthProfile'] as Map)
        : <String, dynamic>{};

    final health = <String, dynamic>{...healthFromTraining, ...healthFromProfile};

    return MemberProfileDetailsData(
      profile: profileData,
      health: health,
      name: (profileData['name'] ?? 'Member').toString(),
      memberId: (profileData['_id'] ?? '').toString(),
      phone: (profileData['phone'] ?? profileData['contact'] ?? '').toString(),
      email: (profileData['email'] ?? '').toString(),
      address: (profileData['address'] ?? '').toString(),
      memberSince: _memberSince((profileData['createdAt'] ?? '').toString()),
      avatarUrl: (profileData['avatar']?['url'] ?? '').toString(),
    );
  }

  String parseErrorMessage(Object error, {required String fallback}) {
    if (error is DioException) {
      final payload = error.response?.data;
      if (payload is Map && payload['message'] != null) {
        return payload['message'].toString();
      }
    }
    return fallback;
  }

  String _ordinalDay(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  String _memberSince(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return 'N/A';
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${_ordinalDay(parsed.day)} ${months[parsed.month - 1]} ${parsed.year}';
  }
}
