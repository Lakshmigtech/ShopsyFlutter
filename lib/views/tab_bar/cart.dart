import 'package:Shopsy/controller/cart_controller.dart';
import 'package:Shopsy/utils/screen_utils.dart';
import 'package:Shopsy/utils/product_ui_helper.dart';
import 'package:Shopsy/views/order/order_summary.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Shopsy/constants/app_colors.dart';

class CartScreen extends GetView<CartController> {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff1f2f6),
      appBar: AppBar(
        title: Text(
          "My Cart",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
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
        if (controller.cartItems.isEmpty) {
          return _buildEmptyCart();
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Cart Items List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.cartItems.length,
                      itemBuilder: (context, index) {
                        final item = controller.cartItems[index];
                        return _buildCartItem(context, item, index);
                      },
                    ),

                    // Price Details Section
                    _buildPriceDetails(),
                    SizedBox(height: 5.w),
                  ],
                ),
              ),
            ),
            // Bottom Checkout Bar
            _buildBottomBar(context),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 60.w,
            color: AppColors.textGrey,
          ),
          SizedBox(height: 4.w),
          Text(
            "Your cart is empty",
            style: TextStyle(
              fontSize: 18.sp,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, dynamic item, int index) {
    return Container(
      margin: EdgeInsets.only(
        left: 3.w,
        right: 3.w,
        top: 3.w,
      ),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  color: AppColors.textWhite,
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Image.network(
                  item.product.image,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.broken_image, color: AppColors.textGrey, size: 10.w),
                ),
              ),
              SizedBox(width: 4.w),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    if (item.size != null || item.color != null) ...[
                      SizedBox(height: 1.w),
                      Row(
                        children: [
                          if (item.size != null)
                            Text(
                              "Size: ${item.size}",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          if (item.size != null && item.color != null)
                            Text(" | ", style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
                          if (item.color != null)
                            Text(
                              "Color: ${item.color}",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                    SizedBox(height: 2.w),
                    Text(
                      ProductUIHelper.getDisplayPrice(item.product),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.w),
                    Text(
                      "Free Delivery",
                      style: TextStyle(
                        color: const Color(0xff388e3c),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.w),
          // Quantity and Remove
          Row(
            children: [
              Row(
                children: [
                  _quantityButton(
                    icon: Icons.remove,
                    onTap: () => controller.decreaseQuantity(index),
                  ),
                  Container(
                    width: 10.w,
                    alignment: Alignment.center,
                    child: Text(
                      "${item.quantity}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  _quantityButton(
                    icon: Icons.add,
                    onTap: () => controller.increaseQuantity(index),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => controller.removeFromCart(index),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 2.w,
                    horizontal: 4.w,
                  ),
                  child: Text(
                    "Remove",
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 8.w,
        height: 8.w,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderGrey),
          borderRadius: BorderRadius.circular(1.w),
        ),
        child: Icon(icon, size: 5.w, color: const Color(0xff2874f0)),
      ),
    );
  }

  Widget _buildPriceDetails() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 3.w,
        vertical: 3.w,
      ),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Price Details",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          Divider(height: 8.w),
          _priceRow("Price", ProductUIHelper.formatPrice(controller.totalPrice)),
          SizedBox(height: 4.w),
          _priceRow("Delivery Charges", "FREE", isGreen: true),
          Divider(height: 8.w),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Amount",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ProductUIHelper.formatPrice(controller.totalPrice),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: Colors.black87),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: isGreen ? const Color(0xff388e3c) : AppColors.textBlack,
            fontWeight: isGreen ? FontWeight.bold : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 3.w,
      ),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ProductUIHelper.formatPrice(controller.totalPrice),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "View price details",
                  style: TextStyle(
                    color: const Color(0xff2874f0),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 12.w,
              child: ElevatedButton(
                onPressed: () => Get.to(() => const OrderSummaryPage()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffff8c31),
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1.w),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Place Order",
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
