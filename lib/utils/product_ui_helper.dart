import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'currency_utils.dart';

enum SortOption { popularity, priceLowToHigh, priceHighToLow }

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

  static const List<String> clothingSizes = ['S', 'M', 'L', 'XL', 'XXL'];
  static const List<String> footwearSizes = ['6', '7', '8', '9', '10', '11'];

  static final List<Map<String, dynamic>> nailPolishColors = [
    {'name': 'Ruby Red', 'color': const Color(0xFF9B111E)},
    {'name': 'Soft Pink', 'color': const Color(0xFFFFB6C1)},
    {'name': 'Nude Beige', 'color': const Color(0xFFE3BC9A)},
    {'name': 'Deep Purple', 'color': const Color(0xFF301934)},
    {'name': 'Classic Black', 'color': Colors.black},
    {'name': 'Royal Blue', 'color': const Color(0xFF002366)},
    {'name': 'Mint Green', 'color': const Color(0xFF98FF98)},
    {'name': 'Burgundy', 'color': const Color(0xFF800020)},
    {'name': 'Lavender', 'color': const Color(0xFFE6E6FA)},
    {'name': 'Teal', 'color': const Color(0xFF008080)},
    {'name': 'Coral', 'color': const Color(0xFFFF7F50)},
    {'name': 'Silver', 'color': const Color(0xFFC0C0C0)},
  ];

  static final List<Map<String, dynamic>> foundationColors = [
    {'name': 'Fair', 'color': const Color(0xFFFCEBD1)},
    {'name': 'Light', 'color': const Color(0xFFFAD4A9)},
    {'name': 'Medium', 'color': const Color(0xFFE5A073)},
    {'name': 'Tan', 'color': const Color(0xFFC1825B)},
    {'name': 'Dark', 'color': const Color(0xFF79443B)},
  ];

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
    return "20% OFF";
  }

  static String getCartItemSubtotal(CartItem item) {
    return formatPrice(item.subtotal);
  }

  static bool isFootwear(Product product) {
    final subCat = product.subCategory.toLowerCase();
    final cat = product.category.toLowerCase();
    final name = product.name.toLowerCase();
    final keywords = product.keywords.map((k) => k.toLowerCase()).toList();

    return cat.contains('footwear') ||
        cat.contains('shoes') ||
        subCat.contains('footwear') ||
        subCat.contains('shoes') ||
        name.contains('shoe') ||
        name.contains('sneaker') ||
        name.contains('sandal') ||
        name.contains('boot') ||
        keywords.any((k) => k.contains('shoe') || k.contains('footwear'));
  }

  static bool isClothing(Product product) {
    final subCat = product.subCategory.toLowerCase();
    final cat = product.category.toLowerCase();
    final name = product.name.toLowerCase();
    final keywords = product.keywords.map((k) => k.toLowerCase()).toList();

    bool isFashion = cat.contains('fashion') ||
        cat.contains('clothing') ||
        subCat.contains('fashion') ||
        cat.contains('clothing') ||
        cat.contains('apparel') ||
        subCat.contains('apparel');

    if (!isFashion || isFootwear(product)) return false;

    final womenRegex = RegExp(r'\bwomen\b|\bfemale\b|\blady\b|\bladies\b');
    final menRegex = RegExp(r'\bmen\b|\bmale\b');

    return womenRegex.hasMatch(name) ||
        womenRegex.hasMatch(subCat) ||
        keywords.any((k) => womenRegex.hasMatch(k)) ||
        menRegex.hasMatch(name) ||
        menRegex.hasMatch(subCat) ||
        keywords.any((k) => menRegex.hasMatch(k));
  }

  static bool isNailPolish(Product product) {
    final name = product.name.toLowerCase();
    final cat = product.category.toLowerCase();
    final subCat = product.subCategory.toLowerCase();
    final keywords = product.keywords.map((k) => k.toLowerCase()).toList();

    return name.contains('nail polish') ||
        name.contains('nail lacquer') ||
        (cat.contains('beauty') && (name.contains('nail') || subCat.contains('nail'))) ||
        keywords.any((k) => k.contains('nail polish'));
  }

  static bool isFoundation(Product product) {
    final name = product.name.toLowerCase();
    final cat = product.category.toLowerCase();
    final subCat = product.subCategory.toLowerCase();
    final keywords = product.keywords.map((k) => k.toLowerCase()).toList();

    return name.contains('foundation') ||
        (cat.contains('beauty') && (name.contains('foundation') || subCat.contains('foundation'))) ||
        keywords.any((k) => k.contains('foundation'));
  }

  static bool requiresSizeSelection(Product product) =>
      isClothing(product) || isFootwear(product);

  static bool requiresColorSelection(Product product) =>
      isNailPolish(product) || isFoundation(product);

  static List<String> getAvailableSizes(Product product) =>
      isFootwear(product) ? footwearSizes : clothingSizes;

  static List<Map<String, dynamic>> getAvailableColors(Product product) =>
      isFoundation(product) ? foundationColors : nailPolishColors;

  static List<Product> filterAndSortProducts({
    required List<Product> products,
    required String category,
    required String query,
    required double minPrice,
    required double maxPrice,
    required int selectedRating,
    required SortOption sortOption,
  }) {
    final categoryLower = category.toLowerCase();
    final queryLower = query.trim().toLowerCase();

    List<Product> filtered = products.where((product) {
      final productPrice = product.price;
      
      final matchesCategory =
          categoryLower == 'all' ||
          product.category.toLowerCase().contains(categoryLower);
      
      final matchesSearch = queryLower.isEmpty || [
        product.name,
        product.category,
        product.subCategory,
        product.description,
        ...product.keywords,
      ].join(' ').toLowerCase().contains(queryLower);

      final matchesPrice = productPrice >= minPrice && productPrice <= maxPrice;
      
      final matchesRating = selectedRating == 0 || product.rating.stars >= selectedRating;

      return matchesCategory && matchesSearch && matchesPrice && matchesRating;
    }).toList();

    // Apply sorting
    switch (sortOption) {
      case SortOption.popularity:
        filtered.sort((a, b) => b.rating.count.compareTo(a.rating.count));
        break;
      case SortOption.priceLowToHigh:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
    }

    return filtered;
  }
}
