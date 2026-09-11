import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/controller/wishlist_controller.dart';
import 'package:Shopsy/utils/product_ui_helper.dart';
import 'package:Shopsy/utils/screen_utils.dart';
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
        title: Text(
          "My Favorites",
          style: TextStyle(
            color: AppColors.textBlack,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.textWhite,
        foregroundColor: AppColors.textBlack,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.wishlistItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 40.w,
                  color: AppColors.textGrey,
                ),
                SizedBox(height: 6.w),
                Text(
                  "Your wishlist is empty!",
                  style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 2.w),
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
                padding: EdgeInsets.all(4.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 30.w,
                      width: 25.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.w),
                        color: AppColors.textWhite,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2.w),
                        child: Image.network(
                          product.image,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image, color: AppColors.textGrey, size: 10.w),
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
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
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2.w),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.green,
                                  borderRadius: BorderRadius.circular(1.w),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 14.sp,
                                      color: AppColors.white,
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      product.rating.stars.toString(),
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                "(${product.rating.count} reviews)",
                                style: TextStyle(
                                  color: AppColors.textGrey,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.w),
                          Row(
                            children: [
                              Text(
                                ProductUIHelper.getDisplayPrice(product),
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                ProductUIHelper.getOriginalPrice(product),
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColors.textGrey,
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                ProductUIHelper.getDiscountPercentage(product),
                                style: TextStyle(
                                  color: AppColors.green,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.5.w),
                          Text(
                            'Free Delivery',
                            style: TextStyle(
                              color: AppColors.green, 
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => controller.toggleFavorite(product),
                          icon: Icon(Icons.favorite, color: AppColors.redAccent, size: 7.w),
                        ),
                        SizedBox(height: 6.w),
                        Icon(Icons.chevron_right, color: AppColors.textGrey, size: 6.w),
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
