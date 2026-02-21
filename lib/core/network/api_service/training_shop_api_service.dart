import 'package:dio/dio.dart';

import '../../constants/api_endpoints.dart';
import 'api_client.dart';

class TrainingShopApiService {
  TrainingShopApiService({ApiClient? client})
    : _client = client ?? ApiClient(ApiEndpoints.baseUrl);

  final ApiClient _client;

  Future<List<Map<String, dynamic>>> getTodayTrainings() async {
    final Response res = await _client.get(ApiEndpoints.trainingToday);
    return _toList(res.data);
  }

  Future<Map<String, dynamic>> getTodayTrainingsBundle() async {
    final Response res = await _client.get(ApiEndpoints.trainingToday);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<List<Map<String, dynamic>>> getTodayNutritions() async {
    final Response res = await _client.get(ApiEndpoints.nutritionToday);
    return _toList(res.data);
  }

  Future<Map<String, dynamic>> getTodayNutritionsBundle() async {
    final Response res = await _client.get(ApiEndpoints.nutritionToday);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<List<Map<String, dynamic>>> getSubscriptions() async {
    final Response res = await _client.get(ApiEndpoints.subscriptions);
    return _toList(res.data);
  }

  Future<List<Map<String, dynamic>>> getProducts() async {
    final Response res = await _client.get(ApiEndpoints.products);
    return _toList(res.data);
  }

  Future<Map<String, dynamic>> getProductById(String id) async {
    final Response res = await _client.get(ApiEndpoints.productById(id));
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> createProduct(
    Map<String, dynamic> payload,
  ) async {
    final Response res = await _client.post(
      ApiEndpoints.createProduct,
      data: payload,
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> updateProduct(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final Response res = await _client.put(
      ApiEndpoints.updateProduct(id),
      data: payload,
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> deleteProduct(String id) async {
    final Response res = await _client.delete(ApiEndpoints.deleteProduct(id));
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> addToCart({
    required String productId,
    int quantity = 1,
    String? size,
  }) async {
    final Response res = await _client.post(
      ApiEndpoints.cartAdd,
      data: {
        'productId': productId,
        'quantity': quantity,
        if (size != null && size.trim().isNotEmpty) 'size': size,
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> getCart() async {
    final Response res = await _client.get(ApiEndpoints.cart);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> updateCartItemQuantity({
    required String productId,
    required String action,
  }) async {
    final Response res = await _client.patch(
      ApiEndpoints.cartUpdateQuantity,
      data: {'productId': productId, 'action': action},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> removeCartItem({
    required String productId,
  }) async {
    final Response res = await _client.delete(
      ApiEndpoints.cartRemoveItem,
      data: {'productId': productId},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> clearCart() async {
    final Response res = await _client.delete(ApiEndpoints.cartClear);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> createPayment({
    required double price,
    String? userId,
    String? subscriptionId,
    String? billingPeriod,
    String? paymentMethod,
    bool useTestStripe = false,
  }) async {
    final Response res = await _client.post(
      ApiEndpoints.paymentCreate,
      data: {
        if (userId != null && userId.trim().isNotEmpty) 'userId': userId,
        'price': price,
        if (subscriptionId != null && subscriptionId.trim().isNotEmpty)
          'subscriptionId': subscriptionId,
        if (billingPeriod != null && billingPeriod.trim().isNotEmpty)
          'billingPeriod': billingPeriod,
        if (paymentMethod != null && paymentMethod.trim().isNotEmpty)
          'paymentMethod': paymentMethod,
        'useTestStripe': useTestStripe,
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> confirmPayment({
    required String paymentIntentId,
  }) async {
    final Response res = await _client.post(
      ApiEndpoints.paymentConfirm,
      data: {'paymentIntentId': paymentIntentId},
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> getPaymentConfig() async {
    final Response res = await _client.get(ApiEndpoints.paymentConfig);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> getPurchaseHistory() async {
    final Response res = await _client.get(ApiEndpoints.paymentHistory);
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> getMembershipSummary() async {
    final Response res = await _client.get(
      ApiEndpoints.paymentMembershipSummary,
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> getMyAttendance({int? year, int? month}) async {
    final query = <String, dynamic>{};
    if (year != null) query['year'] = year;
    if (month != null) query['month'] = month;
    final Response res = await _client.get(
      ApiEndpoints.attendanceMine,
      query: query.isEmpty ? null : query,
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> createTraining(
    Map<String, dynamic> payload,
  ) async {
    final Response res = await _client.post(
      ApiEndpoints.trainingCreate,
      data: payload,
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<List<Map<String, dynamic>>> getMyTrainings() async {
    final Response res = await _client.get(ApiEndpoints.trainingMine);
    return _toList(res.data);
  }

  List<Map<String, dynamic>> _toList(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (raw is Map && raw['data'] is List) {
      return (raw['data'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (raw is Map && raw['products'] is List) {
      return (raw['products'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }
}
