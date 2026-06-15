import 'package:Shopsy/controller/cart_controller.dart';
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;

    return Scaffold(
      backgroundColor: AppColors.textWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Obx(() {
            final products = productController.filteredAndSortedProducts;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          const Icon(Icons.shopping_cart_outlined),
                          if (cartController.itemCount > 0)
                            Positioned(
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
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.04),
                TextField(
                  controller: productController.searchController,
                  onChanged: (value) => productController.updateSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Search for products...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: productController.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => productController.resetFilters(),
                          )
                        : const SizedBox.shrink(),
                    filled: true,
                    fillColor: AppColors.grey200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.075),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: screenWidth * 0.05),
                // Scrollable Categories
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  child: Image.asset(
                    'assets/banner.jpg',
                    height: screenWidth * 0.4,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: screenWidth * 0.05),
                Text(
                  'Deals of the Day',
                  style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: screenWidth * 0.025),
                SizedBox(
                  height: screenWidth * 0.2,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(
                      5,
                      (index) => Container(
                        width: screenWidth * 0.4,
                        margin: EdgeInsets.only(right: screenWidth * 0.025),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                        child: Text(
                          'Up to 60% OFF',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenWidth * 0.05),
                Text(
                  'Recommended for You',
                  style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: screenWidth * 0.025),
                if (productController.isLoading.value)
                  const Center(child: CircularProgressIndicator())
                else if (productController.errorMessage.value != null)
                  Center(
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
                  )
                else if (products.isEmpty)
                  const Center(child: Text('No products match your filters'))
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: screenWidth * 0.025,
                      mainAxisSpacing: screenWidth * 0.025,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];

                      return GestureDetector(
                        onTap: () => Get.to(
                          () => const ProductDetailScreen(),
                          arguments: product,
                        ),
                        child: Card(
                          elevation: 3,
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
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _category(IconData icon, String title, double screenWidth) {
    final isSelected = productController.selectedCategory.value == title;
    return GestureDetector(
      onTap: () => productController.selectCategory(title),
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
  }
}
