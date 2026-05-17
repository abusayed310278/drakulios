import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/common/widgets/custom_snackbar.dart';

import '../../../core/language/translated_text.dart';
import '../../../core/common/widgets/page_loading_overlay.dart';
import '../../../core/constants/assets.dart';
import '../controller/member_profile_details_controller.dart';
import '../model/member_profile_details_data.dart';

class MemberProfileDetailsScreen extends StatefulWidget {
  const MemberProfileDetailsScreen({super.key});

  @override
  State<MemberProfileDetailsScreen> createState() =>
      _MemberProfileDetailsScreenState();
}

class _MemberProfileDetailsScreenState
    extends State<MemberProfileDetailsScreen> {
  final MemberProfileDetailsController _controller =
      MemberProfileDetailsController();

  bool _loading = true;
  MemberProfileDetailsData? _details;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final details = await _controller.loadDetails();
      if (!mounted) return;
      setState(() {
        _details = details;
      });
    } catch (error) {
      CustomSnackbar.show(
        _controller.parseErrorMessage(
          error,
          fallback: 'Failed to load profile details',
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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

    final details = _details;

    if (_loading && details == null) {
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
                          TranslatedText(
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
                                  ((details?.avatarUrl ?? '')
                                      .trim()
                                      .isNotEmpty)
                                  ? Image.network(
                                      details!.avatarUrl,
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
                                TranslatedText(
                                  details?.name ?? 'Member',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TranslatedText(
                                  'Member ID : ${details?.memberId ?? ''}',
                                  style: profileInfoStyle,
                                ),
                                TranslatedText(
                                  'Contact no. : ${details?.phone ?? ''}',
                                  style: profileInfoStyle,
                                ),
                                TranslatedText(
                                  'Email : ${details?.email ?? ''}',
                                  style: profileInfoStyle,
                                ),
                                TranslatedText(
                                  'Address : ${(details?.address ?? '').isEmpty ? 'N/A' : details!.address}',
                                  style: profileInfoStyle,
                                ),
                                TranslatedText(
                                  'Member Since : ${details?.memberSince ?? 'N/A'}',
                                  style: profileInfoStyle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      TranslatedText(
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
                            'Current Weight: ${details?.healthValue('currentWeight') ?? 'N/A'}.\n'
                            'Target Weight: ${details?.healthValue('targetWeight') ?? 'N/A'}.\n'
                            'Body Type Description: ${details?.healthValue('bodyType') ?? 'N/A'}.\n'
                            'Weight Trends: ${details?.healthValue('recentWeightChanges') ?? 'N/A'}.\n'
                            'Current Height: ${details?.healthValue('currentHeight') ?? 'N/A'}.\n'
                            'Sleep: ${details?.healthValue('sleepPatterns') ?? 'N/A'}.',
                        titleStyle: sectionTitleStyle,
                        bodyStyle: sectionBodyStyle,
                      ),
                      const SizedBox(height: 22),
                      _DetailSection(
                        title: '2. Health & Medical History\n',
                        content:
                            'Surgical History: ${details?.healthValue('surgicalHistory') ?? 'N/A'}.\n'
                            'Joint & Muscle Pain: ${details?.healthValue('currentPhysicalPains') ?? 'N/A'}.\n'
                            'Digestive Health: ${details?.healthValue('digestionGutHealth') ?? 'N/A'}.',
                        titleStyle: sectionTitleStyle,
                        bodyStyle: sectionBodyStyle,
                      ),
                      const SizedBox(height: 22),
                      _DetailSection(
                        title: '3. Nutritional Habits & Supplementation\n',
                        content:
                            'Meal Frequency: ${details?.healthValue('typicalDailyMeals') ?? 'N/A'}.\n'
                            'Hunger Patterns: ${details?.healthValue('appetiteHunger') ?? 'N/A'}.\n'
                            'Hydration & Stimulants: ${details?.healthValue('waterFluidIntake') ?? 'N/A'}.\n'
                            'Supplements: ${details?.healthValue('supplementsCurrentlyUsed') ?? 'N/A'}.',
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
