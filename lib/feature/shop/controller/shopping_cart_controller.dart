import 'package:dio/dio.dart';

import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../../core/network/api_service/user_api_service.dart';
import '../model/cart_item_ui.dart';
import '../model/cart_summary.dart';
import '../model/shop_action_result.dart';

class ShoppingCartController {
  ShoppingCartController({
    TrainingShopApiService? api,
    UserApiService? userApi,
  }) : _api = api ?? TrainingShopApiService(),
       _userApi = userApi ?? UserApiService();

  final TrainingShopApiService _api;
  final UserApiService _userApi;

  Future<String> loadShippingAddress() async {
    try {
      final res = await _userApi.getProfile();
      final dataRaw = res['data'];
      if (dataRaw is! Map) return '';
      return (dataRaw['address'] ?? '').toString().trim();
    } catch (_) {
      return '';
    }
  }

  Future<CartSummary> loadCart() async {
    final res = await _api.getCart();
    final data = res['data'];
    if (data is! Map) {
      return const CartSummary(
        items: <CartItemUi>[],
        subtotal: 0,
        tax: 0,
        total: 0,
      );
    }

    final itemsRaw = data['items'];
    final items = <CartItemUi>[];
    if (itemsRaw is List) {
      for (final rawItem in itemsRaw) {
        if (rawItem is! Map) continue;
        final item = Map<String, dynamic>.from(rawItem);
        final productRaw = item['product'];
        final product = productRaw is Map
            ? Map<String, dynamic>.from(productRaw)
            : <String, dynamic>{};
        items.add(
          CartItemUi(
            productId: (product['_id'] ?? item['product'] ?? '').toString(),
            name: (product['name'] ?? 'Product').toString(),
            price: _toDouble(product['price']),
            quantity: (item['quantity'] as num?)?.toInt() ?? 1,
          ),
        );
      }
    }

    return CartSummary(
      items: items,
      subtotal: _toDouble(data['subTotal']),
      tax: _toDouble(data['tax']),
      total: _toDouble(data['total']),
    );
  }

  Future<ShopActionResult> changeQuantity({
    required String productId,
    required String action,
  }) async {
    try {
      await _api.updateCartItemQuantity(productId: productId, action: action);
      return const ShopActionResult(success: true, message: 'Updated');
    } on DioException catch (e) {
      return ShopActionResult(
        success: false,
        message: _dioMessage(e, 'Failed to update cart'),
      );
    } catch (_) {
      return const ShopActionResult(
        success: false,
        message: 'Failed to update cart',
      );
    }
  }

  Future<ShopActionResult> removeItem(String productId) async {
    try {
      await _api.removeCartItem(productId: productId);
      return const ShopActionResult(success: true, message: 'Removed');
    } on DioException catch (e) {
      return ShopActionResult(
        success: false,
        message: _dioMessage(e, 'Failed to remove item'),
      );
    } catch (_) {
      return const ShopActionResult(
        success: false,
        message: 'Failed to remove item',
      );
    }
  }

  String loadCartError(Object error) {
    if (error is DioException) {
      return _dioMessage(error, 'Failed to load cart');
    }
    return 'Failed to load cart';
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _dioMessage(DioException e, String fallback) {
    final d = e.response?.data;
    if (d is Map && d['message'] != null) {
      return d['message'].toString();
    }
    return fallback;
  }
}
