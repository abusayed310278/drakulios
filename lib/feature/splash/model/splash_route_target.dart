import '../../navigation/view/app_shell_screen.dart';
import '../../paymentandsubscription/view/payment_flow_destination.dart';

class SplashRouteTarget {
  const SplashRouteTarget({
    required this.loggedIn,
    this.initialTab,
    this.initialTrainingDestination,
  });

  final bool loggedIn;
  final AppShellTab? initialTab;
  final PaymentFlowDestination? initialTrainingDestination;
}
