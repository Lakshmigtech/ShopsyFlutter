import 'dart:async';
import 'package:Shopsy/controller/cart_controller.dart';
import 'package:Shopsy/controller/navigation_controller.dart';
import 'package:Shopsy/controller/product_controller.dart';
import 'package:Shopsy/constants/app_colors.dart';
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
              // Search Bar
              TextField(
                controller: productController.searchController,
                onChanged: (value) => productController.updateSearchQuery(value),
                decoration: InputDecoration(
                  hintText: 'Search for products...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Obx(() => productController.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => productController.resetFilters(),
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
              SizedBox(height: screenWidth * 0.05),
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
                if (productController.errorMessage.value != null) {
                  return Center(
                    child: Column(
                      children: [
                        Text(productController.errorMessage.value!),
                        SizedBox(height: screenWidth * 0.03),
                        ElevatedButton(
                          onPressed: () => productController.fetchProducts(force: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final recommended = productController.recommendedProducts;
                if (recommended.isEmpty) {
                  return const Center(child: Text('No more recommended products'));
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

                    return GestureDetector(
                      onTap: () => Get.to(
                        () => const ProductDetailScreen(),
                        arguments: product,
                      ),
                      child: Card(
                        elevation: 2,
                        color: AppColors.textWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.02),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Image.network(
                                    product.image,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.broken_image, color: AppColors.textGrey, size: screenWidth * 0.1),
                                  ),
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.015),
                              Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: screenWidth * 0.035,
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.01),
                              Text(
                                '₹${(product.priceCents / 100).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.green,
                                  fontSize: screenWidth * 0.04,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
              SizedBox(height: screenWidth * 0.08),
            ],
          ),
        ),
      ),
    );
  }

  Widget _category(IconData icon, String title, double screenWidth) {
    return Obx(() {
      final isSelected = productController.selectedCategory.value == title;
      return GestureDetector(
        onTap: () {
          productController.selectCategory(title);
          navigationController.changeIndex(1);
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          child: Column(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.07,
                backgroundColor: isSelected ? AppColors.primary : AppColors.blue100,
                child: Icon(icon, color: isSelected ? AppColors.textWhite : AppColors.textBlack, size: screenWidth * 0.06),
              ),
              SizedBox(height: screenWidth * 0.015),
              Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: screenWidth * 0.03,
                  color: isSelected ? AppColors.primary : AppColors.textBlack,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _dealItem(dynamic product, double screenWidth) {
    final discount = (10 + (product.name.length % 40));
    
    return GestureDetector(
      onTap: () => Get.to(
        () => const ProductDetailScreen(),
        arguments: product,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: Image.network(
                  product.image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015, vertical: screenWidth * 0.005),
                decoration: BoxDecoration(
                  color: Colors.red.shade800,
                  borderRadius: BorderRadius.circular(screenWidth * 0.005),
                ),
                child: Text(
                  '$discount% off',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.02,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.015),
              Text(
                'Limited time deal',
                style: TextStyle(
                  color: Colors.red.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.028,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
