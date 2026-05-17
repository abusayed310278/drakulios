import 'auth_action_result.dart';
import 'login_route_target.dart';

class LoginResult extends AuthActionResult {
  const LoginResult({
    required super.success,
    required super.message,
    this.routeTarget,
  });

  final LoginRouteTarget? routeTarget;
}
