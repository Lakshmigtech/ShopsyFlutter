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

  double get price => priceCents / 100.0;

  factory Product.fromJson(Map<String, dynamic> json) {
    // Handle price vs priceCents
    int priceCents = 0;
    if (json['priceCents'] != null) {
      priceCents = (json['priceCents'] as num).toInt();
    } else if (json['price'] != null) {
      priceCents = ((json['price'] as num).toDouble() * 100).round();
    }

    // Handle relative image paths from the specific GitHub API
    String imageUrl = json['image'] ?? json['imageUrl'] ?? '';
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      const String baseUrl = "https://raw.githubusercontent.com/kolzsticks/Free-Ecommerce-Products-Api/main/";
      imageUrl = baseUrl + imageUrl;
    }

    return Product(
      id: json['id']?.toString() ?? '',
      image: imageUrl,
      name: json['name'] ?? json['title'] ?? '',
      rating: Rating.fromJson(json['rating'] ?? {}),
      priceCents: priceCents,
      category: json['category'] ?? json['type'] ?? 'General',
      subCategory: json['subCategory'] ?? '',
      keywords: json['keywords'] != null ? List<String>.from(json['keywords']) : [],
      description: json['description'] ?? 'No description available for this product.',
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
      stars: (json['stars'] as num? ?? json['rate'] as num? ?? 0.0).toDouble(),
      count: (json['count'] as num? ?? 0).toInt(),
    );
  }
}

class CartItem {
  final Product product;
  int quantity;
  String? size;
  String? color;

  CartItem({required this.product, this.quantity = 1, this.size, this.color});

  double get subtotal => product.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] ?? 1,
      size: json['size'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'size': size,
      'color': color,
    };
  }
}
