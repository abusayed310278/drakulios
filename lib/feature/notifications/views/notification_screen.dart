import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/assets.dart';
import 'notification_details_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const todayItems = <_NotificationItem>[
      _NotificationItem(
        title: 'Admin',
        message: 'Gym equipments management',
        details: 'View Details',
        heading: 'ATTENTION MEMBERS:',
        bullet: 'Equipment Maintenance',
        body:
            'Please be advised that the main functional training rack in the center of the gym will be closed for necessary maintenance and safety upgrades on Wednesday, February 11th, from 10:00 AM to 2:00 PM. During this time, the surrounding area will be cordoned off for your safety. We apologize for the inconvenience and appreciate your cooperation in helping us maintain top-tier equipment for your workouts.',
      ),
      _NotificationItem(
        title: 'Admin',
        message: 'Gym Remains closed between 3PM to 5Pm',
        details: 'View Details',
        heading: 'ATTENTION MEMBERS:',
        bullet: 'Temporary Closure',
        body:
            'Please note that the gym remains closed between 3:00 PM and 5:00 PM today due to scheduled maintenance and staff safety checks. We appreciate your patience and understanding.',
      ),
      _NotificationItem(
        title: 'Admin',
        message: 'Gym Remains closed between 3PM to 5Pm',
      ),
    ];
    const weekItems = <_NotificationItem>[
      _NotificationItem(
        title: 'Admin',
        message: 'Gym Remains closed between 3PM to 5Pm',
        details: 'View Details',
        heading: 'ATTENTION MEMBERS:',
        bullet: 'Temporary Closure',
        body:
            'Please note that the gym remains closed between 3:00 PM and 5:00 PM today due to scheduled maintenance and staff safety checks. We appreciate your patience and understanding.',
      ),
      _NotificationItem(
        title: 'Admin',
        message: 'Gym Remains closed between 3PM to 5Pm',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            borderRadius: BorderRadius.circular(12),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: Color(0xFFC9CDD3),
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Notifications',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFB1B1B1),
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _SectionHeading(title: 'Today'),
                        const SizedBox(height: 4),
                        ...todayItems.map(
                          (item) => _NotificationTile(item: item),
                        ),
                        const SizedBox(height: 4),
                        _SectionHeading(title: 'This week'),
                        const SizedBox(height: 4),
                        ...weekItems.map(
                          (item) => _NotificationTile(item: item),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: const Color(0xFFE6E7EA),
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFF2B31A),
            child: ClipOval(
              child: Image.asset(
                Images.profileImage,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 241),
                  child: RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${item.title} ',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFE6E7EA),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.0,
                          ),
                        ),
                        TextSpan(
                          text: item.message,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFBFC4CC),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (item.details != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.details!,
                    style: GoogleFonts.outfit(
                      color: Color(0xFFF2B31A),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ).inkWell(() {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NotificationDetailsScreen(
                          senderName: item.title,
                          heading: item.heading ?? 'ATTENTION MEMBERS:',
                          bullet: item.bullet ?? 'Equipment Maintenance',
                          body:
                              item.body ??
                              'Please be advised that the main functional training rack in the center of the gym will be closed for necessary maintenance and safety upgrades.',
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.message,
    this.details,
    this.heading,
    this.bullet,
    this.body,
  });

  final String title;
  final String message;
  final String? details;
  final String? heading;
  final String? bullet;
  final String? body;
}

extension on Widget {
  Widget inkWell(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: this,
      ),
    );
  }
}
