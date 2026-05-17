import 'package:dio/dio.dart';

import '../../constants/api_endpoints.dart';
import 'api_client.dart';
import 'response_mapper.dart';

class NotificationApiService {
  NotificationApiService({ApiClient? client})
    : _client = client ?? ApiClient(ApiEndpoints.baseUrl);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> getMyNotifications() async {
    final Response res = await _client.get(ApiEndpoints.notifications);
    return ResponseMapper.toList(
      res.data,
      candidateKeys: const <String>['data', 'notifications'],
    );
  }

  Future<void> markAsRead(String id) async {
    await _client.patch(ApiEndpoints.markNotificationRead(id), data: const {});
  }
}
