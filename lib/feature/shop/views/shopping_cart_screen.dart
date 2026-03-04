import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/constants/assets.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import '../../paymentandsubscription/views/payment_flow_destination.dart';
import '../../paymentandsubscription/views/payment_method_screen.dart';
import 'widgets/shop_badge_state.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  final TrainingShopApiService _api = TrainingShopApiService();
  bool _loading = true;
  List<_CartItemUi> _items = <_CartItemUi>[];
  double _subtotal = 0;
  double _tax = 0;
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final res = await _api.getCart();
      final data = res['data'];
      if (data is Map) {
        final itemsRaw = data['items'];
        final items = <_CartItemUi>[];
        if (itemsRaw is List) {
          for (final rawItem in itemsRaw) {
            if (rawItem is! Map) continue;
            final item = Map<String, dynamic>.from(rawItem);
            final productRaw = item['product'];
            final product = productRaw is Map
                ? Map<String, dynamic>.from(productRaw)
                : <String, dynamic>{};
            items.add(
              _CartItemUi(
                productId: (product['_id'] ?? item['product'] ?? '').toString(),
                name: (product['name'] ?? 'Product').toString(),
                price: _toDouble(product['price']),
                quantity: (item['quantity'] as num?)?.toInt() ?? 1,
              ),
            );
          }
        }
        if (!mounted) return;
        final badgeCount = items.length;
        setState(() {
          _items = items;
          _subtotal = _toDouble(data['subTotal']);
          _tax = _toDouble(data['tax']);
          _total = _toDouble(data['total']);
        });
        ShopBadgeState.setCartCount(badgeCount);
      }
    } on DioException catch (e) {
      final d = e.response?.data;
      final msg = d is Map && d['message'] != null
          ? d['message'].toString()
          : 'Failed to load cart';
      CustomSnackbar.show(msg);
    } catch (_) {
      CustomSnackbar.show('Failed to load cart');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeQuantity({
    required String productId,
    required String action,
  }) async {
    try {
      await _api.updateCartItemQuantity(productId: productId, action: action);
      _loadCart();
    } on DioException catch (e) {
      final d = e.response?.data;
      final msg = d is Map && d['message'] != null
          ? d['message'].toString()
          : 'Failed to update cart';
      CustomSnackbar.show(msg);
    } catch (_) {
      CustomSnackbar.show('Failed to update cart');
    }
  }

  Future<void> _removeItem(String productId) async {
    try {
      await _api.removeCartItem(productId: productId);
      _loadCart();
    } on DioException catch (e) {
      final d = e.response?.data;
      final msg = d is Map && d['message'] != null
          ? d['message'].toString()
          : 'Failed to remove item';
      CustomSnackbar.show(msg);
    } catch (_) {
      CustomSnackbar.show('Failed to remove item');
    }
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
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
                        'Shopping Cart',
                        style: TextStyle(
                          color: Color(0xFFB1B1B1),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFF3B41A),
                        ),
                      ),
                    )
                  else if (_items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(
                        child: Text(
                          'Cart is empty',
                          style: TextStyle(
                            color: Color(0xFF9AA1AE),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      padding: const EdgeInsets.only(top: 6),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 220,
                          ),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return _CartItemCard(
                          image: Images.gym1Image,
                          title: item.name,
                          price: '\$${item.price.toStringAsFixed(2)}',
                          quantity: item.quantity,
                          onDecrease: () => _changeQuantity(
                            productId: item.productId,
                            action: 'decrement',
                          ),
                          onIncrease: () => _changeQuantity(
                            productId: item.productId,
                            action: 'increment',
                          ),
                          onRemove: () => _removeItem(item.productId),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                  _SummaryRow(
                    label: 'Subtotal',
                    value: '\$${_subtotal.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 4),
                  _SummaryRow(
                    label: 'Estimated Tax',
                    value: '\$${_tax.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 6),
                  _SummaryRow(
                    label: 'Total',
                    value: '\$${_total.toStringAsFixed(2)}',
                    bold: true,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _items.isEmpty
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PaymentMethodScreen(
                                    flowDestination:
                                        PaymentFlowDestination.shop,
                                    amount: _total,
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2B31A),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        disabledBackgroundColor: const Color(
                          0xFFF2B31A,
                        ).withValues(alpha: 0.45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Make Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.image,
    required this.title,
    required this.price,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final String image;
  final String title;
  final String price;
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x52F3B41A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF3B41A), width: 0.48),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(image, height: 90, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0x33F3B41A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFF3B41A),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            Images.deleteImage,
                            width: 14,
                            height: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 116,
                      height: 28,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0x33F3B41A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFF3B41A),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text(
                              'Quantity:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Row(
                                  children: [
                                    _QtyButton(
                                      icon: Icons.remove,
                                      onTap: onDecrease,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$quantity',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    _QtyButton(
                                      icon: Icons.add,
                                      onTap: onIncrease,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(icon, size: 12, color: Colors.black),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Colors.white,
      fontSize: bold ? 14 : 12,
      fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}

class _CartItemUi {
  const _CartItemUi({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  final String productId;
  final String name;
  final double price;
  final int quantity;
}
