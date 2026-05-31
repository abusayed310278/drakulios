import 'package:dio/dio.dart';

import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../../core/network/api_service/user_api_service.dart';
import '../model/attendance_details_data.dart';

class AttendanceDetailsController {
  AttendanceDetailsController({
    UserApiService? userApi,
    TrainingShopApiService? api,
  }) : _userApi = userApi ?? UserApiService(),
       _api = api ?? TrainingShopApiService();

  final UserApiService _userApi;
  final TrainingShopApiService _api;

  Future<AttendanceDetailsData> loadData({required int month, required int year}) async {
    final profileRes = await _userApi.getProfile();
    final attendanceRes = await _api.getMyAttendance(year: year, month: month);

    final profileRaw = profileRes['data'];
    final attendanceRaw = attendanceRes['data'];
    final profile = profileRaw is Map
        ? Map<String, dynamic>.from(profileRaw)
        : <String, dynamic>{};
    final data = attendanceRaw is Map
        ? Map<String, dynamic>.from(attendanceRaw)
        : <String, dynamic>{};

    final active = ((data['attendedDays'] ?? []) as List)
        .whereType<num>()
        .map((e) => e.toInt())
        .toSet();
    final missed = ((data['missedDays'] ?? []) as List)
        .whereType<num>()
        .map((e) => e.toInt())
        .toSet();

    final details = <String, Map<String, dynamic>>{};
    final rows = (data['dayDetails'] ?? []) as List;
    for (final row in rows.whereType<Map>()) {
      final m = Map<String, dynamic>.from(row);
      final date = (m['date'] ?? '').toString();
      if (date.isNotEmpty) details[date] = m;
    }

    return AttendanceDetailsData(
      profile: profile,
      name: (profile['name'] ?? 'Member').toString(),
      memberId: (profile['_id'] ?? '').toString(),
      avatarUrl: ((profile['avatar'] is Map
                  ? (profile['avatar'] as Map)['url']
                  : null) ??
              '')
          .toString(),
      totalVisits: (data['totalVisits'] as num?)?.toInt() ?? 0,
      avgStayMinutes: (data['averageStayMinutes'] as num?)?.toInt() ?? 0,
      lastVisitText: relativeTime((data['lastVisitAt'] ?? '').toString()),
      activeDays: active,
      missedDays: missed,
      dayDetails: details,
    );
  }

  String parseError(Object error) {
    if (error is DioException) {
      final payload = error.response?.data;
      if (payload is Map && payload['message'] != null) {
        return payload['message'].toString();
      }
      if (payload is Map && payload['error'] != null) {
        return payload['error'].toString();
      }
    }
    return 'Failed to load attendance';
  }

  String relativeTime(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return 'No visits yet';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  String formatDuration(int mins) {
    final h = mins ~/ 60;
    final m = mins % 60;
    if (h == 0) return '${m}m';
    return '${h}h ${m}m';
  }

  String formatClock(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return '--';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final mm = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$mm$ampm';
  }
}
