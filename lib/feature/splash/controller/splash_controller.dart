import '../../../core/network/api_service/token_meneger.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../navigation/view/app_shell_screen.dart';
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
        return const SplashRouteTarget(
          loggedIn: true,
          initialTab: AppShellTab.home,
        );
      }
      return const SplashRouteTarget(
        loggedIn: true,
        initialTab: AppShellTab.home,
      );
    } catch (_) {
      return const SplashRouteTarget(
        loggedIn: true,
        initialTab: AppShellTab.home,
      );
    }
  }
}
