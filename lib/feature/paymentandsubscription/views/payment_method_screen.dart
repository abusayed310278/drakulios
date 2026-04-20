import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dio/dio.dart';

import '../../../core/constants/assets.dart';
import '../../../core/constants/payment_config.dart';
import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/network/api_service/token_meneger.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../shop/views/widgets/shop_badge_state.dart';
import 'payment_flow_destination.dart';
import 'payment_success_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({
    super.key,
    this.flowDestination = PaymentFlowDestination.homeMenu,
    this.amount = 49,
    this.subscriptionId,
    this.billingPeriod,
    this.shippingAddress,
  });

  final PaymentFlowDestination flowDestination;
  final double amount;
  final String? subscriptionId;
  final String? billingPeriod;
  final String? shippingAddress;

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final TrainingShopApiService _api = TrainingShopApiService();
  int _selectedMethod = 0;
  bool _isPaying = false;
  bool _navigatedToSuccess = false;
  static const Duration _paymentRequestTimeout = Duration(seconds: 20);
  static const Duration _stripeSettingsTimeout = Duration(seconds: 15);

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
      if (message != null && message.isNotEmpty) return message;
    } catch (_) {}
    return fallback;
  }

  Future<bool> _applyStripeKey(String key) async {
    final normalized = key.trim();
    if (normalized.isEmpty || !normalized.startsWith('pk_')) return false;
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
        _stripeSettingsTimeout,
        onTimeout: () =>
            throw TimeoutException('Stripe settings apply timed out'),
      );
      return true;
    } on MissingPluginException {
      CustomSnackbar.show(
        'Stripe SDK not loaded. Rebuild app: flutter clean, pub get, pod install, run.',
      );
      return false;
    } on StripeConfigException catch (e) {
      final msg = e.message.trim();
      CustomSnackbar.show(msg.isEmpty ? 'Stripe configuration error' : msg);
      return false;
    } on TimeoutException {
      CustomSnackbar.show(
        'Stripe setup timed out. Please restart app and try again',
      );
      return false;
    }
  }

  Future<bool> _ensureStripeConfigured() async {
    // Always prefer backend key so it matches the server secret key/account.
    try {
      final config = await _api.getPaymentConfig().timeout(
        _paymentRequestTimeout,
        onTimeout: () => throw TimeoutException(
          'Loading payment configuration is taking too long',
        ),
      );
      final data = config['data'];
      final serverKey = data is Map ? data['publishableKey']?.toString() : null;
      if (serverKey != null && serverKey.trim().isNotEmpty) {
        final applied = await _applyStripeKey(serverKey);
        if (applied) return true;
      }
    } on TimeoutException catch (e) {
      debugPrint('Stripe config timeout: ${e.message}');
      // Fallback to local/env key below.
    } on DioException catch (e) {
      debugPrint(
        'Stripe config request failed: ${_friendlyDioError(e, fallback: e.toString())}',
      );
      // Fallback to local/env key below.
    } catch (e) {
      debugPrint('Stripe config unexpected error: $e');
      // Fallback to local/env key below.
    }

    const localKey = PaymentConfig.stripePublishableKey;
    if (localKey.isNotEmpty) {
      final applied = await _applyStripeKey(localKey);
      if (applied) {
        return true;
      }
    }

    // Final fallback: try currently loaded key if any.
    try {
      final existing = Stripe.publishableKey.trim();
      if (existing.isNotEmpty) {
        final applied = await _applyStripeKey(existing);
        if (applied) return true;
      }
    } catch (_) {}

    CustomSnackbar.show('Stripe publishable key is missing or invalid');
    return false;
  }

  String _friendlyStripeError(StripeException e) {
    final stripeMsg = e.error.localizedMessage?.trim();
    if (stripeMsg == null || stripeMsg.isEmpty) return 'Payment failed';
    final lower = stripeMsg.toLowerCase();
    if (lower.contains('no such payment_intent') ||
        lower.contains('payment intent') && lower.contains('invalid')) {
      return 'Stripe key mismatch. Please sync publishable key with backend';
    }
    return stripeMsg;
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

  Future<void> _cachePurchasedTrainingType() async {
    final serviceType = _serviceTypeForDestination(widget.flowDestination);
    if (serviceType == null) return;
    await TokenManager.saveServiceType(serviceType);
  }

  void _goToSuccessScreen() {
    if (!mounted || _navigatedToSuccess) return;
    _navigatedToSuccess = true;
    if (widget.flowDestination == PaymentFlowDestination.shop) {
      ShopBadgeState.setCartCount(0);
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            PaymentSuccessScreen(flowDestination: widget.flowDestination),
      ),
    );
  }

  Future<void> _confirmPaymentInBackground(String paymentIntentId) async {
    try {
      final confirmRes = await _api
          .confirmPayment(paymentIntentId: paymentIntentId)
          .timeout(
            _paymentRequestTimeout,
            onTimeout: () =>
                throw TimeoutException('Payment confirmation timed out'),
          );
      if (confirmRes['success'] != true) {
        debugPrint('Payment confirm API returned non-success: $confirmRes');
      }
    } catch (e) {
      debugPrint('Payment confirm API failed: $e');
    }
  }

  Future<void> _handlePay() async {
    if (_isPaying) return;
    setState(() => _isPaying = true);
    try {
      final token = await TokenManager.getToken();
      if (token == null || token.trim().isEmpty) {
        CustomSnackbar.show('Your session has expired. Please log in again');
        return;
      }
      final normalizedShippingAddress = widget.shippingAddress?.trim() ?? '';
      if (widget.flowDestination == PaymentFlowDestination.shop &&
          normalizedShippingAddress.isEmpty) {
        CustomSnackbar.show('Shipping address is required before payment');
        return;
      }

      final stripeReady = await _ensureStripeConfigured().timeout(
        _paymentRequestTimeout,
        onTimeout: () => false,
      );
      if (!stripeReady) return;

      final hasSubscriptionInfo =
          widget.subscriptionId != null &&
          widget.subscriptionId!.trim().isNotEmpty &&
          widget.billingPeriod != null &&
          widget.billingPeriod!.trim().isNotEmpty;

      final uid =
          await TokenManager.getUid() ?? await TokenManager.getUidFromToken();

      final paymentRes = await _api
          .createPayment(
            userId: uid,
            price: widget.amount,
            subscriptionId: hasSubscriptionInfo ? widget.subscriptionId : null,
            billingPeriod: hasSubscriptionInfo ? widget.billingPeriod : null,
            serviceType: _serviceTypeForDestination(widget.flowDestination),
            shippingAddress: normalizedShippingAddress.isEmpty
                ? null
                : normalizedShippingAddress,
            paymentMethod: _selectedMethod == 0 ? 'card' : 'stripe',
            useTestStripe: false,
          )
          .timeout(
            _paymentRequestTimeout,
            onTimeout: () =>
                throw TimeoutException('Payment request timed out'),
          );

      if (paymentRes['success'] != true &&
          paymentRes['paymentIntentId'] == null) {
        CustomSnackbar.show('Payment initialization failed');
        return;
      }

      final clientSecret = paymentRes['clientSecret']?.toString();
      final paymentIntentId = paymentRes['paymentIntentId']?.toString();
      if (clientSecret == null || clientSecret.isEmpty) {
        CustomSnackbar.show('Payment client secret not found');
        return;
      }
      if (paymentIntentId == null || paymentIntentId.isEmpty) {
        CustomSnackbar.show('Payment id not found');
        return;
      }

      try {
        debugPrint('Stripe: init payment sheet');
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            merchantDisplayName: 'Drakulios',
            paymentIntentClientSecret: clientSecret,
            returnURL: '${PaymentConfig.stripeUrlScheme}://stripe-redirect',
          ),
        );
        debugPrint('Stripe: present payment sheet');
        await Stripe.instance.presentPaymentSheet();
        debugPrint('Stripe: payment sheet completed');
        await _cachePurchasedTrainingType();
        _goToSuccessScreen();
        unawaited(_confirmPaymentInBackground(paymentIntentId));
        return;
      } on MissingPluginException {
        CustomSnackbar.show(
          'Stripe SDK not loaded. Rebuild app: flutter clean, pub get, pod install, run.',
        );
        return;
      } on TimeoutException catch (e) {
        final msg = e.message?.trim();
        CustomSnackbar.show(
          msg != null && msg.isNotEmpty ? msg : 'Payment timed out',
        );
        return;
      } on PlatformException catch (e) {
        final msg = (e.message?.trim().isNotEmpty ?? false)
            ? e.message!.trim()
            : e.toString();
        CustomSnackbar.show(msg);
        return;
      } on StripeConfigException catch (e) {
        final msg = e.message.trim();
        CustomSnackbar.show(msg.isEmpty ? 'Stripe configuration error' : msg);
        return;
      } on StripeException catch (e) {
        final localized = (e.error.localizedMessage ?? '').toLowerCase();
        final isCanceled =
            e.error.code == FailureCode.Canceled ||
            localized.contains('cancel');
        if (isCanceled) {
          CustomSnackbar.show('Payment Canceled');
        } else {
          CustomSnackbar.show(_friendlyStripeError(e));
        }
        return;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        CustomSnackbar.show('Your session has expired. Please log in again');
        return;
      }

      CustomSnackbar.show(_friendlyDioError(e, fallback: 'Payment failed'));
    } on TimeoutException catch (e) {
      final msg = e.message?.trim();
      CustomSnackbar.show(
        msg != null && msg.isNotEmpty
            ? msg
            : 'Payment is taking too long. Please try again',
      );
    } catch (e) {
      CustomSnackbar.show(
        _friendlyError(e, fallback: 'Payment failed. Please try again'),
      );
    } finally {
      if (mounted) setState(() => _isPaying = false);
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
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 40, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
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
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Choose Payment Method',
                          style: TextStyle(
                            color: Color(0xFFE6E7EA),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _PaymentMethodCard(
                      title: 'Debit / Credit Card',
                      subtitle: 'Visa, Mastercard',
                      leading: const _CardIcon(),
                      selected: _selectedMethod == 0,
                      onTap: () => setState(() => _selectedMethod = 0),
                    ),
                    const SizedBox(height: 12),
                    _PaymentMethodCard(
                      title: 'Stripe',
                      subtitle: 'Pay with Stripe',
                      leading: const _StripeBadge(),
                      selected: _selectedMethod == 1,
                      onTap: () => setState(() => _selectedMethod = 1),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            color: Color.fromARGB(255, 232, 235, 240),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '\$${widget.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isPaying ? null : _handlePay,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2B31A),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isPaying
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Pay \$${widget.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          Images.protectImage,
                          width: 14,
                          height: 14,
                          color: const Color(0xFFB1B1B1),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Your payment is encrypted and secure',
                          style: TextStyle(
                            color: Color(0xFFB1B1B1),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget leading;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0C11),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFFF2B31A)
                  : const Color(0xFF2A2F39),
              width: 1.2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFFF4F5F7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF9EA3AA),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardIcon extends StatelessWidget {
  const _CardIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF1F7AE0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.credit_card, size: 16, color: Colors.white),
    );
  }
}

class _StripeBadge extends StatelessWidget {
  const _StripeBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Center(
        child: Text(
          'stripe',
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
