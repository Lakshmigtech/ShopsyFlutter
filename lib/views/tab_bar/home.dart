import 'dart:async';
import 'package:Shopsy/controller/cart_controller.dart';
import 'package:Shopsy/controller/navigation_controller.dart';
import 'package:Shopsy/controller/product_controller.dart';
import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/utils/product_ui_helper.dart';
import 'package:Shopsy/views/tab_bar/cart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'product_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ProductController get productController => Get.find<ProductController>();
  CartController get cartController => Get.find<CartController>();
  NavigationController get navigationController => Get.find<NavigationController>();

  final PageController _pageController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  final List<String> _banners = [
    'assets/offerhome.jpg',
    'assets/offerbanner.jpg',
    'assets/banner.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        if (_currentBannerIndex < _banners.length - 1) {
          _currentBannerIndex++;
        } else {
          _currentBannerIndex = 0;
        }
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    return Scaffold(
      backgroundColor: AppColors.textWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenWidth * 0.04),
              // Header
              Row(
                children: [
                  Text(
                    'Shopsy',
                    style: TextStyle(
                      fontSize: screenWidth * 0.065,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.to(() => const CartScreen()),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: screenWidth * 0.07),
                        Obx(() {
                          if (cartController.itemCount <= 0) return const SizedBox.shrink();
                          return Positioned(
                            right: -screenWidth * 0.015,
                            top: -screenWidth * 0.015,
                            child: Container(
                              padding: EdgeInsets.all(screenWidth * 0.01),
                              decoration: const BoxDecoration(
                                color: AppColors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${cartController.itemCount}',
                                style: TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: screenWidth * 0.025,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.04),
              
              // Animated Search Bar
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  TextField(
                    controller: productController.searchController,
                    onChanged: (value) => productController.updateSearchQuery(value),
                    style: TextStyle(fontSize: screenWidth * 0.038),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Obx(() => productController.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                productController.searchController.clear();
                                productController.updateSearchQuery('');
                              },
                            )
                          : const SizedBox.shrink()),
                      filled: true,
                      fillColor: AppColors.grey200,
                      contentPadding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.075),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  // Animated Placeholder Overlay
                  IgnorePointer(
                    child: Padding(
                      padding: EdgeInsets.only(left: screenWidth * 0.12),
                      child: Obx(() {
                        if (productController.searchQuery.value.isNotEmpty) {
                          return const SizedBox.shrink();
                        }
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.8),
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            ProductUIHelper.searchHints[productController.currentHintIndex.value],
                            key: ValueKey<int>(productController.currentHintIndex.value),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: screenWidth * 0.038,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.05),
              
              Obx(() {
                if (productController.searchQuery.value.isNotEmpty) {
                  return _buildSearchResults(screenWidth);
                }
                return _buildHomeContent(screenWidth, screenHeight);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categories
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _category(Icons.apps, 'All', screenWidth),
              _category(Icons.home, 'Home', screenWidth),
              _category(Icons.checkroom, 'Fashion', screenWidth),
              _category(Icons.laptop, 'Electronics', screenWidth),
              _category(Icons.brush, 'Beauty', screenWidth),
            ],
          ),
        ),
        SizedBox(height: screenWidth * 0.05),
        
        // MAIN BANNER SLIDER
        Column(
          children: [
            SizedBox(
              height: screenWidth * 0.45,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentBannerIndex = index;
                  });
                },
                itemCount: _banners.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      productController.resetFilters();
                      navigationController.changeIndex(1);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        child: Image.asset(
                          _banners[index],
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.blue100,
                            child: const Icon(Icons.image, size: 50, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: screenWidth * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _banners.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentBannerIndex == entry.key ? screenWidth * 0.06 : screenWidth * 0.02,
                  height: screenWidth * 0.02,
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenWidth * 0.01),
                    color: _currentBannerIndex == entry.key
                        ? AppColors.primary
                        : AppColors.grey300,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        SizedBox(height: screenWidth * 0.06),
        
        // DEALS OF THE DAY SECTION
        Text(
          'Deals of the Day',
          style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: screenWidth * 0.03),
        Obx(() {
          final deals = productController.dealsOfDay;
          if (productController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (deals.isEmpty) return const SizedBox.shrink();
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: deals.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: screenWidth * 0.03,
                  mainAxisSpacing: screenWidth * 0.03,
                ),
                itemBuilder: (context, index) {
                  return _dealItem(deals[index], screenWidth);
                },
              ),
              SizedBox(height: screenWidth * 0.03),
              GestureDetector(
                onTap: () {
                  productController.resetFilters();
                  navigationController.changeIndex(1);
                },
                child: Text(
                  'See more deals',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: screenWidth * 0.035,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        }),
        
        SizedBox(height: screenHeight * 0.04),
        Text(
          'Recommended for You',
          style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: screenWidth * 0.03),
        Obx(() {
          if (productController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final recommended = productController.recommendedProducts;
          if (recommended.isEmpty) {
            return const Center(child: Text('No recommended products'));
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recommended.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: screenWidth * 0.025,
              mainAxisSpacing: screenWidth * 0.025,
            ),
            itemBuilder: (context, index) {
              final product = recommended[index];
              return _buildProductCard(product, screenWidth);
            },
          );
        }),
        SizedBox(height: screenWidth * 0.08),
      ],
    );
  }

  Widget _buildSearchResults(double screenWidth) {
    final products = productController.productList;
    
    if (productController.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (products.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
              const Icon(Icons.search_off, size: 64, color: AppColors.textGrey),
              const SizedBox(height: 16),
              const Text('No products found matching your search', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Search Results for "${productController.searchQuery.value}"',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return _buildSearchProductItem(products[index], screenWidth);
          },
        ),
      ],
    );
  }

  Widget _buildSearchProductItem(dynamic product, double screenWidth) {
    return GestureDetector(
      onTap: () => Get.to(
        () => const ProductDetailScreen(),
        arguments: product,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: AppColors.textWhite,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: screenWidth * 0.3,
              height: screenWidth * 0.3,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  product.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image, color: AppColors.textGrey, size: screenWidth * 0.1),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: screenWidth * 0.038,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${product.rating.stars}',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const Icon(Icons.star, color: Colors.white, size: 10),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${product.rating.count})',
                        style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Row(
                    children: [
                      Text(
                        ProductUIHelper.getDisplayPrice(product),
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ProductUIHelper.getOriginalPrice(product),
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: AppColors.textGrey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ProductUIHelper.getDiscountPercentage(product),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Free Delivery',
                    style: TextStyle(color: AppColors.success, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _category(IconData icon, String title, double screenWidth) {
    return GestureDetector(
      onTap: () {
        productController.selectCategory(title);
        navigationController.changeIndex(1);
      },
      child: Container(
        margin: EdgeInsets.only(right: screenWidth * 0.05),
        child: Column(
          children: [
            CircleAvatar(
              radius: screenWidth * 0.07,
              backgroundColor: AppColors.grey100,
              child: Icon(icon, color: AppColors.primary, size: screenWidth * 0.07),
            ),
            SizedBox(height: screenWidth * 0.015),
            Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.032,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dealItem(dynamic product, double screenWidth) {
    return GestureDetector(
      onTap: () => Get.to(
        () => const ProductDetailScreen(),
        arguments: product,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.textWhite,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    product.image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, color: AppColors.textGrey, size: 40),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    'Under ${ProductUIHelper.getDisplayPrice(product)}',
                    style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(dynamic product, double screenWidth) {
    return GestureDetector(
      onTap: () => Get.to(
        () => const ProductDetailScreen(),
        arguments: product,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.textWhite,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    product.image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, color: AppColors.textGrey, size: 40),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: screenWidth * 0.035, fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          ProductUIHelper.getDisplayPrice(product),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ProductUIHelper.getDiscountPercentage(product),
                          style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
