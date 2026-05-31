import '../../navigation/view/app_shell_screen.dart';
import '../../paymentandsubscription/view/payment_flow_destination.dart';

class LoginRouteTarget {
  const LoginRouteTarget({
    required this.initialTab,
    this.initialTrainingDestination,
  });

  final AppShellTab initialTab;
  final PaymentFlowDestination? initialTrainingDestination;
}
