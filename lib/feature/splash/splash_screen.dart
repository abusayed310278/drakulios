import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/assets.dart';
import '../../core/network/api_service/training_shop_api_service.dart';
import '../../core/network/api_service/token_meneger.dart';
import '../navigation/views/app_shell_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../paymentandsubscription/views/payment_flow_destination.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final TrainingShopApiService _trainingApi = TrainingShopApiService();
  Timer? _timer;
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.93,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _timer = Timer(const Duration(milliseconds: 2000), _goNext);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goNext() async {
    if (!mounted) return;
    final loggedIn = await TokenManager.isLoggedIn();
    if (!mounted) return;
    Widget nextScreen = const OnboardingScreen();
    if (loggedIn) {
      nextScreen = await _resolveScreenForLoggedInUser();
      if (!mounted) return;
    }
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => nextScreen));
  }

  Future<Widget> _resolveScreenForLoggedInUser() async {
    try {
      final membership = await _trainingApi.getMembershipSummary();
      final data = membership['data'];
      if (data is Map && data['hasActiveMembership'] == true) {
        final planName = (data['planName'] ?? '').toString();
        final destination = _destinationFromPlanName(planName);
        if (destination != null) return _shellForDestination(destination);
        return const AppShellScreen();
      }
      return const AppShellScreen(initialTab: AppShellTab.trainings);
    } catch (_) {
      return const AppShellScreen();
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

  Widget _shellForDestination(PaymentFlowDestination destination) {
    final tab = AppShellScreen.tabForFlowDestination(destination);
    return AppShellScreen(
      initialTab: tab,
      initialTrainingDestination: tab == AppShellTab.trainings
          ? destination
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.2),
            radius: 1.1,
            colors: [Color(0xFF2A1D06), Color(0xFF0E0E0E), Color(0xFF050505)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double top = (constraints.maxHeight * 0.33).clamp(
              180.0,
              320.0,
            );
            return Stack(
              children: [
                Positioned(
                  top: top + 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 240,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFF0BE57,
                            ).withValues(alpha: 0.32),
                            blurRadius: 64,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: top,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _opacity,
                    child: ScaleTransition(
                      scale: _scale,
                      child: Center(
                        child: SizedBox(
                          width: 300,
                          height: 266,
                          child: Image.asset(
                            Images.appLogo,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
