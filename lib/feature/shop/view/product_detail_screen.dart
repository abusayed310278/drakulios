import 'package:flutter/material.dart';

import '../../../core/language/translated_text.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../controller/product_detail_controller.dart';
import '../model/shop_product_data.dart';
import 'shopping_cart_screen.dart';
import '../widgets/shop_badge_state.dart';
import '../widgets/shop_header.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product, required this.fallbackImage});

  final Map<String, dynamic> product;
  final String fallbackImage;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductDetailController _controller = ProductDetailController();

  late ShopProductData _product;
  int _selectedImageIndex = 0;
  String? _selectedOption;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _product = ShopProductData.fromRaw(widget.product, widget.fallbackImage);
    if (_product.optionValues.isNotEmpty) {
      _selectedOption = _product.optionValues.first;
    }
    _loadFullProduct();
  }

  Future<void> _loadFullProduct() async {
    final full = await _controller.loadFullProduct(current: _product, fallbackImage: widget.fallbackImage);
    if (full == null || !mounted) return;
    setState(() {
      _product = full;
      if (_product.optionValues.isNotEmpty && !_product.optionValues.contains(_selectedOption)) {
        _selectedOption = _product.optionValues.first;
      }
      if (_selectedImageIndex >= _product.gallery.length) {
        _selectedImageIndex = 0;
      }
    });
  }

  Future<void> _addToCartAndOpen() async {
    if (_product.id.isEmpty || _adding) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShoppingCartScreen()));
      return;
    }

    setState(() => _adding = true);
    try {
      final result = await _controller.addToCart(
        productId: _product.id,
        size: _product.usesFlavourOptions ? null : _selectedOption,
        flavour: _product.usesFlavourOptions ? _selectedOption : null,
      );
      if (!result.success) {
        CustomSnackbar.show(result.message);
        return;
      }
      ShopBadgeState.incrementCart();
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShoppingCartScreen()));
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentImage = _product.gallery[_selectedImageIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShopHeader(title: 'Product Details'),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _ProductImage(path: currentImage, height: 230),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _ThumbNavButton(
                        icon: Icons.chevron_left,
                        onTap: _product.gallery.length > 1
                            ? () {
                                setState(() {
                                  _selectedImageIndex = (_selectedImageIndex - 1 + _product.gallery.length) % _product.gallery.length;
                                });
                              }
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _product.gallery.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 6),
                            itemBuilder: (context, index) {
                              return _Thumb(
                                image: _product.gallery[index],
                                selected: index == _selectedImageIndex,
                                onTap: () => setState(() => _selectedImageIndex = index),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _ThumbNavButton(
                        icon: Icons.chevron_right,
                        onTap: _product.gallery.length > 1
                            ? () {
                                setState(() {
                                  _selectedImageIndex = (_selectedImageIndex + 1) % _product.gallery.length;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 29,
                    child: TranslatedText(
                      _product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600, height: 1.2),
                      autoSize: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 24,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TranslatedText(
                        _product.priceText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, height: 1),
                      ),
                    ),
                  ),
                  if (_product.optionValues.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 22,
                      child: TranslatedText(
                        _product.optionTitle,
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1.2),
                        autoSize: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _product.optionValues
                          .map(
                            (option) => _SizeChip(
                              label: option,
                              selected: _selectedOption == option,
                              onTap: () => setState(() => _selectedOption = option),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 18),
                  TranslatedText(
                    _product.subtitle,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1.2),
                    autoSize: true,
                  ),
                  const SizedBox(height: 6),
                  TranslatedText(
                    _product.description,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400, height: 1.2),
                  ),
                  const SizedBox(height: 14),
                  const _SectionTitle(text: 'Product Overview'),
                  ..._product.overviewBullets.map((text) => _Bullet(text: text)),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _adding ? null : _addToCartAndOpen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2B31A),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        disabledBackgroundColor: const Color(0xFF8C6A13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _adding
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : TranslatedText(
                              'Add to cart',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, height: 1.2, color: Colors.white),
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

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.path, required this.height});

  final String path;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');

    if (isNetwork) {
      return Image.network(
        path,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            color: const Color(0xFF1E2024),
            alignment: Alignment.center,
            child: const Icon(Icons.image_not_supported, color: Color(0xFF616775)),
          );
        },
      );
    }

    return Image.asset(path, height: height, width: double.infinity, fit: BoxFit.cover);
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.image, required this.selected, required this.onTap});

  final String image;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF1E2024),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: selected ? const Color(0xFFF2B31A) : const Color(0xFF3A3F47), width: 1.1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: _ProductImage(path: image, height: 56),
        ),
      ),
    );
  }
}

class _ThumbNavButton extends StatelessWidget {
  const _ThumbNavButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFF1E2024),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF3A3F47), width: 1.1),
        ),
        child: Icon(icon, size: 16, color: onTap == null ? const Color(0xFF6C737F) : Colors.white),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TranslatedText(
      text,
      style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1.2),
      autoSize: true,
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: TranslatedText('• ', style: TextStyle(color: Color(0xFF9498A1), fontSize: 13)),
          ),
          Expanded(
            child: TranslatedText(
              text,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _SizeChip extends StatelessWidget {
  const _SizeChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2A2513) : const Color(0xFF141517),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? const Color(0xFFF2B31A) : const Color(0xFF4B505A)),
        ),
        child: TranslatedText(
          label,
          style: TextStyle(color: selected ? const Color(0xFFF2B31A) : const Color(0xFF9EA3AD), fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
