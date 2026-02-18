import 'package:flutter/material.dart';

import '../../../../core/constants/assets.dart';
import '../../../profile/views/member_profile_screen.dart';

class ShopHeader extends StatelessWidget {
  const ShopHeader({super.key, required this.title, this.onBack, this.showIcons = true});

  final String title;
  final VoidCallback? onBack;
  final bool showIcons;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack ?? () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFFC9CDD3)),
          splashRadius: 18,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(color: Color(0xFFB1B1B1), fontSize: 18, fontWeight: FontWeight.w400, height: 1.2),
        ),
        if (showIcons) ...[
          const Spacer(),
          Image.asset(Images.cartImage, width: 24, height: 24, color: const Color(0xFFF3B41A)),
          const SizedBox(width: 12),
          Image.asset(Images.bellImage, width: 24, height: 24, color: const Color(0xFFC9CDD3)),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MemberProfileScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: CircleAvatar(
              radius: 12,
              backgroundColor: const Color(0xFF2A2F39),
              child: ClipOval(child: Image.asset(Images.profileImage, width: 24, height: 24, fit: BoxFit.cover)),
            ),
          ),
        ],
      ],
    );
  }
}
