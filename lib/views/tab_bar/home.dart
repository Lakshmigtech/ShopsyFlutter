import 'dart:async';
import 'package:Shopsy/controller/cart_controller.dart';
import 'package:Shopsy/controller/navigation_controller.dart';
import 'package:Shopsy/controller/product_controller.dart';
import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/utils/currency_utils.dart';
import 'package:Shopsy/utils/screen_utils.dart';
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
                      fontSize: 24.sp, // Increased from screenWidth * 0.065
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.to(() => const CartScreen()),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 28.sp),
                        Obx(() {
                          if (cartController.itemCount <= 0) return const SizedBox.shrink();
                          return Positioned(
                            right: -5,
                            top: -5,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${cartController.itemCount}',
                                style: TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 10.sp,
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
              SizedBox(height: 16.sp),
              
              // Animated Search Bar
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  TextField(
                    controller: productController.searchController,
                    onChanged: (value) => productController.updateSearchQuery(value),
                    style: TextStyle(fontSize: 16.sp),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search, size: 22.sp),
                      suffixIcon: Obx(() => productController.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, size: 20.sp),
                              onPressed: () {
                                productController.searchController.clear();
                                productController.updateSearchQuery('');
                              },
                            )
                          : const SizedBox.shrink()),
                      filled: true,
                      fillColor: AppColors.grey200,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.sp),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.sp),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  // Animated Placeholder Overlay
                  IgnorePointer(
                    child: Padding(
                      padding: EdgeInsets.only(left: 45.sp),
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
                            productController.searchHints[productController.currentHintIndex.value],
                            key: ValueKey<int>(productController.currentHintIndex.value),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16.sp,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.sp),
              
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
        SizedBox(height: 20.sp),
        
        // MAIN BANNER SLIDER
        Column(
          children: [
            SizedBox(
              height: 180.sp,
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
                      padding: EdgeInsets.symmetric(horizontal: 4.sp),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.sp),
                        child: Image.asset(
                          _banners[index],
                          fit: BoxFit.fill,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.blue100,
                            child: Icon(Icons.image, size: 50.sp, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _banners.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentBannerIndex == entry.key ? 24.sp : 8.sp,
                  height: 8.sp,
                  margin: EdgeInsets.symmetric(horizontal: 4.sp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.sp),
                    color: _currentBannerIndex == entry.key
                        ? AppColors.primary
                        : AppColors.grey300,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        SizedBox(height: 24.sp),
        
        // DEALS OF THE DAY SECTION
        Text(
          'Deals of the Day',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.sp),
        Obx(() {
          final deals = productController.dealsOfDay;
          if (productController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (deals.isEmpty) return const SizedBox.shrink();
          
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: deals.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12.sp,
              mainAxisSpacing: 12.sp,
            ),
            itemBuilder: (context, index) {
              return _dealItem(deals[index], screenWidth);
            },
          );
        }),
        
        SizedBox(height: 24.sp),
        
        // ALL PRODUCTS SECTION
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Products',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                navigationController.changeIndex(1);
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.sp),
        Obx(() {
          if (productController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final allProducts = productController.allProducts;
          if (allProducts.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: allProducts.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10.sp,
              mainAxisSpacing: 10.sp,
            ),
            itemBuilder: (context, index) {
              final product = allProducts[index];
              return _buildProductCard(product, screenWidth);
            },
          );
        }),
        SizedBox(height: 32.sp),
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
          padding: EdgeInsets.only(top: 50.sp),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 64.sp, color: AppColors.textGrey),
              SizedBox(height: 16.sp),
              Text(
                'No products found matching your search', 
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.sp),
          child: Text(
            'Search Results for "${productController.searchQuery.value}"',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
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
        padding: EdgeInsets.symmetric(vertical: 12.sp),
        color: AppColors.textWhite,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 100.sp,
              height: 100.sp,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8.sp),
              ),
              child: Padding(
                padding: EdgeInsets.all(8.sp),
                child: Image.network(
                  product.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image, color: AppColors.textGrey, size: 40.sp),
                ),
              ),
            ),
            SizedBox(width: 16.sp),
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
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 6.sp),
                  // Rating
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 2.sp),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(4.sp),
                        ),
                        child: Row(
                          children: [
                            Text(
                              product.rating.stars.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 2.sp),
                            Icon(Icons.star, color: Colors.white, size: 12.sp),
                          ],
                        ),
                      ),
                      SizedBox(width: 6.sp),
                      Text(
                        '(${product.rating.count})',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.sp),
                  // Price
                  Text(
                    '₹${CurrencyUtils.formatPrice(product.price)}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.sp),
                  Text(
                    'Free delivery',
                    style: TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
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
      child: Card(
        elevation: 2,
        color: AppColors.textWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.sp),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Image.network(
                    product.image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, color: AppColors.textGrey, size: 40.sp),
                  ),
                ),
              ),
              SizedBox(height: 8.sp),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 4.sp),
              Text(
                '₹${CurrencyUtils.formatPrice(product.price)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                  fontSize: 16.sp,
                ),
              ),
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
          padding: EdgeInsets.symmetric(horizontal: 8.sp),
          child: Column(
            children: [
              CircleAvatar(
                radius: 28.sp,
                backgroundColor: isSelected ? AppColors.primary : AppColors.blue100,
                child: Icon(icon, color: isSelected ? AppColors.textWhite : AppColors.textBlack, size: 24.sp),
              ),
              SizedBox(height: 6.sp),
              Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13.sp,
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
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(8.sp),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(12.sp),
                  child: Image.network(
                    product.image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 4.sp),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 2.sp),
                        decoration: BoxDecoration(
                          color: Colors.red.shade800,
                          borderRadius: BorderRadius.circular(2.sp),
                        ),
                        child: Text(
                          '$discount% off',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.sp),
                      Text(
                        'Deal',
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
