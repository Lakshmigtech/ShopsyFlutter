import 'package:Shopsy/controller/cart_controller.dart';
import 'package:Shopsy/controller/productcontroller.dart';
import 'package:Shopsy/controller/wishlist_controller.dart';
import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/views/tabbar/cart.dart';
import 'package:Shopsy/views/tabbar/productdetail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  ProductController get controller => Get.find<ProductController>();
  CartController get cartController => Get.find<CartController>();
  WishlistController get wishlistController => Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Products',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showSortBottomSheet(context),
                    child: _iconBtn(Icons.swap_vert),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _showFilterBottomSheet(context),
                    child: _iconBtn(Icons.tune),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => Get.to(() => const CartScreen()),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _iconBtn(Icons.shopping_cart_outlined),
                        Obx(() => cartController.itemCount > 0
                          ? Positioned(
                              right: -4,
                              top: -4,
                              child: CircleAvatar(
                                radius: 9,
                                backgroundColor: AppColors.error,
                                child: Text(
                                  '${cartController.itemCount}',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.errorMessage.value != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(controller.errorMessage.value!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () =>
                              controller.fetchProducts(force: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final products = controller.filteredAndSortedProducts;

                if (products.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                return ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return InkWell(
                      onTap: () => Get.to(
                        () => const ProductDetailScreen(),
                        arguments: product,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 100,
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.grey100,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  product.image,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => 
                                      const Icon(Icons.broken_image, color: AppColors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.success,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              size: 14,
                                              color: AppColors.white,
                                            ),
                                            const SizedBox(width: 2),
                                            Text(
                                              product.rating.stars.toString(),
                                              style: const TextStyle(
                                                color: AppColors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "(${product.rating.count} reviews)",
                                        style: const TextStyle(
                                          color: AppColors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        '₹${(product.priceCents / 100).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '₹${((product.priceCents / 100) * 1.2).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: AppColors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '20% off',
                                        style: TextStyle(
                                          color: AppColors.success,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Free Delivery',
                                    style: TextStyle(color: AppColors.success, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Obx(() => IconButton(
                                  onPressed: () => wishlistController.toggleFavorite(product),
                                  icon: Icon(
                                    wishlistController.isFavorite(product) ? Icons.favorite : Icons.favorite_border,
                                    color: AppColors.error,
                                  ),
                                )),
                                const SizedBox(height: 20),
                                const Icon(Icons.chevron_right, color: AppColors.grey),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sort By',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _sortOptionTile('Popularity', SortOption.popularity),
            _sortOptionTile('Price low to high', SortOption.priceLowToHigh),
            _sortOptionTile('Price high to low', SortOption.priceHighToLow),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    controller.resetFilters();
                  },
                  child: const Text('Reset All'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Categories',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Obx(() => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: controller.categories.map((category) {
                    final isSelected = controller.selectedCategory.value == category;
                    return GestureDetector(
                      onTap: () => controller.selectCategory(category),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.grey100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.grey300,
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? AppColors.white : AppColors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),
            const SizedBox(height: 20),
            const Text(
              'Price Range',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Obx(() {
              double maxLimit = controller.maxPriceLimit.value;
              if (maxLimit <= 0) maxLimit = 5000;
              return Column(
                children: [
                  RangeSlider(
                    values: RangeValues(
                        controller.minPrice.value, controller.maxPrice.value),
                    min: 0,
                    max: maxLimit,
                    divisions: (maxLimit / 10).ceil().clamp(1, 100),
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primary.withOpacity(0.2),
                    labels: RangeLabels(
                      '₹${controller.minPrice.value.round()}',
                      '₹${controller.maxPrice.value.round()}',
                    ),
                    onChanged: (RangeValues values) {
                      controller.updatePriceRange(values.start, values.end);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹0', style: TextStyle(color: AppColors.grey700, fontSize: 12)),
                        Text('₹${maxLimit.round()}', style: TextStyle(color: AppColors.grey700, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),
            const Text(
              'Rating',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(5, (index) {
                    int rating = index + 1;
                    bool isSelected = controller.selectedRating.value == rating;
                    return GestureDetector(
                      onTap: () => controller.updateRating(rating),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.grey100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '$rating',
                              style: TextStyle(
                                color: isSelected ? AppColors.white : AppColors.black,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.star,
                              size: 16,
                              color: isSelected ? AppColors.white : AppColors.warning,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                )),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Get.back(),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(color: AppColors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _sortOptionTile(String title, SortOption option) {
    return Obx(() {
      final isSelected = controller.selectedSortOption.value == option;
      return ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check, color: AppColors.primary)
            : null,
        onTap: () {
          controller.updateSortOption(option);
          Get.back();
        },
      );
    });
  }

  // 🔘 Icon Button
  Widget _iconBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        shape: BoxShape.circle,
      ),
      child: Icon(icon),
    );
  }
}
