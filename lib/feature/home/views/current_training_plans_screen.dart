import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../paymentandsubscription/views/payment_flow_destination.dart';
import 'choose_training_plan_screen.dart';
import 'daily_training_plan_screen.dart';
import 'home_menu_screen.dart';
import 'personal_training_plan_screen.dart';
import 'training_plan_ownership_resolver.dart';
import 'training_nutrition_screen.dart';

class CurrentTrainingPlansScreen extends StatefulWidget {
  const CurrentTrainingPlansScreen({
    super.key,
    this.showBackButton = true,
    this.preferredDestination,
    this.autoOpenOwnedPlan = false,
  });

  final bool showBackButton;
  final PaymentFlowDestination? preferredDestination;
  final bool autoOpenOwnedPlan;

  @override
  State<CurrentTrainingPlansScreen> createState() =>
      _CurrentTrainingPlansScreenState();
}

class _CurrentTrainingPlansScreenState
    extends State<CurrentTrainingPlansScreen> {
  final TrainingShopApiService _api = TrainingShopApiService();

  bool _loading = true;
  String? _loadError;
  List<PaymentFlowDestination> _ownedDestinations = <PaymentFlowDestination>[];
  bool _openedFromAutoMode = false;

  static const Map<PaymentFlowDestination, _OwnedPlanViewData> _viewData =
      <PaymentFlowDestination, _OwnedPlanViewData>{
        PaymentFlowDestination.onlineCoaching: _OwnedPlanViewData(
          title: 'Training & Nutrition',
          subtitle:
              'Open your coaching plan with training and nutrition guidance.',
          icon: Icons.self_improvement_rounded,
          accent: Color(0xFF4BCDC0),
        ),
        PaymentFlowDestination.trainingPlan: _OwnedPlanViewData(
          title: 'Training plan',
          subtitle: 'Open your day-to-day training plan and schedule.',
          icon: Icons.fitness_center_rounded,
          accent: Color(0xFFF2B31A),
        ),
        PaymentFlowDestination.personalTraining: _OwnedPlanViewData(
          title: 'Personal training',
          subtitle: 'Open your personal training sessions and assigned plan.',
          icon: Icons.person_pin_circle_outlined,
          accent: Color(0xFFB45CFF),
        ),
      };

  @override
  void initState() {
    super.initState();
    _loadOwnedPlans();
  }

  Future<void> _loadOwnedPlans() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }

    try {
      final ordered = await TrainingPlanOwnershipResolver.loadOwnedDestinations(
        _api,
      );
      final preferred = widget.preferredDestination;
      if (preferred != null && ordered.remove(preferred)) {
        ordered.insert(0, preferred);
      }

      if (!mounted) return;
      setState(() {
        _ownedDestinations = ordered;
      });

      if (widget.autoOpenOwnedPlan &&
          !_openedFromAutoMode &&
          ordered.length == 1) {
        _openedFromAutoMode = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _openOwnedPlan(ordered.first);
        });
      }
    } on DioException catch (e) {
      final payload = e.response?.data;
      final message = payload is Map && payload['message'] != null
          ? payload['message'].toString()
          : payload is Map && payload['error'] != null
          ? payload['error'].toString()
          : 'Failed to load your current plans';
      if (!mounted) return;
      setState(() => _loadError = message);
      CustomSnackbar.show(message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadError = 'Failed to load your current plans');
      CustomSnackbar.show('Failed to load your current plans');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _goToPurchasePlan() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChooseTrainingPlanScreen()));
  }

  void _openOwnedPlan(PaymentFlowDestination destination) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _screenForDestination(destination)),
    );
  }

  Widget _screenForDestination(PaymentFlowDestination destination) {
    switch (destination) {
      case PaymentFlowDestination.onlineCoaching:
        return const TrainingNutritionScreen();
      case PaymentFlowDestination.trainingPlan:
        return const DailyTrainingPlanScreen();
      case PaymentFlowDestination.personalTraining:
        return const PersonalTrainingPlanScreen();
      case PaymentFlowDestination.shop:
      case PaymentFlowDestination.homeMenu:
        return const HomeMenuScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 50, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (widget.showBackButton)
                        Transform.translate(
                          offset: const Offset(-15, 0),
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                              color: Color(0xFFC9CDD3),
                            ),
                            splashRadius: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 8),
                      const SizedBox(width: 6),
                      const Text(
                        'Current plan',
                        style: TextStyle(
                          color: Color(0xFFE6E7EA),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Plans already purchased on your account',
                    style: TextStyle(
                      color: Color(0xFF9FA5AE),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: CircularProgressIndicator(
                          color: Color(0xFFF3B41A),
                        ),
                      ),
                    )
                  else ...[
                    if (_loadError != null)
                      _NoticeCard(text: _loadError!, onRetry: _loadOwnedPlans),
                    if (_ownedDestinations.isEmpty)
                      const _EmptyCurrentPlans()
                    else ...[
                      ...List.generate(_ownedDestinations.length, (index) {
                        final destination = _ownedDestinations[index];
                        final data = _viewData[destination]!;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == _ownedDestinations.length - 1
                                ? 0
                                : 12,
                          ),
                          child: _OwnedPlanCard(
                            title: data.title,
                            subtitle: data.subtitle,
                            icon: data.icon,
                            accent: data.accent,
                            onTap: () => _openOwnedPlan(destination),
                          ),
                        );
                      }),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _goToPurchasePlan,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFFF2B31A),
                              width: 1.1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Purchase new plan',
                            style: TextStyle(
                              color: Color(0xFFF2B31A),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OwnedPlanViewData {
  const _OwnedPlanViewData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
}

class _OwnedPlanCard extends StatelessWidget {
  const _OwnedPlanCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: const Color(0xFF12151C),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2F3541), width: 1.1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFFF4F6F8),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFFA2A8B3),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFC7CBD2),
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCurrentPlans extends StatelessWidget {
  const _EmptyCurrentPlans();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF12151C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2F3541), width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'No purchased training plan found yet.',
            style: TextStyle(
              color: Color(0xFFE7EAF0),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.text, required this.onRetry});

  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF3C2A2A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF6E4141), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFFFCFCF), size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFFFDEDE),
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
