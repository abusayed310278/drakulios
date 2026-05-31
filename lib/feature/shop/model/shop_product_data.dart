import '../../../core/constants/assets.dart';

class ShopProductData {
  ShopProductData({
    required this.id,
    required this.title,
    required this.price,
    required this.priceText,
    required this.subtitle,
    required this.description,
    required this.gallery,
    required this.sizes,
    required this.flavours,
    required this.optionTitle,
    required this.optionValues,
    required this.usesFlavourOptions,
    required this.overviewBullets,
  });

  final String id;
  final num price;
  final String title;
  final String priceText;
  final String subtitle;
  final String description;
  final List<String> gallery;
  final List<String> sizes;
  final List<String> flavours;
  final String optionTitle;
  final List<String> optionValues;
  final bool usesFlavourOptions;
  final List<String> overviewBullets;

  factory ShopProductData.fromRaw(Map<String, dynamic> raw, String fallbackImage) {
    final id = (raw['_id'] ?? raw['id'] ?? '').toString();
    final title = (raw['name'] ?? raw['title'] ?? 'Product').toString();
    final priceNum = _numValue(raw['price'] ?? raw['priceMonthly'] ?? 0);
    final sizes = _sizesFromRaw(raw['size']);
    final flavours = _flavoursFromRaw(raw);
    final usesFlavourOptions = flavours.isNotEmpty;
    final optionTitle = usesFlavourOptions
        ? 'Available Flavours'
        : 'Available Sizes';
    final optionValues = List<String>.from(
      usesFlavourOptions ? flavours : sizes,
    );
    final description = (raw['description'] ?? 'No description available.')
        .toString()
        .trim();

    final gallery = _galleryFromRaw(raw['image'], fallbackImage);
    final overview = <String>[
      if (raw['stockAvailable'] != null) 'Stock Available: ${raw['stockAvailable']}',
      if (raw['stockSell'] != null) 'Stock Sold: ${raw['stockSell']}',
      if (raw['totalStock'] != null) 'Total Stock: ${raw['totalStock']}',
      if (sizes.isNotEmpty) 'Sizes: ${sizes.join(', ')}',
      if (flavours.isNotEmpty) 'Flavours: ${flavours.join(', ')}',
    ];

    if (overview.isEmpty) {
      overview.add('Premium quality product from Pro Factory lineup.');
      overview.add('Engineered for durability and consistent performance.');
    }

    return ShopProductData(
      id: id,
      title: title,
      price: priceNum,
      priceText: _priceText(raw['priceText'], priceNum),
      subtitle: _subtitleFromTitle(title),
      description: description.isEmpty ? 'No description available.' : description,
      gallery: gallery,
      sizes: sizes,
      flavours: flavours,
      optionTitle: optionTitle,
      optionValues: optionValues,
      usesFlavourOptions: usesFlavourOptions,
      overviewBullets: overview,
    );
  }

  static num _numValue(dynamic raw) {
    if (raw is num) return raw;
    return num.tryParse(raw?.toString() ?? '') ?? 0;
  }

  static String _priceText(dynamic fromRaw, num value) {
    final raw = fromRaw?.toString().trim() ?? '';
    if (raw.isNotEmpty) return raw.startsWith(r'$') ? raw : '\$$raw';
    if (value % 1 == 0) return '\$${value.toInt()}';
    return '\$${value.toStringAsFixed(2)}';
  }

  static String _subtitleFromTitle(String title) {
    final clean = title.trim();
    if (clean.isEmpty) return 'Pro Factory Signature Product';
    return '$clean Signature';
  }

  static List<String> _sizesFromRaw(dynamic rawSizes) {
    if (rawSizes is List) {
      return rawSizes
          .where((e) => e != null)
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty && e.toLowerCase() != 'null')
          .toList();
    }
    return <String>[];
  }

  static List<String> _flavoursFromRaw(Map<String, dynamic> raw) {
    final candidates = <dynamic>[
      raw['flavour'],
      raw['flavourOptions'],
      raw['flavors'],
      raw['flavorsOptions'],
      raw['flavourList'],
      raw['flavor'],
      raw['flavorOptions'],
      raw['taste'],
      raw['tastes'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        final values = candidate
            .where((e) => e != null)
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty && e.toLowerCase() != 'null')
            .toList();
        if (values.isNotEmpty) return values;
      }
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }
    return <String>[];
  }

  static List<String> _galleryFromRaw(dynamic rawImage, String fallbackImage) {
    if (rawImage is List) {
      final urls = rawImage
          .map((item) {
            if (item is Map && item['url'] != null) {
              return item['url'].toString();
            }
            return item.toString();
          })
          .where((url) => url.trim().isNotEmpty)
          .toList();
      if (urls.isNotEmpty) return urls;
    }

    return <String>[fallbackImage, Images.gym2Image, Images.gym3Image, fallbackImage];
  }
}
