import 'package:Shopsy/Controller/cart_controller.dart';
import 'package:Shopsy/Controller/navigation_controller.dart';
import 'package:Shopsy/Controller/order_controller.dart';
import 'package:Shopsy/Controller/payment_controller.dart';
import 'package:Shopsy/models/ordermodel.dart';
import 'package:Shopsy/views/Bottom_Navigation/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentMethodsPage extends StatelessWidget {
  final String selectedAddress;
  const PaymentMethodsPage({super.key, this.selectedAddress = ""});

  Widget paymentTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isDefault = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const SizedBox(width: 15),

            /// TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            /// DEFAULT BADGE
            if (isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Default",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentController = Get.find<PaymentController>();
    final cartController = Get.find<CartController>();
    final orderController = Get.find<OrderController>();
    final navigationController = Get.find<NavigationController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      /// APPBAR
      appBar: AppBar(
        title: const Text("Payment Methods"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.black,
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          /// MAIN CARD
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                paymentTile(
                  icon: Icons.credit_card,
                  title: "Visa Card",
                  subtitle: "**** 4589",
                  isDefault: true,
                  onTap: () => paymentController.openCheckout(
                    cartController.totalPrice, 
                    "9876543210", 
                    "user@example.com"
                  ),
                ),

                const Divider(),

                paymentTile(
                  icon: Icons.qr_code,
                  title: "Google Pay",
                  subtitle: "lakshmi@upi",
                  onTap: () => paymentController.openCheckout(
                    cartController.totalPrice, 
                    "9876543210", 
                    "user@example.com"
                  ),
                ),

                const Divider(),

                paymentTile(
                  icon: Icons.money,
                  title: "Cash on Delivery",
                  subtitle: "Pay at your doorstep",
                  onTap: () {
                    Get.defaultDialog(
                      title: "Confirm Order",
                      middleText: "Place order with Cash on Delivery?",
                      textConfirm: "Confirm",
                      confirmTextColor: Colors.white,
                      onConfirm: () async {
                        // 1. Create Order object
                        final newOrder = OrderModel(
                          orderId: DateTime.now().millisecondsSinceEpoch.toString(),
                          items: cartController.cartItems.map((item) => OrderItem(
                            productId: item.product.id,
                            productName: item.product.name,
                            productImage: item.product.image,
                            quantity: item.quantity.value,
                            price: item.subtotal,
                          )).toList(),
                          totalAmount: cartController.totalPrice,
                          address: selectedAddress,
                          dateTime: DateTime.now(),
                          status: "Confirmed (COD)",
                        );

                        // 2. Save order locally
                        await orderController.placeOrder(newOrder);

                        // 3. Clear cart
                        cartController.cartItems.clear();

                        // 4. Go Home
                        navigationController.changeIndex(0);
                        Get.offAll(() => const MainNavigation());

                        // 5. Show Success
                        Get.snackbar("Success", "Order placed successfully with COD!",
                            backgroundColor: Colors.green, colorText: Colors.white);
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// ADD PAYMENT METHOD
          GestureDetector(
            onTap: () {
              // Trigger Razorpay with total amount
              paymentController.openCheckout(
                cartController.totalPrice, 
                "9876543210", // Prefilled sample contact
                "user@example.com" // Prefilled sample email
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text(
                      "Add Payment Method (Razorpay Test)",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
