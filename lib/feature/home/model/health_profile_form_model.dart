class HealthProfileFormModel {
  const HealthProfileFormModel({
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

  Map<String, dynamic> toTrainingPayload({required String userId}) {
    return <String, dynamic>{
      'userId': userId,
      'name': 'Personalized Training Plan',
      'reps': typicalDailyMeals,
      'rest': sleepPatterns,
      'weight': currentWeight,
      'date': DateTime.now().toIso8601String(),
      'healthProfile': <String, dynamic>{
        'currentWeight': currentWeight,
        'targetWeight': targetWeight,
        'recentWeightChanges': recentWeightChanges,
        'bodyType': bodyType,
        'currentHeight': currentHeight,
        'sleepPatterns': sleepPatterns,
        'appetiteHunger': appetiteHunger,
        'typicalDailyMeals': typicalDailyMeals,
        'waterFluidIntake': waterFluidIntake,
        'surgicalHistory': surgicalHistory,
        'currentPhysicalPains': currentPhysicalPains,
        'digestionGutHealth': digestionGutHealth,
        'supplementsCurrentlyUsed': supplementsCurrentlyUsed,
      },
    };
  }
}
