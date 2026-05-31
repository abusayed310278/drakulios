class EditProfileFormData {
  const EditProfileFormData({
    required this.rawProfile,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.memberId,
    required this.currentWeight,
    required this.targetWeight,
    required this.recentWeightChanges,
    required this.bodyType,
    required this.currentHeight,
    required this.sleepPatterns,
    required this.appetiteHunger,
    required this.typicalDailyMeals,
    required this.waterFluidIntake,
    required this.surgicalHistory,
    required this.currentPhysicalPains,
    required this.digestionGutHealth,
    required this.supplementsCurrentlyUsed,
  });

  final Map<String, dynamic> rawProfile;
  final String name;
  final String phone;
  final String email;
  final String address;
  final String memberId;
  final String currentWeight;
  final String targetWeight;
  final String recentWeightChanges;
  final String bodyType;
  final String currentHeight;
  final String sleepPatterns;
  final String appetiteHunger;
  final String typicalDailyMeals;
  final String waterFluidIntake;
  final String surgicalHistory;
  final String currentPhysicalPains;
  final String digestionGutHealth;
  final String supplementsCurrentlyUsed;

  String get avatarUrl => (rawProfile['avatar']?['url'] ?? '').toString();

  Map<String, String> get personalBodyDetails => <String, String>{
    'currentWeight': currentWeight.trim(),
    'targetWeight': targetWeight.trim(),
    'recentWeightChanges': recentWeightChanges.trim(),
    'bodyType': bodyType.trim(),
    'currentHeight': currentHeight.trim(),
    'sleepPatterns': sleepPatterns.trim(),
    'appetiteHunger': appetiteHunger.trim(),
    'typicalDailyMeals': typicalDailyMeals.trim(),
    'waterFluidIntake': waterFluidIntake.trim(),
    'surgicalHistory': surgicalHistory.trim(),
    'currentPhysicalPains': currentPhysicalPains.trim(),
    'digestionGutHealth': digestionGutHealth.trim(),
    'supplementsCurrentlyUsed': supplementsCurrentlyUsed.trim(),
  };
}
