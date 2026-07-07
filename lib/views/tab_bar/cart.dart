import 'package:Shopsy/controller/cart_controller.dart';
import 'package:Shopsy/utils/currency_utils.dart';
import 'package:Shopsy/views/order/order_summary.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Shopsy/constants/app_colors.dart';

class CartScreen extends GetView<CartController> {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;

    return Scaffold(
      backgroundColor: const Color(0xfff1f2f6),
      appBar: AppBar(
        title: Text(
          "My Cart",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.textWhite,
        foregroundColor: AppColors.textBlack,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: screenWidth * 0.06),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return _buildEmptyCart(screenWidth);
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
                        return _buildCartItem(context, item, index, screenWidth);
                      },
                    ),

                    // Price Details Section
                    _buildPriceDetails(screenWidth),
                    SizedBox(height: screenWidth * 0.05),
                  ],
                ),
              ),
            ),
            // Bottom Checkout Bar
            _buildBottomBar(context, screenWidth),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCart(double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: screenWidth * 0.16,
            color: AppColors.textGrey,
          ),
          SizedBox(height: screenWidth * 0.04),
          Text(
            "Your cart is empty",
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, dynamic item, int index, double screenWidth) {
    String formattedPrice = CurrencyUtils.formatPrice(item.product.priceCents / 100);

    return Container(
      margin: EdgeInsets.only(
        left: screenWidth * 0.03,
        right: screenWidth * 0.03,
        top: screenWidth * 0.03,
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
                decoration: BoxDecoration(
                  color: AppColors.textWhite,
                  borderRadius: BorderRadius.circular(screenWidth * 0.01),
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
                      Icon(Icons.broken_image, color: AppColors.textGrey, size: screenWidth * 0.1),
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
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
                        fontSize: screenWidth * 0.038,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    if (item.size != null) ...[
                      SizedBox(height: screenWidth * 0.01),
                      Text(
                        "Size: ${item.size}",
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    SizedBox(height: screenWidth * 0.02),
                    Text(
                      "₹$formattedPrice",
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Text(
                      "Free Delivery",
                      style: TextStyle(
                        color: const Color(0xff388e3c),
                        fontSize: screenWidth * 0.032,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: screenWidth * 0.04),
          // Quantity and Remove
          Row(
            children: [
              Row(
                children: [
                  _quantityButton(
                    icon: Icons.remove,
                    onTap: () => controller.decreaseQuantity(index),
                    screenWidth: screenWidth,
                  ),
                  Container(
                    width: screenWidth * 0.1,
                    alignment: Alignment.center,
                    child: Text(
                      "${item.quantity}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                  ),
                  _quantityButton(
                    icon: Icons.add,
                    onTap: () => controller.increaseQuantity(index),
                    screenWidth: screenWidth,
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => controller.removeFromCart(index),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenWidth * 0.02,
                    horizontal: screenWidth * 0.04,
                  ),
                  child: Text(
                    "Remove",
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth * 0.035,
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
    required double screenWidth,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.08,
        height: screenWidth * 0.08,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderGrey),
          borderRadius: BorderRadius.circular(screenWidth * 0.01),
        ),
        child: Icon(icon, size: screenWidth * 0.045, color: const Color(0xff2874f0)),
      ),
    );
  }

  Widget _buildPriceDetails(double screenWidth) {
    String formattedPrice = CurrencyUtils.formatPrice(controller.totalPrice);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenWidth * 0.03,
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(screenWidth * 0.01),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Price Details",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
            ),
          ),
          Divider(height: screenWidth * 0.08),
          _priceRow("Price", "₹$formattedPrice", screenWidth),
          SizedBox(height: screenWidth * 0.04),
          _priceRow("Delivery Charges", "FREE", screenWidth, isGreen: true),
          Divider(height: screenWidth * 0.08),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Amount",
                style: TextStyle(
                  fontSize: screenWidth * 0.042,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "₹$formattedPrice",
                style: TextStyle(
                  fontSize: screenWidth * 0.042,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, double screenWidth, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: screenWidth * 0.035, color: Colors.black87),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            color: isGreen ? const Color(0xff388e3c) : AppColors.textBlack,
            fontWeight: isGreen ? FontWeight.bold : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, double screenWidth) {
    String formattedPrice = CurrencyUtils.formatPrice(controller.totalPrice);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.03,
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
                  "₹$formattedPrice",
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "View price details",
                  style: TextStyle(
                    color: const Color(0xff2874f0),
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: screenWidth * 0.12,
              child: ElevatedButton(
                onPressed: () => Get.to(() => const OrderSummaryPage()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffff8c31),
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.01),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Place Order",
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: screenWidth * 0.04,
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
