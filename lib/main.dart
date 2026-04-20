import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';

import 'core/constants/payment_config.dart';
import 'feature/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    const stripePk = PaymentConfig.stripePublishableKey;
    if (stripePk.isNotEmpty) {
      Stripe.urlScheme = PaymentConfig.stripeUrlScheme;
      Stripe.publishableKey = stripePk;
      await Stripe.instance.applySettings();
    }
  } on MissingPluginException {
    // Stripe plugin may be unavailable on hot-reload / unsupported runtime.
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drakulios',
      scrollBehavior: const _AppScrollBehavior(),
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF2B31A)), useMaterial3: true),
      home: const SplashScreen(),
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
