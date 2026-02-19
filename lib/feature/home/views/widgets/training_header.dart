import 'package:flutter/material.dart';

import '../../../../core/constants/assets.dart';
import '../../../../core/network/api_service/token_meneger.dart';
import '../../../../core/network/api_service/user_api_service.dart';
import '../../../profile/views/member_profile_screen.dart';

class TrainingHeader extends StatefulWidget {
  const TrainingHeader({super.key, required this.activeIndex, required this.onTabChange, required this.dateTitle, required this.dateValue});

  final int activeIndex;
  final ValueChanged<int> onTabChange;
  final String dateTitle;
  final String dateValue;

  @override
  State<TrainingHeader> createState() => _TrainingHeaderState();
}

class _TrainingHeaderState extends State<TrainingHeader> {
  final UserApiService _userApi = UserApiService();
  String _displayName = 'Member';
  String _avatarUrl = '';

  String _toCamelCase(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'Member';
    return parts
        .map((word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  @override
  void initState() {
    super.initState();
    _loadHeaderProfile();
  }

  Future<void> _loadHeaderProfile() async {
    try {
      final res = await _userApi.getProfile();
      final data = (res['data'] ?? {}) as Map;
      if (!mounted) return;
      setState(() {
        final name = (data['name'] ?? '').toString().trim();
        _displayName = _toCamelCase(name);
        _avatarUrl = (data['avatar']?['url'] ?? '').toString();
      });
      return;
    } catch (_) {}

    final savedName = (await TokenManager.getUserName())?.trim() ?? '';
    if (!mounted) return;
    setState(() => _displayName = _toCamelCase(savedName));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good Morning 🔥',
                  style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 14, fontWeight: FontWeight.w500, height: 1.2),
                ),
                const SizedBox(height: 2),
                Text(
                  _displayName,
                  style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 18, fontWeight: FontWeight.w700, height: 1.2),
                ),
              ],
            ),
            const Spacer(),
            Image.asset(Images.bellImage, width: 20, height: 20, color: const Color(0xFFC9CDD3)),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MemberProfileScreen()));
              },
              borderRadius: BorderRadius.circular(12),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFF2A2F39),
                child: ClipOval(
                  child: _avatarUrl.trim().isNotEmpty
                      ? Image.network(
                          _avatarUrl,
                          width: 24,
                          height: 24,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.asset(Images.profileImage, width: 24, height: 24, fit: BoxFit.cover),
                        )
                      : Image.asset(Images.profileImage, width: 24, height: 24, fit: BoxFit.cover),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _TabSwitcher(activeIndex: widget.activeIndex, onChange: widget.onTabChange),
        const SizedBox(height: 12),
        _DateCard(title: widget.dateTitle, date: widget.dateValue),
      ],
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({required this.activeIndex, required this.onChange});

  final int activeIndex;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TabButton(label: 'Training', asset: Images.traningImage, selected: activeIndex == 0, onTap: () => onChange(0)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TabButton(label: 'Nutrition', icon: Icons.restaurant, selected: activeIndex == 1, onTap: () => onChange(1)),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, this.icon, this.asset, required this.selected, required this.onTap});

  final String label;
  final IconData? icon;
  final String? asset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2C6CFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? const Color(0xFF2C6CFF) : const Color(0xFF2A2F39), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (asset != null)
              Image.asset(asset!, width: 16, height: 16, color: Colors.white)
            else
              Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({required this.title, required this.date});

  final String title;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(color: const Color(0xFF0C224E), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFFB7C0D0), fontSize: 11, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 94,
                height: 19,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    date,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, height: 1.2),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 32,
            height: 32,
            child: Center(
              child: Image.asset(Images.solarCalendarImage, width: 32, height: 32, color: const Color(0xFFF2B31A)),
            ),
          ),
        ],
      ),
    );
  }
}
