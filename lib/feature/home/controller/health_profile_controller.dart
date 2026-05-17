import '../../../core/network/api_service/token_meneger.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import '../model/health_profile_form_model.dart';

class HealthProfileController {
  HealthProfileController({TrainingShopApiService? api})
    : _api = api ?? TrainingShopApiService();

  final TrainingShopApiService _api;

  Future<String?> submitTrainingDetails(HealthProfileFormModel form) async {
    final uid = await TokenManager.getUid() ?? await TokenManager.getUidFromToken();
    if (uid == null || uid.trim().isEmpty) {
      return 'Unable to identify user for training submission';
    }

    await _api.createTraining(form.toTrainingPayload(userId: uid));
    return null;
  }
}
