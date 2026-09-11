import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/sort_option.dart';
import 'currency_utils.dart';

class ProductUIHelper {
  static const List<String> searchHints = [
    'Search for mobile...',
    'Search for electronics...',
    'Search for fashion...',
    'Search for beauty...',
    'Search for home decor...',
    'Search for sneakers...',
  ];

  static const List<String> categories = [
    'All',
    'Home',
    'Fashion',
    'Electronics',
    'Beauty',
  ];

  static const List<String> clothingSizes = [
    'S',
    'M',
    'L',
    'XL',
    'XXL',
  ];

  static const List<String> footwearSizes = [
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
  ];

  static final List<Map<String, dynamic>> nailPolishColors = [
    {
      'name': 'Ruby Red',
      'color': const Color(0xFF9B111E),
    },
    {
      'name': 'Soft Pink',
      'color': const Color(0xFFFFB6C1),
    },
    {
      'name': 'Nude Beige',
      'color': const Color(0xFFE3BC9A),
    },
    {
      'name': 'Deep Purple',
      'color': const Color(0xFF301934),
    },
    {
      'name': 'Classic Black',
      'color': Colors.black,
    },
    {
      'name': 'Royal Blue',
      'color': const Color(0xFF002366),
    },
    {
      'name': 'Mint Green',
      'color': const Color(0xFF98FF98),
    },
    {
      'name': 'Burgundy',
      'color': const Color(0xFF800020),
    },
    {
      'name': 'Lavender',
      'color': const Color(0xFFE6E6FA),
    },
    {
      'name': 'Teal',
      'color': const Color(0xFF008080),
    },
    {
      'name': 'Coral',
      'color': const Color(0xFFFF7F50),
    },
    {
      'name': 'Silver',
      'color': const Color(0xFFC0C0C0),
    },
  ];

  static final List<Map<String, dynamic>> foundationColors = [
    {
      'name': 'Fair',
      'color': const Color(0xFFFCEBD1),
    },
    {
      'name': 'Light',
      'color': const Color(0xFFFAD4A9),
    },
    {
      'name': 'Medium',
      'color': const Color(0xFFE5A073),
    },
    {
      'name': 'Tan',
      'color': const Color(0xFFC1825B),
    },
    {
      'name': 'Dark',
      'color': const Color(0xFF79443B),
    },
  ];

  // ---------------------------------------------------------------------------
  // PRICE
  // ---------------------------------------------------------------------------

  static String formatPrice(double price) {
    return '₹${CurrencyUtils.formatPrice(price)}';
  }

  static String getDisplayPrice(Product product) {
    return formatPrice(product.price);
  }

  static String getOriginalPrice(Product product) {
    return formatPrice(product.price * 1.25);
  }

  static String getDiscountPercentage(Product product) {
    return '20% OFF';
  }

  static String getCartItemSubtotal(CartItem item) {
    return formatPrice(item.subtotal);
  }

  // ---------------------------------------------------------------------------
  // PRODUCT TYPE CHECKS
  // ---------------------------------------------------------------------------

  static bool isFootwear(Product product) {
    final subCat = product.subCategory.toLowerCase();
    final cat = product.category.toLowerCase();
    final name = product.name.toLowerCase();

    final keywords = product.keywords
        .map((keyword) => keyword.toLowerCase())
        .toList();

    return cat.contains('footwear') ||
        cat.contains('shoes') ||
        subCat.contains('footwear') ||
        subCat.contains('shoes') ||
        name.contains('shoe') ||
        name.contains('sneaker') ||
        name.contains('sandal') ||
        name.contains('boot') ||
        keywords.any(
              (keyword) =>
          keyword.contains('shoe') ||
              keyword.contains('footwear'),
        );
  }

  static bool isClothing(Product product) {
    final subCat = product.subCategory.toLowerCase();
    final cat = product.category.toLowerCase();
    final name = product.name.toLowerCase();

    final keywords = product.keywords
        .map((keyword) => keyword.toLowerCase())
        .toList();

    final isFashion = cat.contains('fashion') ||
        cat.contains('clothing') ||
        cat.contains('apparel') ||
        subCat.contains('fashion') ||
        subCat.contains('clothing') ||
        subCat.contains('apparel');

    if (!isFashion || isFootwear(product)) {
      return false;
    }

    final clothingKeywords = [
      'shirt',
      't-shirt',
      'tshirt',
      'dress',
      'jeans',
      'trouser',
      'pant',
      'shorts',
      'skirt',
      'jacket',
      'coat',
      'hoodie',
      'sweater',
      'top',
      'kurta',
      'saree',
      'blouse',
      'clothing',
      'apparel',
    ];

    return clothingKeywords.any(
          (keyword) =>
      name.contains(keyword) ||
          subCat.contains(keyword) ||
          keywords.any((item) => item.contains(keyword)),
    );
  }

  static bool isNailPolish(Product product) {
    final name = product.name.toLowerCase();
    final cat = product.category.toLowerCase();
    final subCat = product.subCategory.toLowerCase();

    final keywords = product.keywords
        .map((keyword) => keyword.toLowerCase())
        .toList();

    return name.contains('nail polish') ||
        name.contains('nail lacquer') ||
        (cat.contains('beauty') &&
            (name.contains('nail') || subCat.contains('nail'))) ||
        keywords.any(
              (keyword) => keyword.contains('nail polish'),
        );
  }

  static bool isFoundation(Product product) {
    final name = product.name.toLowerCase();
    final cat = product.category.toLowerCase();
    final subCat = product.subCategory.toLowerCase();

    final keywords = product.keywords
        .map((keyword) => keyword.toLowerCase())
        .toList();

    return name.contains('foundation') ||
        (cat.contains('beauty') &&
            (name.contains('foundation') ||
                subCat.contains('foundation'))) ||
        keywords.any(
              (keyword) => keyword.contains('foundation'),
        );
  }

  // ---------------------------------------------------------------------------
  // SIZE / COLOR
  // ---------------------------------------------------------------------------

  static bool requiresSizeSelection(Product product) {
    return isClothing(product) || isFootwear(product);
  }

  static bool requiresColorSelection(Product product) {
    return isNailPolish(product) || isFoundation(product);
  }

  static List<String> getAvailableSizes(Product product) {
    if (isFootwear(product)) {
      return footwearSizes;
    }

    return clothingSizes;
  }

  static List<Map<String, dynamic>> getAvailableColors(Product product) {
    if (isFoundation(product)) {
      return foundationColors;
    }

    return nailPolishColors;
  }

  // ---------------------------------------------------------------------------
  // FILTER & SORT
  // ---------------------------------------------------------------------------

  static List<Product> filterAndSortProducts({
    required List<Product> products,
    required String category,
    required String query,
    required double minPrice,
    required double maxPrice,
    required int selectedRating,
    required SortOption sortOption,
  }) {
    final categoryLower = category.trim().toLowerCase();
    final queryLower = query.trim().toLowerCase();

    final List<Product> filtered = products.where((product) {
      final productCategory = product.category.toLowerCase();
      final productPrice = product.price;

      // Category
      final matchesCategory =
          categoryLower == 'all' ||
              productCategory == categoryLower ||
              productCategory.contains(categoryLower);

      // Search
      final searchableText = [
        product.name,
        product.category,
        product.subCategory,
        product.description,
        ...product.keywords,
      ].join(' ').toLowerCase();

      final matchesSearch =
          queryLower.isEmpty || searchableText.contains(queryLower);

      // Price
      final matchesPrice =
          productPrice >= minPrice && productPrice <= maxPrice;

      // Rating
      final matchesRating =
          selectedRating == 0 ||
              product.rating.stars >= selectedRating;

      return matchesCategory &&
          matchesSearch &&
          matchesPrice &&
          matchesRating;
    }).toList();

    // Sorting
    switch (sortOption) {
      case SortOption.popularity:
        filtered.sort(
              (a, b) => b.rating.count.compareTo(a.rating.count),
        );
        break;

      case SortOption.priceLowToHigh:
        filtered.sort(
              (a, b) => a.price.compareTo(b.price),
        );
        break;

      case SortOption.priceHighToLow:
        filtered.sort(
              (a, b) => b.price.compareTo(a.price),
        );
        break;
    }

    return filtered;
  }
}