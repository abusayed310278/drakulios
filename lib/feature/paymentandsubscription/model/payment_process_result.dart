class PaymentProcessResult {
  const PaymentProcessResult({
    required this.success,
    this.message,
    this.clearShopCart = false,
  });

  final bool success;
  final String? message;
  final bool clearShopCart;

  factory PaymentProcessResult.failure(String message) {
    return PaymentProcessResult(success: false, message: message);
  }
}
