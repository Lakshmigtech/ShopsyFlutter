import 'package:get/get.dart';

class Product {
  final String id;
  final String image;
  final String name;
  final Rating rating;
  final int priceCents;
  final String category;
  final String subCategory;
  final List<String> keywords;
  final String description;

  // Adding a reactive property for wishlist/favorite status
  final RxBool isFavorite = false.obs;

  Product({
    required this.id,
    required this.image,
    required this.name,
    required this.rating,
    required this.priceCents,
    required this.category,
    required this.subCategory,
    required this.keywords,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      image: json['image'] ?? '',
      name: json['name'] ?? '',
      rating: Rating.fromJson(json['rating'] ?? {}),
      priceCents: json['priceCents'] ?? 0,
      category: json['category'] ?? '',
      subCategory: json['subCategory'] ?? '',
      keywords: List<String>.from(json['keywords'] ?? []),
      description: json['description'] ?? '',
    );
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }
}

class Rating {
  final double stars;
  final int count;

  Rating({required this.stars, required this.count});

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      stars: (json['stars'] as num? ?? 0.0).toDouble(),
      count: json['count'] ?? 0,
    );
  }
}

class CartItem {
  final Product product;
  final RxInt quantity;

  CartItem({required this.product, int initialQuantity = 1})
    : quantity = initialQuantity.obs;

  // Helper method to get total price for this item
  double get subtotal => (product.priceCents * quantity.value) / 100.0;
}
