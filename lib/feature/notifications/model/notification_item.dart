class NotificationItem {
  const NotificationItem({
    this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    this.details,
    this.heading,
    this.bullet,
    this.body,
    this.senderAvatarUrl,
  });

  final String? id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? details;
  final String? heading;
  final String? bullet;
  final String? body;
  final String? senderAvatarUrl;

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    final created = DateTime.tryParse((map['createdAt'] ?? '').toString()) ??
        DateTime.now();
    return NotificationItem(
      id: map['_id']?.toString(),
      title: (map['title'] ?? 'Admin').toString(),
      message: (map['message'] ?? '').toString(),
      details: map['details']?.toString(),
      heading: map['heading']?.toString(),
      bullet: map['bullet']?.toString(),
      body: map['body']?.toString(),
      senderAvatarUrl: _readImageUrl(map),
      isRead: map['isRead'] == true,
      createdAt: created,
    );
  }

  static String _readImageUrl(Map<String, dynamic> map) {
    const possibleDirectKeys = <String>[
      'senderAvatarUrl',
      'senderImage',
      'imageUrl',
      'avatarUrl',
      'adminImage',
    ];

    for (final key in possibleDirectKeys) {
      final value = map[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }

    final sender = map['sender'];
    if (sender is Map) {
      final senderMap = Map<String, dynamic>.from(sender);
      final nested = (senderMap['avatar'] is Map)
          ? Map<String, dynamic>.from(senderMap['avatar'] as Map)
          : null;

      final nestedUrl = (nested?['url'] ?? '').toString().trim();
      if (nestedUrl.isNotEmpty) return nestedUrl;

      for (final key in possibleDirectKeys) {
        final value = senderMap[key]?.toString().trim() ?? '';
        if (value.isNotEmpty) return value;
      }
    }

    return '';
  }
}
