import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../../core/network/api_service/user_api_service.dart';
import '../model/member_profile_data.dart';
import '../model/profile_action_result.dart';

class MemberProfileController {
  MemberProfileController({
    UserApiService? userApi,
    TrainingShopApiService? trainingApi,
  }) : _userApi = userApi ?? UserApiService(),
       _trainingApi = trainingApi ?? TrainingShopApiService();

  static const String defaultAdminWhatsApp = '01623769661';

  final UserApiService _userApi;
  final TrainingShopApiService _trainingApi;

  Future<MemberProfileData> loadProfileData() async {
    final responses = await Future.wait<dynamic>([
      _userApi.getProfile(),
      _trainingApi.getMembershipSummary(),
    ]);

    final profileRaw = responses[0]['data'];
    final membershipRaw = responses[1]['data'];
    final profile = profileRaw is Map
        ? Map<String, dynamic>.from(profileRaw)
        : <String, dynamic>{};
    final membership = membershipRaw is Map
        ? Map<String, dynamic>.from(membershipRaw)
        : <String, dynamic>{};

    final name = _toCamelCase((profile['name'] ?? 'Member').toString());
    final memberId = (profile['_id'] ?? '').toString();
    final phone = _formatPhone((profile['phone'] ?? profile['contact'] ?? '').toString());
    final email = (profile['email'] ?? '').toString();
    final address = (profile['address'] ?? '').toString();
    final memberSince = _formatMemberSince((profile['createdAt'] ?? '').toString());
    final avatarRaw = profile['avatar'];
    final avatar = avatarRaw is Map ? Map<String, dynamic>.from(avatarRaw) : const <String, dynamic>{};
    final avatarUrl = (avatar['url'] ?? '').toString();

    final hasMembership = membership['hasActiveMembership'] == true;
    final planName = (membership['planName'] ?? 'No Active Plan').toString();
    final price = (membership['price'] as num?)?.toDouble() ?? 0;
    final billingPeriod = (membership['billingPeriod'] ?? 'monthly')
        .toString()
        .toLowerCase();
    final billingLabel = billingPeriod == 'yearly' ? 'Year' : 'Month';
    final renewalDate = _formatRenewalDate((membership['renewalDate'] ?? '').toString());
    final paymentMethod = (membership['paymentMethod'] ?? 'Card').toString();
    final paid =
        (membership['paymentStatus'] ?? '').toString().toLowerCase() ==
        'complete';

    return MemberProfileData(
      profile: profile,
      membership: membership,
      name: name,
      memberId: memberId,
      phone: phone,
      email: email,
      address: address,
      memberSince: memberSince,
      avatarUrl: avatarUrl,
      adminPhone: (profile['adminPhone'] ?? defaultAdminWhatsApp).toString(),
      hasMembership: hasMembership,
      planName: planName,
      price: price,
      billingLabel: billingLabel,
      renewalDate: renewalDate,
      paymentMethod: paymentMethod,
      paid: paid,
    );
  }

  Future<ProfileActionResult> openWhatsApp({
    required String phone,
    String? name,
  }) async {
    final normalized = _normalizeWhatsAppPhone(phone);
    if (normalized.isEmpty) {
      return const ProfileActionResult(
        success: false,
        message: 'Admin contact number is not available',
      );
    }

    final text = Uri.encodeComponent(
      'Hi ${name?.trim().isNotEmpty == true ? name : 'Admin'}',
    );
    final appUri = Uri.parse('whatsapp://send?phone=$normalized&text=$text');
    final webUri = Uri.parse('https://wa.me/$normalized?text=$text');

    try {
      final openedApp = await launchUrl(
        appUri,
        mode: LaunchMode.externalApplication,
      );
      if (openedApp) {
        return const ProfileActionResult(success: true, message: 'Opened');
      }
    } catch (_) {}

    try {
      final openedWeb = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
      if (openedWeb) {
        return const ProfileActionResult(success: true, message: 'Opened');
      }
    } catch (_) {}

    return const ProfileActionResult(
      success: false,
      message: 'Unable to open WhatsApp on this device',
    );
  }

  String parseErrorMessage(Object error, {required String fallback}) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    }
    return fallback;
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

  String _normalizeWhatsAppPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    if (digits.startsWith('880')) return digits;
    if (digits.length == 11 && digits.startsWith('0')) {
      return '880${digits.substring(1)}';
    }
    return digits;
  }

  String _formatPhone(String raw) {
    return raw.replaceAll(RegExp(r'[^0-9]'), '');
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

  String _formatMemberSince(String raw) {
    final fallback = '5th January 2026';
    if (raw.trim().isEmpty) return fallback;
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return fallback;
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

  String _formatRenewalDate(String raw) {
    if (raw.trim().isEmpty) return 'N/A';
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
    return '${months[parsed.month - 1]} ${_ordinalDay(parsed.day)}, ${parsed.year}';
  }
}
