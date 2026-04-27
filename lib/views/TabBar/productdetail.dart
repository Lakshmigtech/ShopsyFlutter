import 'package:Shopsy/Controller/cart_controller.dart';
import 'package:Shopsy/Controller/wishlist_controller.dart';
import 'package:Shopsy/models/productmodel.dart';
import 'package:Shopsy/views/TabBar/cart.dart';
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
        cartController.addToCart(product);
        _animationController.reset();
      }
    });
  }

  void _runAddToCartAnimation() {
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
      cartController.addToCart(product);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 🔝 Header
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _circleIcon(Icons.arrow_back, () => Get.back()),
                      const Spacer(),
                      Obx(() => _circleIcon(
                        product.isFavorite.value ? Icons.favorite : Icons.favorite_border,
                        () => wishlistController.toggleFavorite(product),
                        color: product.isFavorite.value ? Colors.red : Colors.black,
                      )),
                      const SizedBox(width: 10),
                      Obx(
                        () => Stack(
                          key: _cartKey,
                          children: [
                            _circleIcon(Icons.shopping_cart_outlined, () {
                              Get.to(() => const CartScreen());
                            }),
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
                            child: Image.network(product.image, height: 250),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 📝 Title
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              // ⭐ Rating
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          product.rating.stars.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "(${product.rating.count} reviews)",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // 💰 Price
                              Row(
                                children: [
                                  Text(
                                    "₹${(product.priceCents / 100).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "₹${((product.priceCents / 100) * 1.2).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "20% OFF",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // 🚚 Delivery
                              const Text(
                                "Free Delivery",
                                style: TextStyle(color: Colors.green),
                              ),

                              const SizedBox(height: 20),

                              const Divider(),

                              // 🎁 Offers
                              const Text(
                                "Available Offers",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              _offerItem("10% Instant Discount on ICICI Cards"),
                              _offerItem("Buy 2 Get Extra 5% Off"),

                              const SizedBox(height: 20),

                              const Divider(),

                              // 📄 Description
                              const Text(
                                "Product Details",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                product.description,
                                style: const TextStyle(color: Colors.grey),
                              ),

                              const SizedBox(height: 80),
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
                          height: 55,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Text(
                              "Add to Cart",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 55,
                        color: Colors.orange,
                        child: const Center(
                          child: Text(
                            "Buy Now",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
  Widget _circleIcon(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
    );
  }

  // 🎁 Offer Item
  Widget _offerItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.local_offer, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
