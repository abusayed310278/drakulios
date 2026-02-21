import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/common/widgets/page_loading_overlay.dart';
import '../../../core/constants/assets.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../../core/network/api_service/user_api_service.dart';

class MemberProfileDetailsScreen extends StatefulWidget {
  const MemberProfileDetailsScreen({super.key});

  @override
  State<MemberProfileDetailsScreen> createState() =>
      _MemberProfileDetailsScreenState();
}

class _MemberProfileDetailsScreenState
    extends State<MemberProfileDetailsScreen> {
  final UserApiService _userApi = UserApiService();
  final TrainingShopApiService _api = TrainingShopApiService();

  bool _loading = true;
  Map<String, dynamic> _profile = const {};
  Map<String, dynamic> _health = const {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final profileRes = await _userApi.getProfile();
      final trainings = await _api.getMyTrainings();
      final latest = trainings.isNotEmpty
          ? trainings.first
          : <String, dynamic>{};
      final profileData = Map<String, dynamic>.from(
        (profileRes['data'] ?? {}) as Map,
      );
      final healthFromProfile = profileData['personalBodyDetails'] is Map
          ? Map<String, dynamic>.from(profileData['personalBodyDetails'] as Map)
          : <String, dynamic>{};
      final healthFromTraining = latest['healthProfile'] is Map
          ? Map<String, dynamic>.from(latest['healthProfile'] as Map)
          : <String, dynamic>{};
      final health = <String, dynamic>{
        ...healthFromTraining,
        ...healthFromProfile,
      };

      if (!mounted) return;
      setState(() {
        _profile = profileData;
        _health = health;
      });
    } on DioException catch (e) {
      final payload = e.response?.data;
      final msg = payload is Map && payload['message'] != null
          ? payload['message'].toString()
          : 'Failed to load profile details';
      CustomSnackbar.show(msg);
    } catch (_) {
      CustomSnackbar.show('Failed to load profile details');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _v(String key, {String fallback = 'N/A'}) {
    final value = (_health[key] ?? '').toString().trim();
    return value.isEmpty ? fallback : value;
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

  @override
  Widget build(BuildContext context) {
    final profileInfoStyle = GoogleFonts.outfit(
      color: const Color(0xFFF4F4F5),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.45,
    );
    final sectionTitleStyle = GoogleFonts.outfit(
      color: const Color(0xFFF4F4F5),
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 1.2,
    );
    final sectionBodyStyle = GoogleFonts.outfit(
      color: const Color(0xFFF4F4F5),
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
    );

    final name = (_profile['name'] ?? 'Member').toString();
    final memberId = (_profile['_id'] ?? '').toString();
    final phone = (_profile['phone'] ?? _profile['contact'] ?? '').toString();
    final email = (_profile['email'] ?? '').toString();
    final since = _memberSince((_profile['createdAt'] ?? '').toString());

    if (_loading && _profile.isEmpty) {
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
        top: true,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_loading)
                        const LinearProgressIndicator(
                          minHeight: 1.5,
                          color: Color(0xFFF3B41A),
                          backgroundColor: Colors.transparent,
                        ),
                      Row(
                        children: [
                          Transform.translate(
                            offset: const Offset(-10, 0),
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
                          Text(
                            'View Details',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFE5E7EB),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(0xFF2A2F39),
                            child: ClipOval(
                              child:
                                  ((_profile['avatar']?['url'] ?? '')
                                      .toString()
                                      .trim()
                                      .isNotEmpty)
                                  ? Image.network(
                                      (_profile['avatar']?['url'] ?? '')
                                          .toString(),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                                Images.profileImage,
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              ),
                                    )
                                  : Image.asset(
                                      Images.profileImage,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Member ID : $memberId',
                                  style: profileInfoStyle,
                                ),
                                Text(
                                  'Contact no. : $phone',
                                  style: profileInfoStyle,
                                ),
                                Text('Email : $email', style: profileInfoStyle),
                                Text(
                                  'Member Since : $since',
                                  style: profileInfoStyle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Personal Body Details :',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFF3B41A),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _DetailSection(
                        title: '1. Physical Metrics & Body Composition\n',
                        content:
                            'Current Weight: ${_v('currentWeight')}.\n'
                            'Target Weight: ${_v('targetWeight')}.\n'
                            'Body Type Description: ${_v('bodyType')}.\n'
                            'Weight Trends: ${_v('recentWeightChanges')}.\n'
                            'Current Height: ${_v('currentHeight')}.\n'
                            'Sleep: ${_v('sleepPatterns')}.',
                        titleStyle: sectionTitleStyle,
                        bodyStyle: sectionBodyStyle,
                      ),
                      const SizedBox(height: 22),
                      _DetailSection(
                        title: '2. Health & Medical History\n',
                        content:
                            'Surgical History: ${_v('surgicalHistory')}.\n'
                            'Joint & Muscle Pain: ${_v('currentPhysicalPains')}.\n'
                            'Digestive Health: ${_v('digestionGutHealth')}.',
                        titleStyle: sectionTitleStyle,
                        bodyStyle: sectionBodyStyle,
                      ),
                      const SizedBox(height: 22),
                      _DetailSection(
                        title: '3. Nutritional Habits & Supplementation\n',
                        content:
                            'Meal Frequency: ${_v('typicalDailyMeals')}.\n'
                            'Hunger Patterns: ${_v('appetiteHunger')}.\n'
                            'Hydration & Stimulants: ${_v('waterFluidIntake')}.\n'
                            'Supplements: ${_v('supplementsCurrentlyUsed')}.',
                        titleStyle: sectionTitleStyle,
                        bodyStyle: sectionBodyStyle,
                      ),
                    ],
                  ),
                ),
                PageLoadingOverlay(loading: _loading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.content,
    required this.titleStyle,
    required this.bodyStyle,
  });

  final String title;
  final String content;
  final TextStyle titleStyle;
  final TextStyle bodyStyle;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '$title ', style: titleStyle),
          TextSpan(text: content, style: bodyStyle),
        ],
      ),
    );
  }
}
