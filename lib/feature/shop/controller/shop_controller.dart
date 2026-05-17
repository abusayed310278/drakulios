import 'package:dio/dio.dart';

import '../../../core/network/api_service/training_shop_api_service.dart';
import '../model/shop_action_result.dart';

class ShopController {
  ShopController({TrainingShopApiService? api})
    : _api = api ?? TrainingShopApiService();

  final TrainingShopApiService _api;

  Future<List<Map<String, dynamic>>> loadProducts() async {
    return _api.getProducts();
  }

  Future<ShopActionResult> addToCart({required String productId}) async {
    try {
      await _api.addToCart(productId: productId, quantity: 1);
      return const ShopActionResult(success: true, message: 'Added');
    } on DioException catch (e) {
      return ShopActionResult(
        success: false,
        message: _dioMessage(e, 'Failed to add product to cart'),
      );
    } catch (_) {
      return const ShopActionResult(
        success: false,
        message: 'Failed to add product to cart',
      );
    }
  }

  bool matchesCategory(Map<String, dynamic> item, String categoryKey) {
    final resolvedCategory = _resolveCategory(item);
    if (resolvedCategory != null) {
      return resolvedCategory == categoryKey;
    }

    if (categoryKey == 'equipments') return true;
    return false;
  }

  String? _resolveCategory(Map<String, dynamic> item) {
    final categoryRaw = item['category'];
    final categoryName = (() {
      if (categoryRaw is Map) {
        return (categoryRaw['name'] ??
                categoryRaw['title'] ??
                categoryRaw['slug'] ??
                categoryRaw['type'])
            ?.toString();
      }
      return categoryRaw?.toString();
    })();

    final parts = <String>[
      categoryName ?? '',
      item['type']?.toString() ?? '',
      item['productType']?.toString() ?? '',
      item['name']?.toString() ?? '',
      item['description']?.toString() ?? '',
    ];

    final tags = item['tags'];
    if (tags is List) {
      parts.addAll(tags.map((e) => e.toString()));
    }

    final raw = parts.join(' ').toLowerCase();
    if (raw.trim().isEmpty) return null;

    if (_looksLikeApparel(raw)) return 'apparel';
    if (_looksLikeDrink(raw)) return 'drink';
    if (_looksLikeEquipment(raw)) return 'equipments';
    return null;
  }

  String resolveCardImage(Map<String, dynamic> item, String fallbackImage) {
    final raw = item['image'];
    if (raw is List && raw.isNotEmpty) {
      final first = raw.first;
      if (first is Map && first['url'] != null) {
        final url = first['url'].toString().trim();
        if (url.isNotEmpty) return url;
      }
      final direct = first.toString().trim();
      if (direct.isNotEmpty) return direct;
    }
    return fallbackImage;
  }

  String dioLoadMessage(DioException e) {
    return _dioMessage(e, 'Failed to load shop items');
  }

  String _dioMessage(DioException e, String fallback) {
    final d = e.response?.data;
    if (d is Map && d['message'] != null) {
      return d['message'].toString();
    }
    return fallback;
  }

  bool _looksLikeEquipment(String raw) {
    return raw.contains('equipment') ||
        raw.contains('equipments') ||
        raw.contains('machine') ||
        raw.contains('gym') ||
        raw.contains('dumbbell') ||
        raw.contains('barbell') ||
        raw.contains('kettlebell') ||
        raw.contains('bench') ||
        raw.contains('treadmill') ||
        raw.contains('bike') ||
        raw.contains('cross trainer') ||
        raw.contains('plate') ||
        raw.contains('rope') ||
        raw.contains('mat');
  }

  bool _looksLikeApparel(String raw) {
    return raw.contains('apparel') ||
        raw.contains('cloth') ||
        raw.contains('wear') ||
        raw.contains('shirt') ||
        raw.contains('hoodie') ||
        raw.contains('pant') ||
        raw.contains('jogger') ||
        raw.contains('short') ||
        raw.contains('cap') ||
        raw.contains('socks');
  }

  bool _looksLikeDrink(String raw) {
    return raw.contains('drink') ||
        raw.contains('beverage') ||
        raw.contains('water') ||
        raw.contains('juice') ||
        raw.contains('shake') ||
        raw.contains('protein') ||
        raw.contains('electrolyte');
  }
}
