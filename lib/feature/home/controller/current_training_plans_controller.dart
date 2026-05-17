import 'package:dio/dio.dart';

import '../../../core/network/api_service/token_meneger.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../paymentandsubscription/view/payment_flow_destination.dart';

class CurrentTrainingPlansController {
  CurrentTrainingPlansController({TrainingShopApiService? api})
    : _api = api ?? TrainingShopApiService();

  final TrainingShopApiService _api;

  static const List<PaymentFlowDestination> orderedDestinations =
      <PaymentFlowDestination>[
        PaymentFlowDestination.onlineCoaching,
        PaymentFlowDestination.trainingPlan,
        PaymentFlowDestination.personalTraining,
      ];

  Future<List<PaymentFlowDestination>> loadOwnedDestinations({
    PaymentFlowDestination? preferredDestination,
  }) async {
    final membershipFuture = _api.getMembershipSummary();
    final purchaseHistoryFuture = _api.getPurchaseHistory();
    final serviceTypeFuture = TokenManager.getServiceType();

    final results = await Future.wait<dynamic>(<Future<dynamic>>[
      membershipFuture,
      purchaseHistoryFuture,
      serviceTypeFuture,
    ]);

    final owned = <PaymentFlowDestination>{};
    _extractFromMembershipSummary(results[0], owned);
    _extractFromPurchaseHistory(results[1], owned);
    _addFromLabel(results[2]?.toString(), owned);

    final ordered = orderedDestinations.where(owned.contains).toList();
    if (preferredDestination != null && ordered.remove(preferredDestination)) {
      ordered.insert(0, preferredDestination);
    }
    return ordered;
  }

  String readErrorMessage(Object error, {required String fallback}) {
    if (error is DioException) {
      final payload = error.response?.data;
      if (payload is Map && payload['message'] != null) {
        final message = payload['message'].toString().trim();
        if (message.isNotEmpty) return message;
      }
      if (payload is Map && payload['error'] != null) {
        final message = payload['error'].toString().trim();
        if (message.isNotEmpty) return message;
      }
    }
    return fallback;
  }

  void _extractFromMembershipSummary(
    dynamic summaryRaw,
    Set<PaymentFlowDestination> out,
  ) {
    if (summaryRaw is! Map) return;
    final data = summaryRaw['data'];
    if (data is! Map) return;

    _addFromLabel(data['planName']?.toString(), out);
    _addFromLabel(data['membershipName']?.toString(), out);
    _addFromLabel(data['subscriptionName']?.toString(), out);
    _addFromLabel(data['serviceType']?.toString(), out);

    _extractListOfMaps(data['plans'], out);
    _extractListOfMaps(data['memberships'], out);
    _extractListOfMaps(data['subscriptions'], out);
  }

  void _extractFromPurchaseHistory(
    dynamic purchaseRaw,
    Set<PaymentFlowDestination> out,
  ) {
    if (purchaseRaw is! Map) return;
    final data = purchaseRaw['data'];
    if (data is! Map) return;
    _extractListOfMaps(data['purchases'], out);
  }

  void _extractListOfMaps(dynamic raw, Set<PaymentFlowDestination> out) {
    if (raw is! List) return;
    for (final item in raw) {
      if (item is! Map) continue;
      _addFromLabel(item['title']?.toString(), out);
      _addFromLabel(item['name']?.toString(), out);
      _addFromLabel(item['planName']?.toString(), out);
      _addFromLabel(item['subscriptionName']?.toString(), out);
      _addFromLabel(item['serviceType']?.toString(), out);
      _addFromLabel(item['type']?.toString(), out);
      _addFromLabel(item['category']?.toString(), out);
    }
  }

  void _addFromLabel(String? rawLabel, Set<PaymentFlowDestination> out) {
    final destination = _destinationFromLabel(rawLabel);
    if (destination != null) out.add(destination);
  }

  PaymentFlowDestination? _destinationFromLabel(String? label) {
    final value = (label ?? '').trim().toLowerCase();
    if (value.isEmpty) return null;

    if (value.contains('personal training') || value.contains('personal')) {
      return PaymentFlowDestination.personalTraining;
    }
    if (value.contains('online coaching') ||
        value.contains('coaching') ||
        value.contains('nutrition')) {
      return PaymentFlowDestination.onlineCoaching;
    }
    if (value.contains('training plan') ||
        value.contains('daily training') ||
        value == 'training') {
      return PaymentFlowDestination.trainingPlan;
    }
    return null;
  }
}
