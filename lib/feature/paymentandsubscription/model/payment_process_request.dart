import '../view/payment_flow_destination.dart';

class PaymentProcessRequest {
  const PaymentProcessRequest({
    required this.flowDestination,
    required this.amount,
    required this.selectedMethod,
    this.subscriptionId,
    this.billingPeriod,
    this.shippingAddress,
  });

  final PaymentFlowDestination flowDestination;
  final double amount;
  final int selectedMethod;
  final String? subscriptionId;
  final String? billingPeriod;
  final String? shippingAddress;
}
