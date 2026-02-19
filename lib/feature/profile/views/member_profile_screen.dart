import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/constants/assets.dart';
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
  final UserApiService _userApi = UserApiService();
  bool _isLoading = true;
  Map<String, dynamic> _profile = const {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final res = await _userApi.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = Map<String, dynamic>.from((res['data'] ?? {}) as Map);
      });
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map && data['message'] != null ? data['message'].toString() : 'Failed to load profile';
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
    final cleanedPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanedPhone.isEmpty) {
      CustomSnackbar.show('Admin contact number is not available');
      return;
    }

    final text = Uri.encodeComponent('Hi ${name?.trim().isNotEmpty == true ? name : 'Admin'}');
    final appUri = Uri.parse('whatsapp://send?phone=$cleanedPhone&text=$text');
    final webUri = Uri.parse('https://wa.me/${cleanedPhone.replaceAll('+', '')}?text=$text');

    try {
      final openedApp = await launchUrl(appUri, mode: LaunchMode.externalApplication);
      if (openedApp) return;
    } catch (_) {
      // Ignore and try web fallback.
    }

    try {
      final openedWeb = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      if (openedWeb) return;
    } catch (_) {}

    CustomSnackbar.show('Unable to open WhatsApp on this device');
  }

  @override
  Widget build(BuildContext context) {
    final name = (_profile['name'] ?? 'Stella Jacobs').toString();
    final id = (_profile['_id'] ?? '1212').toString();
    final phone = (_profile['phone'] ?? _profile['contact'] ?? '0000000000').toString();
    final email = (_profile['email'] ?? 'stella1212@gmail.com').toString();
    final since = (_profile['createdAt'] ?? '').toString();

    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 50, 0, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isLoading) const LinearProgressIndicator(minHeight: 1.5, color: Color(0xFFF3B41A), backgroundColor: Colors.transparent),
                    Row(
                      children: [
                        Transform.translate(
                          offset: const Offset(-15, 0),
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFFC9CDD3)),
                            splashRadius: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Member Profile',
                          style: TextStyle(color: Color(0xFFB1B1B1), fontSize: 18, fontWeight: FontWeight.w400, height: 1.2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileAvatar(imageUrl: (_profile['avatar']?['url'] ?? '').toString()),
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
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 120),
                                  IconButton(
                                    onPressed: () async {
                                      await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => EditProfileScreen(
                                            initialProfile: Map<String, dynamic>.from(_profile),
                                          ),
                                        ),
                                      );
                                      if (!mounted) return;
                                      _loadProfile();
                                    },
                                    icon: const Icon(Icons.edit, size: 24, color: Color(0xFF2C6CFF)),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                    splashRadius: 18,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),
                              Text('Member ID : $id', style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3)),
                              Text('Contact no. : $phone', style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3)),
                              Text('Email : $email', style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3)),
                              Text(
                                'Member Since : ${since.isEmpty ? '5th January 2026' : since}',
                                style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const MemberProfileDetailsScreen()),
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
                      onTap: () => _openWhatsApp(phone, name: 'Admin'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C224E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2C6CFF), width: 1.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(Images.whatsappImage, width: 24, height: 24, color: const Color(0xFF21C063)),
                            const SizedBox(width: 8),
                            const Text(
                              'Contact Admin',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Plan Name: Online Coaching \nPrice : €149/ Month',
                                  style: TextStyle(color: Color(0xFF263451), fontSize: 16, fontWeight: FontWeight.w500, height: 1.2),
                                ),
                              ),
                              Container(
                                width: 64,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: const Color(0xFF47AD2A), borderRadius: BorderRadius.circular(100)),
                                child: Text(
                                  'Active',
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w400, height: 1.2),
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
                              children: const [
                                TextSpan(text: 'Renewal Date: March 1st, 2026.\nPayment Method : Credit Card '),
                                TextSpan(
                                  text: '(paid)',
                                  style: TextStyle(color: Color(0xFF47AD2A)),
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
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AttendanceDetailsScreen()));
                      },
                    ),
                    const SizedBox(height: 10),
                    _MenuRow(
                      title: 'View Purchase History',
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PurchaseHistoryScreen()));
                      },
                    ),
                    const SizedBox(height: 10),
                    _MenuRow(
                      title: 'Settings',
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SecurityScreen()));
                      },
                    ),
                  ],
                ),
              ),
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
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
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
