import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/common/widgets/custom_snackbar.dart';

import '../../../core/language/translated_text.dart';
import '../../../core/common/widgets/page_loading_overlay.dart';
import '../../../core/constants/assets.dart';
import '../../../core/language/language_controller.dart';
import '../controller/member_profile_controller.dart';
import '../model/member_profile_data.dart';
import 'attendance_details_screen.dart';
import 'edit_profile_screen.dart';
import 'freeze_account_screen.dart';
import 'member_profile_details_screen.dart';
import 'purchase_history_screen.dart';
import 'security_screen.dart';

class MemberProfileScreen extends StatefulWidget {
  const MemberProfileScreen({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  final MemberProfileController _controller = MemberProfileController();
  final LanguageController _languageController = LanguageController.instance;
  bool _isLoading = true;
  MemberProfileData? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profileData = await _controller.loadProfileData();
      if (!mounted) return;
      setState(() {
        _profileData = profileData;
      });
    } catch (error) {
      CustomSnackbar.show(
        _controller.parseErrorMessage(error, fallback: 'Failed to load profile'),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showLanguagePicker() async {
    final currentLang = _languageController.selectedLang.value;
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF11151D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A404C),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TranslatedText(
                    'Choose Language',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _LanguageOptionTile(
                  label: 'English',
                  value: 'en',
                  selected: currentLang == 'en',
                  onTap: () => Navigator.of(context).pop('en'),
                ),
                const SizedBox(height: 10),
                _LanguageOptionTile(
                  label: 'বাংলা',
                  value: 'bn',
                  selected: currentLang == 'bn',
                  onTap: () => Navigator.of(context).pop('bn'),
                ),
                const SizedBox(height: 10),
                _LanguageOptionTile(
                  label: 'Español',
                  value: 'es',
                  selected: currentLang == 'es',
                  onTap: () => Navigator.of(context).pop('es'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || selected == currentLang) return;
    final errorMessage = await _languageController.changeLanguageWithValidation(
      selected,
    );
    if (errorMessage != null && errorMessage.isNotEmpty) {
      if (!mounted) return;
      CustomSnackbar.show(errorMessage);
      return;
    }
    if (!mounted) return;
    setState(() {});
    CustomSnackbar.show(
      'Language changed to ${_languageName(selected)}',
    );
  }

  String _languageName(String code) {
    switch (code) {
      case 'bn':
        return 'বাংলা';
      case 'es':
        return 'Español';
      case 'en':
      default:
        return 'English';
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _profileData;
    if (_isLoading && data == null) {
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
                    padding: const EdgeInsets.fromLTRB(18, 50, 18, 24),
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
                            if (widget.showBackButton)
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
                              )
                            else
                              const SizedBox(width: 8),
                            const SizedBox(width: 6),
                            TranslatedText(
                              'Member Profile',
                              style: TextStyle(
                                color: Color(0xFFB1B1B1),
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                              ),
                              autoSize: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ProfileAvatar(
                              imageUrl: data?.avatarUrl ?? '',
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                    child: TranslatedText(
                                          data?.name ?? 'Member',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 34 / 2,
                                            fontWeight: FontWeight.w700,
                                            height: 1.2,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          autoSize: true,
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () async {
                                          await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => EditProfileScreen(
                                                initialProfile:
                                                    Map<String, dynamic>.from(
                                                      data?.profile ?? const <String, dynamic>{},
                                                    ),
                                              ),
                                            ),
                                          );
                                          if (!mounted) return;
                                          _loadProfile();
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          size: 20,
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
                                  _LabelValueText(
                                    label: 'Member ID :',
                                    value: (data?.memberId ?? '').isEmpty ? '1212' : data!.memberId,
                                  ),
                                  _LabelValueText(
                                    label: 'Contact no. :',
                                    value: (data?.phone ?? '').isEmpty ? '0000000000' : data!.phone,
                                  ),
                                  _LabelValueText(
                                    label: 'Email :',
                                    value: (data?.email ?? '').isEmpty ? 'stella1212j@gmail.com' : data!.email,
                                  ),
                                  _LabelValueText(
                                    label: 'Address :',
                                    value: (data?.address ?? '').isEmpty ? 'N/A' : data!.address,
                                  ),
                                  _LabelValueText(
                                    label: 'Member Since :',
                                    value: data?.memberSince ?? 'N/A',
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
                                    child: TranslatedText(
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
                        _MembershipCard(
                          planName: (data?.hasMembership ?? false)
                              ? (data?.planName ?? 'Monthly Plan')
                              : 'Monthly Plan',
                          priceLabel: (data?.hasMembership ?? false)
                              ? data!.priceLabel
                              : 'N/A',
                          renewalDate: data?.renewalDate ?? 'N/A',
                          paymentMethod: data?.paymentMethod ?? 'Card',
                          isActive: data?.hasMembership ?? false,
                          paid: data?.paid ?? false,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                title: 'Freeze Membership',
                                borderColor: const Color(0xFFF2B31A),
                                backgroundColor: const Color(0xFF2A2513),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => FreezeAccountScreen(
                                        memberName: data?.name ?? 'Member',
                                        memberId: (data?.memberId ?? '').isEmpty ? '1212' : data!.memberId,
                                        phone: (data?.phone ?? '').isEmpty
                                            ? '0000000000'
                                            : data!.phone,
                                        email: (data?.email ?? '').isEmpty
                                            ? 'stella1212j@gmail.com'
                                            : data!.email,
                                        memberSince: data?.memberSince ?? 'N/A',
                                        avatarUrl: data?.avatarUrl ?? '',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ActionButton(
                                title: 'Message Admin',
                                borderColor: const Color(0xFF2C6CFF),
                                backgroundColor: const Color(0xFF0C224E),
                                leading: Image.asset(
                                  Images.whatsappImage,
                                  width: 18,
                                  height: 18,
                                  color: const Color(0xFF21C063),
                                ),
                                onTap: () async {
                                  final result = await _controller.openWhatsApp(
                                    phone: data?.adminPhone ??
                                        MemberProfileController.defaultAdminWhatsApp,
                                    name: 'Admin',
                                  );
                                  if (!result.success && mounted) {
                                    CustomSnackbar.show(result.message);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
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
                        const SizedBox(height: 10),
                        _MenuRow(
                          title:
                              'Language (${_languageName(_languageController.selectedLang.value)})',
                          onTap: _showLanguagePicker,
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

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2A2513) : const Color(0xFF1B202A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? const Color(0xFFF2B31A) : const Color(0xFF303743),
              width: 1.1,
            ),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (selected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFFF2B31A),
                  size: 18,
                ),
            ],
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
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2513),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFF2B31A), width: 1.1),
          ),
          child: Row(
            children: [
              TranslatedText(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18 / 1.6,
                  fontWeight: FontWeight.w500,
                ),
                autoSize: true,
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({
    required this.planName,
    required this.priceLabel,
    required this.renewalDate,
    required this.paymentMethod,
    required this.isActive,
    required this.paid,
  });

  final String planName;
  final String priceLabel;
  final String renewalDate;
  final String paymentMethod;
  final bool isActive;
  final bool paid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TranslatedText(
                  'Plan Name: $planName\nPrice : $priceLabel',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF22314F),
                    fontSize: 16 / 1.3,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
              Container(
                width: 50,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF47AD2A)
                      : const Color(0xFF9AA1AE),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: TranslatedText(
                  isActive ? 'Active' : 'Inactive',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TranslatedText(
            'Renewal Date: $renewalDate.',
            style: GoogleFonts.outfit(
              color: const Color(0xFF1E1E1E),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
          RichText(
            text: TextSpan(
              style: GoogleFonts.outfit(
                color: const Color(0xFF1E1E1E),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
              children: [
                TextSpan(text: 'Payment Method : $paymentMethod '),
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
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.title,
    required this.borderColor,
    required this.backgroundColor,
    required this.onTap,
    this.leading,
  });

  final String title;
  final Color borderColor;
  final Color backgroundColor;
  final VoidCallback onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 44,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 6)],
              TranslatedText(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabelValueText extends StatelessWidget {
  const _LabelValueText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: Colors.white, fontSize: 12, height: 1.3);
    return Row(
      children: [
        TranslatedText(label, style: style),
        const SizedBox(width: 4),
        Flexible(child: Text(value, style: style)),
      ],
    );
  }
}
