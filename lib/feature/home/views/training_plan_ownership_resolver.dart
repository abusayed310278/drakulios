import '../../../core/network/api_service/token_meneger.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../paymentandsubscription/views/payment_flow_destination.dart';

class TrainingPlanOwnershipResolver {
  static const List<PaymentFlowDestination> _orderedDestinations =
      <PaymentFlowDestination>[
        PaymentFlowDestination.onlineCoaching,
        PaymentFlowDestination.trainingPlan,
        PaymentFlowDestination.personalTraining,
      ];

  static Future<List<PaymentFlowDestination>> loadOwnedDestinations(
    TrainingShopApiService api,
  ) async {
    final membershipFuture = api.getMembershipSummary();
    final purchaseHistoryFuture = api.getPurchaseHistory();
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

    return _orderedDestinations.where(owned.contains).toList();
  }

  static void _extractFromMembershipSummary(
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

  static void _extractFromPurchaseHistory(
    dynamic purchaseRaw,
    Set<PaymentFlowDestination> out,
  ) {
    if (purchaseRaw is! Map) return;
    final data = purchaseRaw['data'];
    if (data is! Map) return;
    _extractListOfMaps(data['purchases'], out);
  }

  static void _extractListOfMaps(dynamic raw, Set<PaymentFlowDestination> out) {
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

  static void _addFromLabel(String? rawLabel, Set<PaymentFlowDestination> out) {
    final destination = _destinationFromLabel(rawLabel);
    if (destination != null) out.add(destination);
  }

  static PaymentFlowDestination? _destinationFromLabel(String? label) {
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
