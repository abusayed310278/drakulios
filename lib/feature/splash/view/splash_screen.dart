import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/assets.dart';
import '../controller/splash_controller.dart';
import '../../navigation/view/app_shell_screen.dart';
import '../../onboarding/view/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final SplashController _splashController = SplashController();
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
    final target = await _splashController.resolveRoute();
    if (!mounted) return;
    Widget nextScreen = const OnboardingScreen();
    if (target.loggedIn) {
      nextScreen = AppShellScreen(
        initialTab: target.initialTab ?? AppShellTab.home,
        initialTrainingDestination: target.initialTrainingDestination,
      );
    }
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => nextScreen));
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
