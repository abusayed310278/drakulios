class MemberProfileDetailsData {
  const MemberProfileDetailsData({
    required this.profile,
    required this.health,
    required this.name,
    required this.memberId,
    required this.phone,
    required this.email,
    required this.address,
    required this.memberSince,
    required this.avatarUrl,
  });

  final Map<String, dynamic> profile;
  final Map<String, dynamic> health;
  final String name;
  final String memberId;
  final String phone;
  final String email;
  final String address;
  final String memberSince;
  final String avatarUrl;

  String healthValue(String key, {String fallback = 'N/A'}) {
    final value = (health[key] ?? '').toString().trim();
    return value.isEmpty ? fallback : value;
  }
}
