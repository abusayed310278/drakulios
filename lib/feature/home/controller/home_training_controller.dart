import 'package:dio/dio.dart';

import '../../../core/network/api_service/token_meneger.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../../core/network/api_service/user_api_service.dart';
import '../model/home_feed_data.dart';
import '../model/home_member_profile_data.dart';

class HomeTrainingController {
  HomeTrainingController({
    TrainingShopApiService? api,
    UserApiService? userApi,
  }) : _api = api ?? TrainingShopApiService(),
       _userApi = userApi ?? UserApiService();

  final TrainingShopApiService _api;
  final UserApiService _userApi;

  Future<HomeMemberProfileData> loadMemberProfile() async {
    try {
      final response = await _userApi.getProfile();
      final data = (response['data'] ?? <String, dynamic>{}) as Map;
      final name = _toCamelCase((data['name'] ?? '').toString().trim());
      final avatarUrl = (data['avatar']?['url'] ?? '').toString();
      return HomeMemberProfileData(displayName: name, avatarUrl: avatarUrl);
    } catch (_) {
      final savedName = (await TokenManager.getUserName())?.trim() ?? '';
      return HomeMemberProfileData(
        displayName: _toCamelCase(savedName),
        avatarUrl: '',
      );
    }
  }

  Future<HomeFeedData> loadTodayTrainings() async {
    final payload = await _api.getTodayTrainingsBundle();
    final data = _toMapList(payload['data']);
    final serverDate = _readServerDate(payload['meta']);

    var resolved = data;
    if (resolved.isEmpty) {
      final mine = await _api.getMyTrainings();
      final today = DateTime.now();
      final filtered = mine
          .where((e) => isSameDay(tryParseItemDate(e), today))
          .toList();
      resolved = filtered.isNotEmpty ? filtered : mine;
    }

    return HomeFeedData(items: resolved, serverDate: serverDate);
  }

  Future<HomeFeedData> loadTodayNutritions() async {
    final payload = await _api.getTodayNutritionsBundle();
    final data = _toMapList(payload['data']);
    final serverDate = _readServerDate(payload['meta']);

    var resolved = data;
    if (resolved.isEmpty) {
      final mine = await _api.getMyNutritions();
      final today = DateTime.now();
      final filtered = mine
          .where((e) => isSameDay(tryParseItemDate(e), today))
          .toList();
      resolved = filtered.isNotEmpty ? filtered : mine;
    }

    return HomeFeedData(items: resolved, serverDate: serverDate);
  }

  String readErrorMessage(Object error, {required String fallback}) {
    if (error is DioException) {
      final payload = error.response?.data;
      if (payload is Map && payload['message'] != null) {
        final message = payload['message'].toString().trim();
        if (message.isNotEmpty) return message;
      }
    }
    return fallback;
  }

  DateTime? tryParseItemDate(Map<String, dynamic>? item) {
    if (item == null) return null;
    final raw =
        item['date'] ??
        item['nutritionDate'] ??
        item['forDate'] ??
        item['createdAt'] ??
        item['updatedAt'];
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }

  String? extractImageUrl(Map<String, dynamic>? row) {
    if (row == null) return null;
    final imageRaw = row['image'];
    if (imageRaw is Map && imageRaw['url'] != null) {
      final url = imageRaw['url'].toString().trim();
      return url.isEmpty ? null : url;
    }
    if (imageRaw is String) {
      final url = imageRaw.trim();
      return url.isEmpty ? null : url;
    }
    return null;
  }

  bool isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String formatHeaderDate(DateTime? date) {
    final d = date ?? DateTime.now();
    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = d.day;
    final mod100 = day % 100;
    var suffix = 'th';
    if (mod100 < 11 || mod100 > 13) {
      switch (day % 10) {
        case 1:
          suffix = 'st';
          break;
        case 2:
          suffix = 'nd';
          break;
        case 3:
          suffix = 'rd';
          break;
      }
    }
    return '$day$suffix ${months[d.month - 1]} ${d.year}';
  }

  DateTime? _readServerDate(dynamic meta) {
    if (meta is Map && meta['serverDate'] != null) {
      return DateTime.tryParse(meta['serverDate'].toString());
    }
    return null;
  }

  List<Map<String, dynamic>> _toMapList(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  String _toCamelCase(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'Member';

    return parts
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
