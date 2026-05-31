import 'package:flutter/material.dart';

import '../../../core/language/translated_text.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/constants/assets.dart';
import '../controller/shopping_cart_controller.dart';
import '../model/cart_item_ui.dart';
import '../../paymentandsubscription/view/payment_flow_destination.dart';
import '../../paymentandsubscription/view/payment_method_screen.dart';
import '../widgets/shop_badge_state.dart';

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  final ShoppingCartController _controller = ShoppingCartController();
  final TextEditingController _shippingAddressController =
      TextEditingController();
  bool _loading = true;
  List<CartItemUi> _items = <CartItemUi>[];
  double _subtotal = 0;
  double _tax = 0;
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _loadShippingAddress();
    _loadCart();
  }

  @override
  void dispose() {
    _shippingAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadShippingAddress() async {
    final address = await _controller.loadShippingAddress();
    if (!mounted || address.isEmpty) return;
    _shippingAddressController.text = address;
  }

  Future<void> _loadCart() async {
    try {
      final summary = await _controller.loadCart();
      if (!mounted) return;
      setState(() {
        _items = summary.items;
        _subtotal = summary.subtotal;
        _tax = summary.tax;
        _total = summary.total;
      });
      ShopBadgeState.setCartCount(summary.items.length);
    } catch (error) {
      CustomSnackbar.show(_controller.loadCartError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _changeQuantity({
    required String productId,
    required String action,
  }) async {
    final result = await _controller.changeQuantity(
      productId: productId,
      action: action,
    );
    if (result.success) {
      _loadCart();
      return;
    }
    CustomSnackbar.show(result.message);
  }

  Future<void> _removeItem(String productId) async {
    final result = await _controller.removeItem(productId);
    if (result.success) {
      _loadCart();
      return;
    }
    CustomSnackbar.show(result.message);
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
                      if (widget.showBackButton)
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
                        )
                      else
                        const SizedBox(width: 8),
                      const SizedBox(width: 6),
                      TranslatedText(
                        'Shopping Cart',
                        style: TextStyle(
                          color: Color(0xFFB1B1B1),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                        ),
                        autoSize: true,
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
                        child: TranslatedText(
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
                  TranslatedText(
                    'Shipping Address',
                    style: TextStyle(
                      color: Color(0xFFE6E8EC),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _shippingAddressController,
                    minLines: 2,
                    maxLines: 3,
                    style: const TextStyle(
                      color: Color(0xFFF5F6F8),
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter shipping address',
                      hintStyle: const TextStyle(
                        color: Color(0xFFA8ADB3),
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF090B0F),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFF3B41A),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFF3B41A),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFFF3B41A),
                          width: 1.2,
                        ),
                      ),
                    ),
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
                              final shippingAddress = _shippingAddressController
                                  .text
                                  .trim();
                              if (shippingAddress.isEmpty) {
                                CustomSnackbar.show(
                                  'Please enter shipping address before payment',
                                );
                                return;
                              }
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PaymentMethodScreen(
                                    flowDestination:
                                        PaymentFlowDestination.shop,
                                    amount: _total,
                                    shippingAddress: shippingAddress,
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
                      child: TranslatedText(
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
                TranslatedText(
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
                TranslatedText(
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
                            TranslatedText(
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
                                    TranslatedText(
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
        TranslatedText(label, style: style),
        TranslatedText(value, style: style),
      ],
    );
  }
}
