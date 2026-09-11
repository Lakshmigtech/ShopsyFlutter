import 'package:Shopsy/controller/cart_controller.dart';
import 'package:Shopsy/controller/product_controller.dart';
import 'package:Shopsy/controller/wishlist_controller.dart';
import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/models/sort_option.dart';
import 'package:Shopsy/utils/product_ui_helper.dart';
import 'package:Shopsy/views/tab_bar/cart.dart';
import 'package:Shopsy/views/tab_bar/product_detail.dart';
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
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const CartScreen()),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.searchController,
                      onChanged: (value) => controller.updateSearchQuery(value),
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: () => _showSortBottomSheet(context),
                    icon: const Icon(Icons.sort),
                  ),
                  IconButton(
                    onPressed: () => _showFilterBottomSheet(context),
                    icon: const Icon(Icons.filter_list),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = controller.filteredAndSortedProducts;

                if (products.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return GestureDetector(
                      onTap: () => Get.to(
                        () => const ProductDetailScreen(),
                        arguments: product,
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product.image,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 100,
                                  height: 100,
                                  color: AppColors.grey100,
                                  child: const Icon(Icons.image),
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
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
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
                                        ProductUIHelper.getDisplayPrice(product),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        ProductUIHelper.getOriginalPrice(product),
                                        style: const TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: AppColors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        ProductUIHelper.getDiscountPercentage(product),
                                        style: const TextStyle(
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
                  children: ProductUIHelper.categories.map((category) {
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
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(color: AppColors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
