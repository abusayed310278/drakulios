abstract final class PaymentConfig {
  const PaymentConfig._();

  static const String stripeUrlScheme = String.fromEnvironment(
    'STRIPE_URL_SCHEME',
    defaultValue: 'darkolious',
  );

  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'pk_test_51S6pMbRZVOYD6qjBukBi2VyPiTtIhzAyYzmfyAo4izzIwemOo7I3fUYELhxmTJeNln7zMiztFA4CKihsybqrJlo800nWzvIXZY',
  );
}
