import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/common/widgets/page_loading_overlay.dart';
import '../../../core/constants/assets.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../../core/network/api_service/user_api_service.dart';
import 'attendance_details_screen.dart';
import 'edit_profile_screen.dart';
import 'member_profile_details_screen.dart';
import 'purchase_history_screen.dart';
import 'security_screen.dart';

class MemberProfileScreen extends StatefulWidget {
  const MemberProfileScreen({super.key});

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  static const String _defaultAdminWhatsApp = '01623769661';
  final UserApiService _userApi = UserApiService();
  final TrainingShopApiService _trainingApi = TrainingShopApiService();
  bool _isLoading = true;
  Map<String, dynamic> _profile = const {};
  Map<String, dynamic> _membership = const {};

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

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final responses = await Future.wait([
        _userApi.getProfile(),
        _trainingApi.getMembershipSummary(),
      ]);
      final res = responses[0];
      final membershipRes = responses[1];
      if (!mounted) return;
      setState(() {
        _profile = Map<String, dynamic>.from((res['data'] ?? {}) as Map);
        _membership = Map<String, dynamic>.from(
          (membershipRes['data'] ?? {}) as Map,
        );
      });
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map && data['message'] != null
          ? data['message'].toString()
          : 'Failed to load profile';
      CustomSnackbar.show(msg);
    } catch (_) {
      CustomSnackbar.show('Failed to load profile');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openWhatsApp(String phone, {String? name}) async {
    final normalized = _normalizeWhatsAppPhone(phone);
    if (normalized.isEmpty) {
      CustomSnackbar.show('Admin contact number is not available');
      return;
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
      if (openedApp) return;
    } catch (_) {
      // Ignore and try web fallback.
    }

    try {
      final openedWeb = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
      if (openedWeb) return;
    } catch (_) {}

    CustomSnackbar.show('Unable to open WhatsApp on this device');
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
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return digits;
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

  @override
  Widget build(BuildContext context) {
    final name = _toCamelCase((_profile['name'] ?? 'Member').toString());
    final id = (_profile['_id'] ?? '').toString();
    final phone = _formatPhone(
      (_profile['phone'] ?? _profile['contact'] ?? '').toString(),
    );
    final email = (_profile['email'] ?? '').toString();
    final since = _formatMemberSince((_profile['createdAt'] ?? '').toString());
    final hasMembership = _membership['hasActiveMembership'] == true;
    final planName = (_membership['planName'] ?? 'No Active Plan').toString();
    final price = (_membership['price'] as num?)?.toDouble() ?? 0;
    final billingPeriod = (_membership['billingPeriod'] ?? 'monthly')
        .toString()
        .toLowerCase();
    final billingLabel = billingPeriod == 'yearly' ? 'Year' : 'Month';
    final renewalDate = _formatRenewalDate(
      (_membership['renewalDate'] ?? '').toString(),
    );
    final paymentMethod = (_membership['paymentMethod'] ?? 'Card').toString();
    final paid =
        (_membership['paymentStatus'] ?? '').toString().toLowerCase() ==
        'complete';

    if (_isLoading && _profile.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF050608),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF3B41A)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Stack(
              children: [
                MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 50, 0, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_isLoading)
                          const LinearProgressIndicator(
                            minHeight: 1.5,
                            color: Color(0xFFF3B41A),
                            backgroundColor: Colors.transparent,
                          ),
                        Row(
                          children: [
                            Transform.translate(
                              offset: const Offset(-15, 0),
                              child: IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 18,
                                  color: Color(0xFFC9CDD3),
                                ),
                                splashRadius: 18,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Member Profile',
                              style: TextStyle(
                                color: Color(0xFFB1B1B1),
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ProfileAvatar(
                              imageUrl: (_profile['avatar']?['url'] ?? '')
                                  .toString(),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          name,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 120),
                                      IconButton(
                                        onPressed: () async {
                                          await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => EditProfileScreen(
                                                initialProfile:
                                                    Map<String, dynamic>.from(
                                                      _profile,
                                                    ),
                                              ),
                                            ),
                                          );
                                          if (!mounted) return;
                                          _loadProfile();
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          size: 24,
                                          color: Color(0xFF2C6CFF),
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 24,
                                          minHeight: 24,
                                        ),
                                        splashRadius: 18,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),
                                  Text(
                                    'Member ID : $id',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      height: 1.3,
                                    ),
                                  ),
                                  Text(
                                    'Contact no. : $phone',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      height: 1.3,
                                    ),
                                  ),
                                  Text(
                                    'Email : $email',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      height: 1.3,
                                    ),
                                  ),
                                  Text(
                                    'Member Since : $since',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const MemberProfileDetailsScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'View Details',
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFFF3B41A),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () => _openWhatsApp(
                            (_profile['adminPhone'] ?? _defaultAdminWhatsApp)
                                .toString(),
                            name: 'Admin',
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0C224E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF2C6CFF),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  Images.whatsappImage,
                                  width: 24,
                                  height: 24,
                                  color: const Color(0xFF21C063),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Contact Admin',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      hasMembership
                                          ? 'Plan Name: $planName\nPrice : €${price.toStringAsFixed(price == price.roundToDouble() ? 0 : 2)}/ $billingLabel'
                                          : 'Plan Name: No Active Plan\nPrice : N/A',
                                      style: const TextStyle(
                                        color: Color(0xFF263451),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 64,
                                    height: 24,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: hasMembership
                                          ? const Color(0xFF47AD2A)
                                          : const Color(0xFF9AA1AE),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      hasMembership ? 'Active' : 'Inactive',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF1E1E1E),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          'Renewal Date: $renewalDate.\nPayment Method : $paymentMethod ',
                                    ),
                                    if (hasMembership)
                                      TextSpan(
                                        text: paid ? '(paid)' : '(pending)',
                                        style: TextStyle(
                                          color: paid
                                              ? const Color(0xFF47AD2A)
                                              : const Color(0xFFE53935),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _MenuRow(
                          title: 'View Attendance',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AttendanceDetailsScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        _MenuRow(
                          title: 'View Purchase History',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PurchaseHistoryScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        _MenuRow(
                          title: 'Settings',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SecurityScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                PageLoadingOverlay(loading: _isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasUrl = imageUrl.trim().isNotEmpty;
    return CircleAvatar(
      radius: 32,
      backgroundColor: const Color(0xFF2A2F39),
      child: ClipOval(
        child: hasUrl
            ? Image.network(
                imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 64,
      height: 64,
      color: const Color(0xFF2A2F39),
      child: const Icon(Icons.person, color: Color(0xFFB1B1B1), size: 28),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2513),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF2B31A), width: 1.1),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
