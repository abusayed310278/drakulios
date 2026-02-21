import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/constants/assets.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import 'product_detail_screen.dart';
import 'shopping_cart_screen.dart';
import 'widgets/shop_badge_state.dart';
import 'widgets/shop_header.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final TrainingShopApiService _api = TrainingShopApiService();
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  List<Map<String, dynamic>> _items = <Map<String, dynamic>>[];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final data = await _api.getProducts();
      if (!mounted) return;
      setState(() => _items = data);
    } on DioException catch (e) {
      final d = e.response?.data;
      final msg = d is Map && d['message'] != null
          ? d['message'].toString()
          : 'Failed to load shop items';
      CustomSnackbar.show(msg);
    } catch (_) {
      CustomSnackbar.show('Failed to load shop items');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addToCart(String productId) async {
    try {
      await _api.addToCart(productId: productId, quantity: 1);
      ShopBadgeState.incrementCart();
      if (!mounted) return;
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ShoppingCartScreen()));
    } on DioException catch (e) {
      final d = e.response?.data;
      final msg = d is Map && d['message'] != null
          ? d['message'].toString()
          : 'Failed to add product to cart';
      CustomSnackbar.show(msg);
    } catch (_) {
      CustomSnackbar.show('Failed to add product to cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    final fallbackItems = <Map<String, String>>[
      {
        'title': 'GT5s Motorized Treadmill',
        'price': r'$1200',
        'image': Images.gym1Image,
      },
      {
        'title': 'Magnetic Cross Trainer',
        'price': r'$449',
        'image': Images.gym2Image,
      },
      {
        'title': 'Spinning Bike (Pro)',
        'price': r'$259',
        'image': Images.gym3Image,
      },
    ];
    final filteredApiItems = _items.where((item) {
      final title = (item['name'] ?? 'Product').toString().toLowerCase();
      return _searchQuery.isEmpty || title.contains(_searchQuery);
    }).toList();
    final filteredFallbackItems = fallbackItems.where((item) {
      final title = (item['title'] ?? '').toLowerCase();
      return _searchQuery.isEmpty || title.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        top: true,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ShopHeader(title: 'Shop'),
                  const SizedBox(height: 14),
                  Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(
                        () => _searchQuery = value.trim().toLowerCase(),
                      ),
                      style: const TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: false,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        prefixIcon: Icon(
                          Icons.search,
                          size: 18,
                          color: Color(0xFF90959C),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: 34,
                          minHeight: 34,
                        ),
                        hintText: 'Search',
                        hintStyle: TextStyle(
                          color: Color(0xFF90959C),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Products',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _CategoryChip(label: 'Equipments', selected: true),
                        SizedBox(width: 8),
                        _CategoryChip(label: 'Apparel'),
                        SizedBox(width: 8),
                        _CategoryChip(label: 'Drinks'),
                        SizedBox(width: 8),
                        _CategoryChip(label: 'Supps'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DealCard(),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFF3B41A),
                      ),
                    )
                  else if (_items.isEmpty) ...[
                    if (filteredFallbackItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 18),
                        child: Center(
                          child: Text(
                            'No products found',
                            style: TextStyle(
                              color: Color(0xFF9AA1AE),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      ...List.generate(filteredFallbackItems.length, (index) {
                        final item = filteredFallbackItems[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == filteredFallbackItems.length - 1
                                ? 0
                                : 12,
                          ),
                          child: _ProductCard(
                            title: item['title']!,
                            price: item['price']!,
                            image: item['image']!,
                          ),
                        );
                      }),
                  ] else if (filteredApiItems.isEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 18),
                      child: Center(
                        child: Text(
                          'No products found',
                          style: TextStyle(
                            color: Color(0xFF9AA1AE),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ] else
                    ...List.generate(filteredApiItems.length, (index) {
                      final item = filteredApiItems[index];
                      final title = (item['name'] ?? 'Product').toString();
                      final price = (item['price'] ?? item['priceMonthly'] ?? 0)
                          .toString();
                      final image = [
                        Images.gym1Image,
                        Images.gym2Image,
                        Images.gym3Image,
                      ][index % 3];
                      final productId = (item['_id'] ?? item['id'] ?? '')
                          .toString();
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == filteredApiItems.length - 1 ? 0 : 12,
                        ),
                        child: _ProductCard(
                          title: title,
                          price: '\$$price',
                          image: image,
                          onAdd: productId.isNotEmpty
                              ? () => _addToCart(productId)
                              : null,
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF2C6CFF) : const Color(0xFF1E2024),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? const Color(0xFF2C6CFF) : const Color(0xFF3A3F47),
          width: 1.1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.fitness_center,
            size: 14,
            color: selected ? Colors.white : const Color(0xFFF2B31A),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFFF2B31A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0C224E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Deal of the month',
                  style: TextStyle(
                    color: Color(0xFFB7C0D0),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '10% off Pre-Workout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2C6CFF),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text(
              'See Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.title,
    required this.price,
    required this.image,
    this.onAdd,
  });

  final String title;
  final String price;
  final String image;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProductDetailScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2513),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF2B31A), width: 1.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.asset(image, height: 150, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 24,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                price,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: onAdd,
                          borderRadius: BorderRadius.circular(6),
                          child: Ink(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2B31A),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 14,
                              color: Colors.black,
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
        ),
      ),
    );
  }
}
