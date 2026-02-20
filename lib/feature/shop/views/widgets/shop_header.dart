import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../../core/constants/assets.dart';
import '../../../../core/network/api_service/user_api_service.dart';
import '../../../../core/common/widgets/custom_snackbar.dart';
import '../../../notifications/views/notification_screen.dart';
import '../../../profile/views/member_profile_screen.dart';
import '../shopping_cart_screen.dart';
import 'shop_badge_state.dart';

class ShopHeader extends StatefulWidget {
  const ShopHeader({
    super.key,
    required this.title,
    this.onBack,
    this.showIcons = true,
  });

  final String title;
  final VoidCallback? onBack;
  final bool showIcons;

  @override
  State<ShopHeader> createState() => _ShopHeaderState();
}

class _ShopHeaderState extends State<ShopHeader> {
  final UserApiService _userApi = UserApiService();
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    try {
      final res = await _userApi.getProfile();
      final data = (res['data'] ?? {}) as Map;
      final avatar = (data['avatar']?['url'] ?? '').toString();
      if (!mounted) return;
      setState(() => _avatarUrl = avatar);
    } on DioException catch (e) {
      final payload = e.response?.data;
      final msg = payload is Map && payload['message'] != null
          ? payload['message'].toString()
          : '';
      if (msg.isNotEmpty) {
        CustomSnackbar.show(msg);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform.translate(
          offset: const Offset(-15, 0),
          child: IconButton(
            onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Color(0xFFC9CDD3),
            ),
            splashRadius: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          widget.title,
          style: const TextStyle(
            color: Color(0xFFB1B1B1),
            fontSize: 18,
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ),
        if (widget.showIcons) ...[
          const Spacer(),
          ValueListenableBuilder<int>(
            valueListenable: ShopBadgeState.cartCount,
            builder: (context, cartCount, _) {
              return _BadgeIcon(
                count: cartCount,
                icon: Images.cartImage,
                color: const Color(0xFFF3B41A),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ShoppingCartScreen(),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 12),
          ValueListenableBuilder<int>(
            valueListenable: ShopBadgeState.notificationCount,
            builder: (context, notificationCount, _) {
              return _BadgeIcon(
                count: notificationCount,
                icon: Images.bellImage,
                color: notificationCount > 0
                    ? const Color(0xFFF3B41A)
                    : const Color(0xFFC9CDD3),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MemberProfileScreen()),
              );
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
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            Images.profileImage,
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        Images.profileImage,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final int count;
  final String icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 28,
        height: 28,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Image.asset(icon, width: 24, height: 24, color: color),
            ),
            if (count > 0)
              Positioned(
                top: -3,
                right: -4,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
