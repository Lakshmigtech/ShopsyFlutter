import 'package:Shopsy/controller/cart_controller.dart';
import 'package:Shopsy/controller/wishlist_controller.dart';
import 'package:Shopsy/models/product_model.dart';
import 'package:Shopsy/views/tab_bar/cart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  final Product product = Get.arguments;
  final cartController = Get.find<CartController>();
  final wishlistController = Get.find<WishlistController>();
  final GlobalKey _cartKey = GlobalKey();
  final GlobalKey _imageKey = GlobalKey();

  late AnimationController _animationController;
  late Animation<Offset> _moveAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isAnimating = false;
  Offset _startOffset = Offset.zero;
  Offset _endOffset = Offset.zero;

  String? _selectedSize;
  String? _selectedColorName;

  final List<String> _clothingSizes = ['S', 'M', 'L', 'XL', 'XXL'];
  final List<String> _footwearSizes = ['6', '7', '8', '9', '10', '11'];

  final List<Map<String, dynamic>> _nailPolishColors = [
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

  final List<Map<String, dynamic>> _foundationColors = [
    {'name': 'Fair', 'color': const Color(0xFFFCEBD1)},
    {'name': 'Light', 'color': const Color(0xFFFAD4A9)},
    {'name': 'Medium', 'color': const Color(0xFFE5A073)},
    {'name': 'Tan', 'color': const Color(0xFFC1825B)},
    {'name': 'Dark', 'color': const Color(0xFF79443B)},
  ];

  // Identify if it is footwear
  bool get _isFootwear {
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

  // Identify if it is clothing
  bool get _isClothing {
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

    if (!isFashion || _isFootwear) return false;

    final womenRegex = RegExp(r'\bwomen\b|\bfemale\b|\blady\b|\bladies\b');
    final menRegex = RegExp(r'\bmen\b|\bmale\b');

    return womenRegex.hasMatch(name) ||
        womenRegex.hasMatch(subCat) ||
        keywords.any((k) => womenRegex.hasMatch(k)) ||
        menRegex.hasMatch(name) ||
        menRegex.hasMatch(subCat) ||
        keywords.any((k) => menRegex.hasMatch(k));
  }

  // Identify if it is nail polish
  bool get _isNailPolish {
    final name = product.name.toLowerCase();
    final cat = product.category.toLowerCase();
    final subCat = product.subCategory.toLowerCase();
    final keywords = product.keywords.map((k) => k.toLowerCase()).toList();

    return name.contains('nail polish') ||
        name.contains('nail lacquer') ||
        (cat.contains('beauty') && (name.contains('nail') || subCat.contains('nail'))) ||
        keywords.any((k) => k.contains('nail polish'));
  }

  // Identify if it is foundation
  bool get _isFoundation {
    final name = product.name.toLowerCase();
    final cat = product.category.toLowerCase();
    final subCat = product.subCategory.toLowerCase();
    final keywords = product.keywords.map((k) => k.toLowerCase()).toList();

    return name.contains('foundation') ||
        (cat.contains('beauty') && (name.contains('foundation') || subCat.contains('foundation'))) ||
        keywords.any((k) => k.contains('foundation'));
  }

  bool get _requiresSizeSelection => _isClothing || _isFootwear;
  bool get _requiresColorSelection => _isNailPolish || _isFoundation;

  List<String> get _availableSizes => _isFootwear ? _footwearSizes : _clothingSizes;
  List<Map<String, dynamic>> get _availableColors => _isFoundation ? _foundationColors : _nailPolishColors;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0),
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
        });
        cartController.addToCart(product, size: _selectedSize, color: _selectedColorName);
        _animationController.reset();
      }
    });
  }

  void _runAddToCartAnimation() {
    if (_requiresSizeSelection && _selectedSize == null) {
      Get.snackbar(
        'Selection Required',
        'Please select a size before adding to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (_requiresColorSelection && _selectedColorName == null) {
      Get.snackbar(
        'Selection Required',
        'Please select a shade before adding to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final RenderBox? imageBox =
        _imageKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? cartBox =
        _cartKey.currentContext?.findRenderObject() as RenderBox?;

    if (imageBox != null && cartBox != null) {
      final imagePosition = imageBox.localToGlobal(Offset.zero);
      final cartPosition = cartBox.localToGlobal(Offset.zero);

      setState(() {
        _startOffset = Offset(
          imagePosition.dx + imageBox.size.width / 2 - 40,
          imagePosition.dy + imageBox.size.height / 2 - 40,
        );
        _endOffset = Offset(
          cartPosition.dx + cartBox.size.width / 2 - 20,
          cartPosition.dy + cartBox.size.height / 2 - 20,
        );
        _isAnimating = true;
      });

      _moveAnimation = Tween<Offset>(begin: _startOffset, end: _endOffset)
          .animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInCirc,
        ),
      );

      _animationController.forward();
    } else {
      cartController.addToCart(product, size: _selectedSize, color: _selectedColorName);
    }
  }

  void _handleBuyNow() {
    if (_requiresSizeSelection && _selectedSize == null) {
      Get.snackbar(
        'Selection Required',
        'Please select a size before proceeding',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (_requiresColorSelection && _selectedColorName == null) {
      Get.snackbar(
        'Selection Required',
        'Please select a shade before proceeding',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    cartController.addToCart(product, size: _selectedSize, color: _selectedColorName);
    Get.to(() => const CartScreen());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 🔝 Header
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: Row(
                    children: [
                      _circleIcon(Icons.arrow_back, () => Get.back(), screenWidth),
                      const Spacer(),
                      Obx(() => _circleIcon(
                        wishlistController.isFavorite(product) ? Icons.favorite : Icons.favorite_border,
                            () => wishlistController.toggleFavorite(product),
                        screenWidth,
                        color: wishlistController.isFavorite(product) ? Colors.red : Colors.black,
                      )),
                      const SizedBox(width: 10),
                      Obx(
                            () => Stack(
                          key: _cartKey,
                          children: [
                            _circleIcon(Icons.shopping_cart_outlined, () {
                              Get.to(() => const CartScreen());
                            }, screenWidth),
                            if (cartController.itemCount > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    "${cartController.itemCount}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 📜 Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🖼️ Product Image
                        Center(
                          child: Container(
                            key: _imageKey,
                            child: Image.network(product.image, height: screenHeight * 0.35),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.025),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🏷️ Category & Subcategory Breadcrumb
                              Row(
                                children: [
                                  Text(
                                    product.category,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.032,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (product.subCategory.isNotEmpty) ...[
                                    Icon(Icons.chevron_right, size: screenWidth * 0.035, color: Colors.grey),
                                    Text(
                                      product.subCategory,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.032,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.01),

                              // 📝 Title
                              Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.012),

                              // ⭐ Rating
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.02,
                                      vertical: screenHeight * 0.005,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: screenWidth * 0.035,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: screenWidth * 0.01),
                                        Text(
                                          product.rating.stars.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    "(${product.rating.count} reviews)",
                                    style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.032),
                                  ),
                                ],
                              ),

                              SizedBox(height: screenHeight * 0.015),

                              // 💰 Price
                              Row(
                                children: [
                                  Text(
                                    "₹${(product.priceCents / 100).toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.06,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.025),
                                  Text(
                                    "₹${((product.priceCents / 100) * 1.2).toStringAsFixed(2)}",
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                      fontSize: screenWidth * 0.04,
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.025),
                                  Text(
                                    "20% OFF",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                      fontSize: screenWidth * 0.04,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: screenHeight * 0.012),

                              // 🚚 Delivery
                              Row(
                                children: [
                                  Icon(Icons.delivery_dining_outlined, color: Colors.green, size: screenWidth * 0.05),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    "Free Delivery",
                                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500, fontSize: screenWidth * 0.035),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                "Estimated delivery: 3-5 business days",
                                style: TextStyle(color: Colors.grey.shade600, fontSize: screenWidth * 0.032),
                              ),

                              SizedBox(height: screenHeight * 0.025),

                              // 🎨 Color Selection (Visible for Nail Polish or Foundation)
                              if (_requiresColorSelection) ...[
                                Text(
                                  "Select Shade",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.012),
                                SizedBox(
                                  height: 80,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _availableColors.length,
                                    itemBuilder: (context, index) {
                                      final shade = _availableColors[index];
                                      final isSelected = _selectedColorName == shade['name'];
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedColorName = shade['name'];
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 45,
                                              height: 45,
                                              margin: const EdgeInsets.only(right: 15),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: shade['color'],
                                                border: Border.all(
                                                  color: isSelected ? Colors.orange : Colors.grey.shade300,
                                                  width: isSelected ? 3 : 1,
                                                ),
                                                boxShadow: isSelected ? [
                                                  BoxShadow(
                                                    color: Colors.orange.withOpacity(0.3),
                                                    blurRadius: 8,
                                                    spreadRadius: 2,
                                                  )
                                                ] : null,
                                              ),
                                              child: isSelected ? const Center(
                                                child: Icon(Icons.check, color: Colors.white, size: 20),
                                              ) : null,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 15, top: 4),
                                              child: Text(
                                                shade['name'],
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                  color: isSelected ? Colors.orange.shade900 : Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.025),
                              ],

                              // 📏 Size Selection (Visible for Clothing and Footwear)
                              if (_requiresSizeSelection) ...[
                                Text(
                                  _isFootwear ? "Select Footwear Size (UK/India)" : "Select Size",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.012),
                                SizedBox(
                                  height: screenHeight * 0.06,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _availableSizes.length,
                                    itemBuilder: (context, index) {
                                      final size = _availableSizes[index];
                                      final isSelected = _selectedSize == size;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedSize = size;
                                          });
                                        },
                                        child: Container(
                                          width: screenWidth * 0.12,
                                          margin: EdgeInsets.only(right: screenWidth * 0.025),
                                          decoration: BoxDecoration(
                                            color: isSelected ? Colors.orange : Colors.white,
                                            border: Border.all(
                                              color: isSelected ? Colors.orange : Colors.grey.shade300,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              size,
                                              style: TextStyle(
                                                color: isSelected ? Colors.white : Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: screenWidth * 0.035,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.025),
                              ],

                              const Divider(),

                              // 🎁 Offers
                              Text(
                                "Available Offers",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.012),

                              _offerItem("10% Instant Discount on ICICI Cards", screenWidth),
                              _offerItem("Buy 2 Get Extra 5% Off", screenWidth),

                              SizedBox(height: screenHeight * 0.025),

                              const Divider(),

                              // 📄 Description
                              Text(
                                "Product Details",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: screenHeight * 0.012),

                              Text(
                                product.description,
                                style: TextStyle(color: Colors.grey, fontSize: screenWidth * 0.035),
                              ),

                              SizedBox(height: screenHeight * 0.1),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 🔻 Bottom Buttons
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _isAnimating ? null : _runAddToCartAnimation,
                        child: Container(
                          height: screenHeight * 0.07,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Text(
                              "Add to Cart",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: _handleBuyNow,
                        child: Container(
                          height: screenHeight * 0.07,
                          color: Colors.orange,
                          child: Center(
                            child: Text(
                              "Buy Now",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.04,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_isAnimating)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Positioned(
                    left: _moveAnimation.value.dx,
                    top: _moveAnimation.value.dy,
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              product.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // 🔘 Circle Icon
  Widget _circleIcon(IconData icon, VoidCallback onTap, double screenWidth, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.025),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: screenWidth * 0.06),
      ),
    );
  }

  // 🎁 Offer Item
  Widget _offerItem(String text, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.015),
      child: Row(
        children: [
          Icon(Icons.local_offer, size: screenWidth * 0.045),
          SizedBox(width: screenWidth * 0.02),
          Expanded(child: Text(text, style: TextStyle(fontSize: screenWidth * 0.035))),
        ],
      ),
    );
  }
}
