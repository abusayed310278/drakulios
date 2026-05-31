import 'package:dio/dio.dart';

import '../../../core/network/api_service/training_shop_api_service.dart';
import '../model/shop_action_result.dart';
import '../model/shop_product_data.dart';

class ProductDetailController {
  ProductDetailController({TrainingShopApiService? api})
    : _api = api ?? TrainingShopApiService();

  final TrainingShopApiService _api;

  Future<ShopProductData?> loadFullProduct({
    required ShopProductData current,
    required String fallbackImage,
  }) async {
    if (current.id.isEmpty) return null;
    try {
      final res = await _api.getProductById(current.id);
      final raw = _normalizeProductPayload(res);
      return ShopProductData.fromRaw(raw, fallbackImage);
    } catch (_) {
      return null;
    }
  }

  Future<ShopActionResult> addToCart({
    required String productId,
    String? size,
    String? flavour,
  }) async {
    try {
      await _api.addToCart(
        productId: productId,
        quantity: 1,
        size: size,
        flavour: flavour,
      );
      return const ShopActionResult(success: true, message: 'Added');
    } on DioException catch (e) {
      final d = e.response?.data;
      if (d is Map && d['message'] != null) {
        return ShopActionResult(success: false, message: d['message'].toString());
      }
      return const ShopActionResult(
        success: false,
        message: 'Failed to add product to cart',
      );
    } catch (_) {
      return const ShopActionResult(
        success: false,
        message: 'Failed to add product to cart',
      );
    }
  }

  Map<String, dynamic> _normalizeProductPayload(Map<String, dynamic> payload) {
    final data = payload['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return payload;
  }
}
