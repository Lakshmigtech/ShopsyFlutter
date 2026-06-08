import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/controller/wishlist_controller.dart';
import 'package:Shopsy/views/tab_bar/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  WishlistController get controller => Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textWhite,
      appBar: AppBar(
        title: const Text("My Favorites"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.textWhite,
        foregroundColor: AppColors.textBlack,
      ),
      body: Obx(() {
        if (controller.wishlistItems.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: AppColors.textGrey,
                ),
                SizedBox(height: 16),
                Text(
                  "Your wishlist is empty!",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: controller.wishlistItems.length,
          separatorBuilder: (_, index) => const Divider(),
          itemBuilder: (context, index) {
            final product = controller.wishlistItems[index];

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
                        color: AppColors.borderGrey,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          product.image,
                          fit: BoxFit.cover,
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
                                  color: AppColors.green,
                                  borderRadius: BorderRadius.circular(5),
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
                                  color: AppColors.textGrey,
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
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColors.textGrey,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '20% off',
                                style: TextStyle(color: AppColors.green),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Free Delivery',
                            style: TextStyle(color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () => controller.toggleFavorite(product),
                          icon: const Icon(Icons.favorite, color: AppColors.redAccent),
                        ),
                        const SizedBox(height: 20),
                        const Icon(Icons.chevron_right, color: AppColors.textGrey),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
