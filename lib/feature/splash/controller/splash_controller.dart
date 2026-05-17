import '../../../core/network/api_service/token_meneger.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../navigation/view/app_shell_screen.dart';
import '../../paymentandsubscription/view/payment_flow_destination.dart';
import '../model/splash_route_target.dart';

class SplashController {
  SplashController({TrainingShopApiService? trainingApi})
    : _trainingApi = trainingApi ?? TrainingShopApiService();

  final TrainingShopApiService _trainingApi;

  Future<SplashRouteTarget> resolveRoute() async {
    final loggedIn = await TokenManager.isLoggedIn();
    if (!loggedIn) {
      return const SplashRouteTarget(loggedIn: false);
    }

    try {
      final membership = await _trainingApi.getMembershipSummary();
      final data = membership['data'];
      if (data is Map && data['hasActiveMembership'] == true) {
        final planName = (data['planName'] ?? '').toString();
        final destination = _destinationFromPlanName(planName);
        if (destination != null) {
          final tab = AppShellScreen.tabForFlowDestination(destination);
          return SplashRouteTarget(
            loggedIn: true,
            initialTab: tab,
            initialTrainingDestination:
                tab == AppShellTab.trainings ? destination : null,
          );
        }
        return const SplashRouteTarget(
          loggedIn: true,
          initialTab: AppShellTab.home,
        );
      }
      return const SplashRouteTarget(
        loggedIn: true,
        initialTab: AppShellTab.trainings,
      );
    } catch (_) {
      return const SplashRouteTarget(
        loggedIn: true,
        initialTab: AppShellTab.home,
      );
    }
  }

  PaymentFlowDestination? _destinationFromPlanName(String planName) {
    final name = planName.toLowerCase();
    if (name.contains('personal training') || name.contains('personal')) {
      return PaymentFlowDestination.personalTraining;
    }
    if (name.contains('online coaching') || name.contains('coaching')) {
      return PaymentFlowDestination.onlineCoaching;
    }
    if (name.contains('training plan') || name.contains('daily training')) {
      return PaymentFlowDestination.trainingPlan;
    }
    return null;
  }
}
