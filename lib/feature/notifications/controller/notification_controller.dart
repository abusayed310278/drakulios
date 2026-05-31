import 'package:dio/dio.dart';

import '../../../core/network/api_service/notification_api_service.dart';
import '../model/notification_item.dart';

class NotificationController {
  NotificationController({NotificationApiService? api})
    : _api = api ?? NotificationApiService();

  final NotificationApiService _api;

  Future<List<NotificationItem>> loadNotifications() async {
    final raw = await _api.getMyNotifications();
    return raw
        .map<Map<String, dynamic>>(_normalizeToMap)
        .where((map) => map.isNotEmpty)
        .map(NotificationItem.fromMap)
        .toList(growable: false);
  }

  Future<void> markAsRead(String id) async {
    await _api.markAsRead(id);
  }

  Future<void> markAllAsRead(List<String> ids) async {
    await Future.wait(
      ids.map((id) async {
        try {
          await _api.markAsRead(id);
        } catch (_) {}
      }),
    );
  }

  String parseError(Object error, {required String fallback}) {
    if (error is DioException) {
      final d = error.response?.data;
      if (d is Map && d['message'] != null) {
        return d['message'].toString();
      }
    }
    return fallback;
  }

  bool isToday(DateTime time) {
    final now = DateTime.now();
    return time.year == now.year && time.month == now.month && time.day == now.day;
  }

  bool isWithinLast7Days(DateTime time) {
    final now = DateTime.now();
    return now.difference(time).inDays <= 7;
  }

  Map<String, dynamic> _normalizeToMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);

    // Defensive conversion for stale runtime objects after refactors/hot reload.
    try {
      final item = raw as dynamic;
      return <String, dynamic>{
        '_id': item.id,
        'title': item.title,
        'message': item.message,
        'createdAt': item.createdAt?.toString(),
        'isRead': item.isRead,
        'details': item.details,
        'heading': item.heading,
        'bullet': item.bullet,
        'body': item.body,
        'senderAvatarUrl': item.senderAvatarUrl,
      };
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
