import 'package:dio/dio.dart';

import '../../../core/network/api_service/training_shop_api_service.dart';
import '../model/freeze_membership_preset.dart';
import '../model/profile_action_result.dart';

class FreezeAccountController {
  FreezeAccountController({TrainingShopApiService? api})
    : _api = api ?? TrainingShopApiService();

  final TrainingShopApiService _api;

  static const List<int> weekOptions = <int>[1, 2, 3, 4];

  Future<FreezeMembershipPreset> loadFreezeStatus() async {
    final res = await _api.getFreezeMembershipStatus();
    final dataRaw = res['data'];
    if (dataRaw is! Map) return const FreezeMembershipPreset();

    final data = Map<String, dynamic>.from(dataRaw);
    final isFrozen = data['isFrozen'] == true;
    if (!isFrozen) return const FreezeMembershipPreset();

    final startDate = _parseDateFromAnyKey(data, <String>[
      'startDate',
      'freezeStartDate',
      'fromDate',
    ]);
    final endDate = _parseDateFromAnyKey(data, <String>[
      'endDate',
      'freezeEndDate',
      'toDate',
    ]);

    DateTime? resolvedStart = startDate;
    int? resolvedWeeks;
    if (endDate != null) {
      resolvedStart ??= normalizeDate(DateTime.now());
      final diffDays = endDate.difference(resolvedStart).inDays;
      final calculatedWeeks = diffDays <= 0 ? 1 : (diffDays / 7).ceil();
      resolvedWeeks = calculatedWeeks.clamp(1, 4);
    }

    return FreezeMembershipPreset(startDate: resolvedStart, weeks: resolvedWeeks);
  }

  Future<ProfileActionResult> confirmFreeze({
    required DateTime? startDate,
    required int? selectedWeeks,
  }) async {
    if (startDate == null) {
      return const ProfileActionResult(
        success: false,
        message: 'Please select freeze start date',
      );
    }
    if (selectedWeeks == null) {
      return const ProfileActionResult(
        success: false,
        message: 'Please select freeze duration (1-4 weeks)',
      );
    }

    final endDate = normalizeDate(startDate.add(Duration(days: selectedWeeks * 7)));
    try {
      final res = await _api.freezeMembership(indefinite: false, endDate: endDate);
      return ProfileActionResult(
        success: true,
        message: (res['message'] ?? 'Membership freeze updated successfully').toString(),
      );
    } catch (error) {
      return ProfileActionResult(
        success: false,
        message: parseErrorMessage(error),
      );
    }
  }

  DateTime normalizeDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  String startDateLabel(DateTime? date) {
    if (date == null) return 'Enter start date..';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  DateTime? calculatedEndDate(DateTime? startDate, int? selectedWeeks) {
    if (startDate == null || selectedWeeks == null) return null;
    return normalizeDate(startDate.add(Duration(days: selectedWeeks * 7)));
  }

  String freezeSummaryLabel(DateTime? startDate, int? selectedWeeks) {
    final endDate = calculatedEndDate(startDate, selectedWeeks);
    if (startDate == null || selectedWeeks == null || endDate == null) {
      return 'Select start date and duration (1-4 weeks).';
    }

    final startText = startDateLabel(startDate);
    final endText = startDateLabel(endDate);
    return 'Freeze duration: $selectedWeeks week${selectedWeeks > 1 ? 's' : ''} ($startText to $endText)';
  }

  String parseErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final message =
            data['message']?.toString() ??
            data['error']?.toString() ??
            data['details']?.toString();
        if (message != null && message.trim().isNotEmpty) {
          return message;
        }
      }
    }
    return 'Failed to freeze membership. Please try again.';
  }

  DateTime? _parseDateFromAnyKey(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final raw = data[key]?.toString();
      if (raw == null || raw.trim().isEmpty) continue;
      final parsed = DateTime.tryParse(raw)?.toLocal();
      if (parsed != null) return normalizeDate(parsed);
    }
    return null;
  }
}
