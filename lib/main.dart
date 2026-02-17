import 'package:flutter/material.dart';

import 'feature/onboarding/onboarding_screen.dart';
import 'feature/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drakulios',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF2B31A)),
        useMaterial3: true,
      ),
      home: const SplashScreen(next: OnboardingScreen()),
    );
  }
}
