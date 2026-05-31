import 'package:flutter/material.dart';

import '../../../core/network/api_service/training_shop_api_service.dart';
import '../model/subscription_plan_model.dart';

class PaymentAndSubscriptionController {
  PaymentAndSubscriptionController({TrainingShopApiService? api})
    : _api = api ?? TrainingShopApiService();

  final TrainingShopApiService _api;

  static const List<PlanTheme> planThemes = <PlanTheme>[
    PlanTheme(
      markerColor: Color(0xFFF3B41A),
      borderColor: Color(0xFFF3B41A),
      background: LinearGradient(colors: [Color(0xFF073447), Color(0xFF073447)]),
      accentColor: Color(0xFFF3B41A),
    ),
    PlanTheme(
      markerColor: Color(0xFF4BCDC0),
      borderColor: Color(0xFF6A8C87),
      background: LinearGradient(colors: [Color(0xFF142733), Color(0xFF124331)]),
      accentColor: Color(0xFF4BCDC0),
    ),
    PlanTheme(
      markerColor: Color(0xFFB45CFF),
      borderColor: Color(0xFF7A5D9A),
      background: LinearGradient(colors: [Color(0xFF2E1C44), Color(0xFF39214D)]),
      accentColor: Color(0xFFB45CFF),
    ),
    PlanTheme(
      markerColor: Color(0xFFF39DB8),
      borderColor: Color(0xFF8D6675),
      background: LinearGradient(colors: [Color(0xFF4A2D39), Color(0xFF4A3139)]),
      accentColor: Color(0xFFF39DB8),
    ),
    PlanTheme(
      markerColor: Color(0xFFA7A7A7),
      borderColor: Color(0xFF626B76),
      background: LinearGradient(colors: [Color(0xFF191E2B), Color(0xFF20222D)]),
      accentColor: Color(0xFFA7A7A7),
    ),
    PlanTheme(
      markerColor: Color(0xFF45C83C),
      borderColor: Color(0xFF5A8755),
      background: LinearGradient(colors: [Color(0xFF15270E), Color(0xFF1C3112)]),
      accentColor: Color(0xFF45C83C),
    ),
  ];

  Future<List<PlanModel>> fetchPlans() async {
    final rawPlans = await _api.getSubscriptions();
    final mappedPlans = <PlanModel>[];
    for (final raw in rawPlans) {
      final id = raw['_id']?.toString() ?? '';
      if (id.isEmpty) continue;
      final name = raw['name']?.toString().trim();
      if (name == null || name.isEmpty) continue;
      final isActive = raw['isActive'] == true;
      if (!isActive) continue;

      final benefitsRaw = raw['benefits'];
      final benefits = benefitsRaw is List
          ? benefitsRaw
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList()
          : <String>[];
      final monthly = asDouble(raw['priceMonthly']);
      final yearly = asDouble(raw['priceYearly']);

      if (monthly > 0) {
        mappedPlans.add(
          _mapApiPlan(
            index: mappedPlans.length,
            id: id,
            title: yearly > 0 ? '$name (Monthly)' : name,
            bullets: benefits,
            amount: monthly,
            billingPeriod: 'monthly',
          ),
        );
      }
      if (yearly > 0) {
        mappedPlans.add(
          _mapApiPlan(
            index: mappedPlans.length,
            id: id,
            title: '$name (Yearly)',
            bullets: benefits,
            amount: yearly,
            billingPeriod: 'yearly',
          ),
        );
      }
    }
    return mappedPlans;
  }

  PlanModel _mapApiPlan({
    required int index,
    required String id,
    required String title,
    required List<String> bullets,
    required double amount,
    required String billingPeriod,
  }) {
    final theme = planThemes[index % planThemes.length];
    return PlanModel(
      subscriptionId: id,
      billingPeriod: billingPeriod,
      amount: amount,
      title: title,
      markerColor: theme.markerColor,
      borderColor: theme.borderColor,
      background: theme.background,
      bullets: bullets.isEmpty ? const ['Full access to your selected plan'] : bullets,
      priceMain: '\$${priceText(amount)}',
      priceAccent: billingPeriod == 'yearly' ? '/ Year' : '/ Month',
      accentColor: theme.accentColor,
    );
  }

  double asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String priceText(double amount) {
    if (amount == amount.truncateToDouble()) return amount.toStringAsFixed(0);
    return amount.toStringAsFixed(2);
  }
}
