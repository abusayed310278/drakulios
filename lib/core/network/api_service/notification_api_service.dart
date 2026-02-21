import 'package:dio/dio.dart';

import '../../constants/api_endpoints.dart';
import 'api_client.dart';

class NotificationApiService {
  NotificationApiService({ApiClient? client})
    : _client = client ?? ApiClient(ApiEndpoints.baseUrl);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> getMyNotifications() async {
    final Response res = await _client.get(ApiEndpoints.notifications);
    final raw = res.data;

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (raw is Map && raw['data'] is List) {
      return (raw['data'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (raw is Map && raw['notifications'] is List) {
      return (raw['notifications'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  Future<void> markAsRead(String id) async {
    await _client.patch(ApiEndpoints.markNotificationRead(id), data: const {});
  }
}
