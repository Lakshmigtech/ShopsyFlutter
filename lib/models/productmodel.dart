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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'rating': {
        'stars': rating.stars,
        'count': rating.count,
      },
      'priceCents': priceCents,
      'category': category,
      'subCategory': subCategory,
      'keywords': keywords,
      'description': description,
    };
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
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => (product.priceCents * quantity) / 100.0;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
}
