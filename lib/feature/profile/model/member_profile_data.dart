class MemberProfileData {
  const MemberProfileData({
    required this.profile,
    required this.membership,
    required this.name,
    required this.memberId,
    required this.phone,
    required this.email,
    required this.address,
    required this.memberSince,
    required this.avatarUrl,
    required this.adminPhone,
    required this.hasMembership,
    required this.planName,
    required this.price,
    required this.billingLabel,
    required this.renewalDate,
    required this.paymentMethod,
    required this.paid,
  });

  final Map<String, dynamic> profile;
  final Map<String, dynamic> membership;
  final String name;
  final String memberId;
  final String phone;
  final String email;
  final String address;
  final String memberSince;
  final String avatarUrl;
  final String adminPhone;
  final bool hasMembership;
  final String planName;
  final double price;
  final String billingLabel;
  final String renewalDate;
  final String paymentMethod;
  final bool paid;

  String get priceLabel {
    final decimals = price == price.roundToDouble() ? 0 : 2;
    return '€${price.toStringAsFixed(decimals)}/ $billingLabel';
  }
}
