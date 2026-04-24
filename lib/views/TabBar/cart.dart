import 'package:Shopsy/Controller/cart_controller.dart';
import 'package:Shopsy/views/Order/order_summary.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  CartController get controller => Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text("My Cart"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  "Your cart is empty!",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Cart Items List
            Expanded(
              child: ListView.builder(
                itemCount: controller.cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = controller.cartItems[index];
                  final product = cartItem.product;

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
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
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "₹${cartItem.subtotal.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Free Delivery",
                                style: TextStyle(color: Colors.green),
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () =>
                                        controller.decreaseQuantity(index),
                                    child: _qtyButton(Icons.remove),
                                  ),
                                  const SizedBox(width: 15),
                                  Text(
                                    "${cartItem.quantity.value}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  GestureDetector(
                                    onTap: () =>
                                        controller.increaseQuantity(index),
                                    child: _qtyButton(Icons.add),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () =>
                                        controller.removeFromCart(index),
                                    child: const Text(
                                      "Remove",
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Price Details",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  PriceRow(
                    title: "Price (${controller.itemCount} items)",
                    value: "₹${controller.totalPrice.toStringAsFixed(2)}",
                  ),
                  const PriceRow(
                    title: "Delivery Charges",
                    value: "FREE",
                    isGreen: true,
                  ),
                  const Divider(),
                  PriceRow(
                    title: "Total Amount",
                    value: "₹${controller.totalPrice.toStringAsFixed(2)}",
                    isBold: true,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Get.to(() => const OrderSummaryScreen()),
                  child: const Text(
                    "PLACE ORDER",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      }),
    );
  }

  Widget _qtyButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Icon(icon, size: 18, color: Colors.black),
    );
  }
}

class PriceRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isBold;
  final bool isGreen;

  const PriceRow({
    super.key,
    required this.title,
    required this.value,
    this.isBold = false,
    this.isGreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(title),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isGreen ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
