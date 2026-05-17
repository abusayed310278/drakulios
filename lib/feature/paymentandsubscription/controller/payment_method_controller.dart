import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../core/constants/payment_config.dart';
import '../../../core/network/api_service/token_meneger.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import '../model/payment_process_request.dart';
import '../model/payment_process_result.dart';
import '../view/payment_flow_destination.dart';

class PaymentMethodController {
  PaymentMethodController({TrainingShopApiService? api})
    : _api = api ?? TrainingShopApiService();

  final TrainingShopApiService _api;

  static const Duration paymentRequestTimeout = Duration(seconds: 20);
  static const Duration stripeSettingsTimeout = Duration(seconds: 15);

  Future<PaymentProcessResult> processPayment(PaymentProcessRequest request) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null || token.trim().isEmpty) {
        return PaymentProcessResult.failure(
          'Your session has expired. Please log in again',
        );
      }

      final normalizedShippingAddress = request.shippingAddress?.trim() ?? '';
      if (request.flowDestination == PaymentFlowDestination.shop &&
          normalizedShippingAddress.isEmpty) {
        return PaymentProcessResult.failure(
          'Shipping address is required before payment',
        );
      }

      final stripeSetupError = await _ensureStripeConfigured().timeout(
        paymentRequestTimeout,
        onTimeout: () => 'Payment setup timed out. Please try again',
      );
      if (stripeSetupError != null) {
        return PaymentProcessResult.failure(stripeSetupError);
      }

      final hasSubscriptionInfo =
          request.subscriptionId != null &&
          request.subscriptionId!.trim().isNotEmpty &&
          request.billingPeriod != null &&
          request.billingPeriod!.trim().isNotEmpty;

      final uid = await TokenManager.getUid() ?? await TokenManager.getUidFromToken();

      final paymentRes = await _api
          .createPayment(
            userId: uid,
            price: request.amount,
            subscriptionId: hasSubscriptionInfo ? request.subscriptionId : null,
            billingPeriod: hasSubscriptionInfo ? request.billingPeriod : null,
            serviceType: _serviceTypeForDestination(request.flowDestination),
            shippingAddress: normalizedShippingAddress.isEmpty
                ? null
                : normalizedShippingAddress,
            paymentMethod: request.selectedMethod == 0 ? 'card' : 'stripe',
            useTestStripe: false,
          )
          .timeout(
            paymentRequestTimeout,
            onTimeout: () => throw TimeoutException('Payment request timed out'),
          );

      if (paymentRes['success'] != true && paymentRes['paymentIntentId'] == null) {
        return PaymentProcessResult.failure('Payment initialization failed');
      }

      final clientSecret = paymentRes['clientSecret']?.toString();
      final paymentIntentId = paymentRes['paymentIntentId']?.toString();
      if (clientSecret == null || clientSecret.isEmpty) {
        return PaymentProcessResult.failure('Payment client secret not found');
      }
      if (paymentIntentId == null || paymentIntentId.isEmpty) {
        return PaymentProcessResult.failure('Payment id not found');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Drakulios',
          paymentIntentClientSecret: clientSecret,
          returnURL: '${PaymentConfig.stripeUrlScheme}://stripe-redirect',
        ),
      );
      await Stripe.instance.presentPaymentSheet();

      await _cachePurchasedTrainingType(request.flowDestination);
      unawaited(_confirmPaymentInBackground(paymentIntentId));

      return PaymentProcessResult(
        success: true,
        clearShopCart: request.flowDestination == PaymentFlowDestination.shop,
      );
    } on MissingPluginException {
      return PaymentProcessResult.failure(
        'Stripe SDK not loaded. Rebuild app: flutter clean, pub get, pod install, run.',
      );
    } on TimeoutException catch (e) {
      final message = e.message?.trim();
      return PaymentProcessResult.failure(
        message != null && message.isNotEmpty
            ? message
            : 'Payment is taking too long. Please try again',
      );
    } on PlatformException catch (e) {
      final msg = (e.message?.trim().isNotEmpty ?? false)
          ? e.message!.trim()
          : e.toString();
      return PaymentProcessResult.failure(msg);
    } on StripeConfigException catch (e) {
      final msg = e.message.trim();
      return PaymentProcessResult.failure(
        msg.isEmpty ? 'Stripe configuration error' : msg,
      );
    } on StripeException catch (e) {
      final localized = (e.error.localizedMessage ?? '').toLowerCase();
      final isCanceled =
          e.error.code == FailureCode.Canceled || localized.contains('cancel');
      if (isCanceled) {
        return PaymentProcessResult.failure('Payment Canceled');
      }
      return PaymentProcessResult.failure(_friendlyStripeError(e));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return PaymentProcessResult.failure(
          'Your session has expired. Please log in again',
        );
      }
      return PaymentProcessResult.failure(
        _friendlyDioError(e, fallback: 'Payment failed'),
      );
    } catch (e) {
      return PaymentProcessResult.failure(
        _friendlyError(e, fallback: 'Payment failed. Please try again'),
      );
    }
  }

  String _friendlyDioError(DioException error, {required String fallback}) {
    final data = error.response?.data;
    String? message;

    if (data is Map) {
      message =
          data['error']?.toString() ??
          data['message']?.toString() ??
          data['details']?.toString();
    } else if (data != null) {
      message = data.toString();
    }

    final normalized = message?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      final lower = normalized.toLowerCase();
      final looksLikeHtml =
          lower.contains('<!doctype html') ||
          lower.contains('<html') ||
          lower.contains('</html>') ||
          lower.contains('<body');
      final looksLikeHostError =
          lower.contains('unexpected error') ||
          lower.contains('try again in a few seconds') ||
          lower.contains('server error');

      if (!looksLikeHtml && !looksLikeHostError) {
        return normalized;
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Payment server timed out. Please try again';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Cannot reach payment server. Check your internet connection';
    }

    final statusCode = error.response?.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return 'Payment server is unavailable right now. Please try again shortly';
    }

    return fallback;
  }

  String _friendlyError(Object error, {required String fallback}) {
    final asString = error.toString().trim();
    if (asString.isNotEmpty && !asString.startsWith('Instance of')) {
      return asString;
    }
    try {
      final dynamicError = error as dynamic;
      final message = dynamicError.message?.toString().trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    } catch (_) {}
    return fallback;
  }

  Future<String?> _ensureStripeConfigured() async {
    try {
      final config = await _api.getPaymentConfig().timeout(
        paymentRequestTimeout,
        onTimeout: () => throw TimeoutException(
          'Loading payment configuration is taking too long',
        ),
      );
      final data = config['data'];
      final serverKey = data is Map ? data['publishableKey']?.toString() : null;
      if (serverKey != null && serverKey.trim().isNotEmpty) {
        final applyError = await _applyStripeKey(serverKey);
        if (applyError == null) {
          return null;
        }
      }
    } catch (_) {
      // Fallback to local and current Stripe keys below.
    }

    const localKey = PaymentConfig.stripePublishableKey;
    if (localKey.isNotEmpty) {
      final applyError = await _applyStripeKey(localKey);
      if (applyError == null) {
        return null;
      }
    }

    try {
      final existing = Stripe.publishableKey.trim();
      if (existing.isNotEmpty) {
        final applyError = await _applyStripeKey(existing);
        if (applyError == null) {
          return null;
        }
      }
    } catch (_) {}

    return 'Stripe publishable key is missing or invalid';
  }

  Future<String?> _applyStripeKey(String key) async {
    final normalized = key.trim();
    if (normalized.isEmpty || !normalized.startsWith('pk_')) {
      return 'Stripe publishable key is missing or invalid';
    }

    try {
      final current = (() {
        try {
          return Stripe.publishableKey.trim();
        } catch (_) {
          return '';
        }
      })();

      if (current != normalized) {
        Stripe.publishableKey = normalized;
      }

      Stripe.urlScheme = PaymentConfig.stripeUrlScheme;
      await Stripe.instance.applySettings().timeout(
        stripeSettingsTimeout,
        onTimeout: () => throw TimeoutException('Stripe settings apply timed out'),
      );
      return null;
    } on MissingPluginException {
      return 'Stripe SDK not loaded. Rebuild app: flutter clean, pub get, pod install, run.';
    } on StripeConfigException catch (e) {
      final message = e.message.trim();
      return message.isEmpty ? 'Stripe configuration error' : message;
    } on TimeoutException {
      return 'Stripe setup timed out. Please restart app and try again';
    }
  }

  String _friendlyStripeError(StripeException e) {
    final stripeMsg = e.error.localizedMessage?.trim();
    if (stripeMsg == null || stripeMsg.isEmpty) {
      return 'Payment failed';
    }
    final lower = stripeMsg.toLowerCase();
    if (lower.contains('no such payment_intent') ||
        lower.contains('payment intent') && lower.contains('invalid')) {
      return 'Stripe key mismatch. Please sync publishable key with backend';
    }
    return stripeMsg;
  }

  Future<void> _cachePurchasedTrainingType(
    PaymentFlowDestination destination,
  ) async {
    final serviceType = _serviceTypeForDestination(destination);
    if (serviceType == null) {
      return;
    }
    await TokenManager.saveServiceType(serviceType);
  }

  String? _serviceTypeForDestination(PaymentFlowDestination destination) {
    switch (destination) {
      case PaymentFlowDestination.onlineCoaching:
        return 'online coaching';
      case PaymentFlowDestination.trainingPlan:
        return 'training plan';
      case PaymentFlowDestination.personalTraining:
        return 'personal training';
      case PaymentFlowDestination.homeMenu:
      case PaymentFlowDestination.shop:
        return null;
    }
  }

  Future<void> _confirmPaymentInBackground(String paymentIntentId) async {
    try {
      final response = await _api
          .confirmPayment(paymentIntentId: paymentIntentId)
          .timeout(
            paymentRequestTimeout,
            onTimeout: () => throw TimeoutException('Payment confirmation timed out'),
          );
      if (response['success'] != true) {
        // keep silent for background confirmation
      }
    } catch (_) {
      // keep silent for background confirmation
    }
  }
}
