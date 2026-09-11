import 'package:Shopsy/controller/cart_controller.dart';
import 'package:Shopsy/controller/wishlist_controller.dart';
import 'package:Shopsy/models/product_model.dart';
import 'package:Shopsy/utils/product_ui_helper.dart';
import 'package:Shopsy/utils/screen_utils.dart';
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
    if (ProductUIHelper.requiresSizeSelection(product) && _selectedSize == null) {
      Get.snackbar(
        'Selection Required',
        'Please select a size before adding to cart',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (ProductUIHelper.requiresColorSelection(product) && _selectedColorName == null) {
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
    if (ProductUIHelper.requiresSizeSelection(product) && _selectedSize == null) {
      Get.snackbar(
        'Selection Required',
        'Please select a size before proceeding',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (ProductUIHelper.requiresColorSelection(product) && _selectedColorName == null) {
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
    final bool requiresColorSelection = ProductUIHelper.requiresColorSelection(product);
    final bool requiresSizeSelection = ProductUIHelper.requiresSizeSelection(product);
    final List<Map<String, dynamic>> availableColors = ProductUIHelper.getAvailableColors(product);
    final List<String> availableSizes = ProductUIHelper.getAvailableSizes(product);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 🔝 Header
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    children: [
                      _circleIcon(Icons.arrow_back, () => Get.back()),
                      const Spacer(),
                      Obx(() => _circleIcon(
                        wishlistController.isFavorite(product) ? Icons.favorite : Icons.favorite_border,
                            () => wishlistController.toggleFavorite(product),
                        color: wishlistController.isFavorite(product) ? Colors.red : Colors.black,
                      )),
                      const SizedBox(width: 12),
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
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    "${cartController.itemCount}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
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
                            child: Image.network(
                              product.image, 
                              height: 42.h,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        SizedBox(height: 3.h),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🏷️ Category & Subcategory Breadcrumb
                              Row(
                                children: [
                                  Text(
                                    product.category,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (product.subCategory.isNotEmpty) ...[
                                    Icon(Icons.chevron_right, size: 14.sp, color: Colors.grey),
                                    Text(
                                      product.subCategory,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: 1.2.h),

                              // 📝 Title
                              Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 1.5.h),

                              // ⭐ Rating
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 3.w,
                                      vertical: 0.6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 15.sp,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 1.w),
                                        Text(
                                          product.rating.stars.toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    "(${product.rating.count} reviews)",
                                    style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                                  ),
                                ],
                              ),

                              SizedBox(height: 2.h),

                              // 💰 Price
                              Row(
                                children: [
                                  Text(
                                    ProductUIHelper.getDisplayPrice(product),
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    ProductUIHelper.getOriginalPrice(product),
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    ProductUIHelper.getDiscountPercentage(product),
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 1.5.h),

                              // 🚚 Delivery
                              Row(
                                children: [
                                  Icon(Icons.delivery_dining_outlined, color: Colors.green, size: 6.w),
                                  SizedBox(width: 2.w),
                                  Text(
                                    "Free Delivery",
                                    style: TextStyle(
                                      color: Colors.green, 
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 14.sp
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 0.6.h),
                              Text(
                                "Estimated delivery: 3-5 business days",
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
                              ),

                              SizedBox(height: 3.h),

                              // 🎨 Color Selection
                              if (requiresColorSelection) ...[
                                Text(
                                  "Select Shade",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 1.5.h),
                                SizedBox(
                                  height: 90,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: availableColors.length,
                                    itemBuilder: (context, index) {
                                      final shade = availableColors[index];
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
                                              width: 50,
                                              height: 50,
                                              margin: const EdgeInsets.only(right: 18),
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
                                                child: Icon(Icons.check, color: Colors.white, size: 24),
                                              ) : null,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 18, top: 6),
                                              child: Text(
                                                shade['name'],
                                                style: TextStyle(
                                                  fontSize: 11,
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
                                SizedBox(height: 3.h),
                              ],

                              // 📏 Size Selection
                              if (requiresSizeSelection) ...[
                                Text(
                                  ProductUIHelper.isFootwear(product) ? "Select Footwear Size (UK/India)" : "Select Size",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 1.5.h),
                                SizedBox(
                                  height: 7.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: availableSizes.length,
                                    itemBuilder: (context, index) {
                                      final size = availableSizes[index];
                                      final isSelected = _selectedSize == size;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedSize = size;
                                          });
                                        },
                                        child: Container(
                                          width: 14.w,
                                          margin: EdgeInsets.only(right: 3.w),
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
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 3.h),
                              ],

                              const Divider(),

                              // 🎁 Offers
                              Text(
                                "Available Offers",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 1.5.h),

                              _offerItem("10% Instant Discount on ICICI Cards"),
                              _offerItem("Buy 2 Get Extra 5% Off"),

                              SizedBox(height: 3.h),

                              const Divider(),

                              // 📄 Description
                              Text(
                                "Product Details",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 1.5.h),

                              Text(
                                product.description,
                                style: TextStyle(
                                  color: Colors.grey.shade700, 
                                  fontSize: 15.sp,
                                  height: 1.5,
                                ),
                              ),

                              SizedBox(height: 12.h),
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
                          height: 8.h,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Text(
                              "Add to Cart",
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
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
                          height: 8.h,
                          color: Colors.orange,
                          child: Center(
                            child: Text(
                              "Buy Now",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
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
                          width: 100,
                          height: 100,
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
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 7.w),
      ),
    );
  }

  // 🎁 Offer Item
  Widget _offerItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.w),
      child: Row(
        children: [
          Icon(Icons.local_offer, size: 5.w, color: Colors.orange.shade800),
          SizedBox(width: 3.w),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14.sp))),
        ],
      ),
    );
  }
}
