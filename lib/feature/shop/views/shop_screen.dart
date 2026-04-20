import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../core/common/widgets/custom_snackbar.dart';
import '../../../core/constants/assets.dart';
import '../../../core/network/api_service/training_shop_api_service.dart';
import 'product_detail_screen.dart';
import 'shopping_cart_screen.dart';
import 'widgets/shop_badge_state.dart';
import 'widgets/shop_header.dart';

enum _ShopCategory { equipments, apparel, drink }

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  final TrainingShopApiService _api = TrainingShopApiService();
  final TextEditingController _searchController = TextEditingController();
  late final TabController _tabController;
  bool _loading = true;
  List<Map<String, dynamic>> _items = <Map<String, dynamic>>[];
  String _searchQuery = '';
  _ShopCategory _selectedCategory = _ShopCategory.equipments;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (_tabController.indexIsChanging) return;
        final next = _ShopCategory.values[_tabController.index];
        if (_selectedCategory == next) return;
        setState(() => _selectedCategory = next);
      });
    _loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  bool _matchesSelectedCategory(Map<String, dynamic> item) {
    final resolvedCategory = _resolveCategory(item);
    if (resolvedCategory != null) {
      return resolvedCategory == _selectedCategory;
    }

    // If backend does not provide category metadata, keep products visible
    // under Equipments so users still see the catalog.
    if (_selectedCategory == _ShopCategory.equipments) {
      return true;
    }

    return false;
  }

  _ShopCategory? _resolveCategory(Map<String, dynamic> item) {
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

    if (_looksLikeApparel(raw)) return _ShopCategory.apparel;
    if (_looksLikeDrink(raw)) return _ShopCategory.drink;
    if (_looksLikeEquipment(raw)) return _ShopCategory.equipments;
    return null;
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

  @override
  Widget build(BuildContext context) {
    final fallbackItemsByCategory = <_ShopCategory, List<Map<String, String>>>{
      _ShopCategory.equipments: <Map<String, String>>[
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
      ],
      _ShopCategory.apparel: <Map<String, String>>[
        {
          'title': 'Performance Joggers',
          'price': r'$59',
          'image': Images.apparelImage,
        },
        {
          'title': 'Pro Gym T-Shirt',
          'price': r'$35',
          'image': Images.img2Image,
        },
        {'title': 'Zip Hoodie', 'price': r'$72', 'image': Images.img3Image},
      ],
      _ShopCategory.drink: <Map<String, String>>[
        {'title': 'Electro Drink', 'price': r'$6', 'image': Images.drinkImage},
        {'title': 'Protein Shake', 'price': r'$8', 'image': Images.lunchImage},
        {'title': 'Energy Water', 'price': r'$5', 'image': Images.dinnerImage},
      ],
    };

    final categoryFilteredApiItems = _items
        .where(_matchesSelectedCategory)
        .toList();
    final filteredApiItems = categoryFilteredApiItems.where((item) {
      final title = (item['name'] ?? 'Product').toString().toLowerCase();
      return _searchQuery.isEmpty || title.contains(_searchQuery);
    }).toList();
    final categoryFallbackItems =
        fallbackItemsByCategory[_selectedCategory] ?? <Map<String, String>>[];
    final filteredFallbackItems = categoryFallbackItems.where((item) {
      final title = (item['title'] ?? '').toLowerCase();
      return _searchQuery.isEmpty || title.contains(_searchQuery);
    }).toList();

    Widget buildFallbackList(List<Map<String, String>> items) {
      return ListView.separated(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final item = items[index];
          final productPayload = <String, dynamic>{
            'name': item['title']!,
            'priceText': item['price']!,
            'price': item['price']!.replaceAll('\$', ''),
            'description':
                'Premium training product designed for gym performance.',
            'image': [item['image']!],
            'size': const <String>['M', 'XL', 'XXL'],
          };
          return _ProductCard(
            title: item['title']!,
            price: item['price']!,
            image: item['image']!,
            product: productPayload,
            fallbackImage: item['image']!,
          );
        },
      );
    }

    Widget buildApiList(List<Map<String, dynamic>> items) {
      return ListView.separated(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final item = items[index];
          final title = (item['name'] ?? 'Product').toString();
          final price = (item['price'] ?? item['priceMonthly'] ?? 0).toString();
          final fallbackImage = [
            Images.gym1Image,
            Images.gym2Image,
            Images.gym3Image,
          ][index % 3];
          final image = _resolveCardImage(item, fallbackImage);
          final productId = (item['_id'] ?? item['id'] ?? '').toString();
          return _ProductCard(
            title: title,
            price: '\$$price',
            image: image,
            product: item,
            fallbackImage: fallbackImage,
            onAdd: productId.isNotEmpty ? () => _addToCart(productId) : null,
          );
        },
      );
    }

    Widget buildProductsBody() {
      if (_loading) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFF3B41A)),
        );
      }

      if (filteredApiItems.isNotEmpty) {
        return buildApiList(filteredApiItems);
      }

      if (filteredFallbackItems.isNotEmpty) {
        return buildFallbackList(filteredFallbackItems);
      }

      final message = _items.isEmpty
          ? 'No products found'
          : 'No products found for this category';
      return Center(
        child: Text(
          message,
          style: const TextStyle(color: Color(0xFF9AA1AE), fontSize: 13),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050608),
      body: SafeArea(
        top: true,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
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
                    height: 38,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      dividerColor: Colors.transparent,
                      labelPadding: const EdgeInsets.only(right: 8),
                      indicatorPadding: EdgeInsets.zero,
                      indicator: BoxDecoration(
                        color: const Color(0xFF2C6CFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      splashBorderRadius: BorderRadius.circular(8),
                      tabs: <Widget>[
                        _CategoryTab(
                          label: 'Equipments',
                          icon: Icons.fitness_center,
                          selected:
                              _selectedCategory == _ShopCategory.equipments,
                        ),
                        _CategoryTab(
                          label: 'Apparel',
                          icon: Icons.checkroom_outlined,
                          selected: _selectedCategory == _ShopCategory.apparel,
                        ),
                        _CategoryTab(
                          label: 'Drink',
                          icon: Icons.local_drink_outlined,
                          selected: _selectedCategory == _ShopCategory.drink,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: buildProductsBody()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.label,
    required this.icon,
    required this.selected,
  });

  final String label;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Colors.transparent : const Color(0xFF1E2024),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? const Color(0xFF2C6CFF) : const Color(0xFF3A3F47),
          width: 1.1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
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

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.title,
    required this.price,
    required this.image,
    required this.product,
    required this.fallbackImage,
    this.onAdd,
  });

  final String title;
  final String price;
  final String image;
  final Map<String, dynamic> product;
  final String fallbackImage;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(
                product: product,
                fallbackImage: fallbackImage,
              ),
            ),
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
                child: _CardImage(path: image),
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

class _CardImage extends StatelessWidget {
  const _CardImage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
    if (isNetwork) {
      return Image.network(
        path,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Image.asset(Images.gym1Image, height: 150, fit: BoxFit.cover),
      );
    }

    return Image.asset(path, height: 150, fit: BoxFit.cover);
  }
}

String _resolveCardImage(Map<String, dynamic> item, String fallbackImage) {
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
