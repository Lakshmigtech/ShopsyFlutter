import 'package:Shopsy/controller/cart_controller.dart';
import 'package:Shopsy/controller/navigation_controller.dart';
import 'package:Shopsy/controller/order_controller.dart';
import 'package:Shopsy/controller/address_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Shopsy/views/account/payment.dart';

class OrderSummaryPage extends StatelessWidget {
  const OrderSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final orderController = Get.find<OrderController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Summary"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Shipping Address",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Obx(() => Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(orderController.selectedAddress.value.isEmpty
                      ? "No address selected"
                      : orderController.selectedAddress.value),
                )),
            const SizedBox(height: 24),
            const Text("Order Items",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cartController.cartItems.length,
              itemBuilder: (context, index) {
                final item = cartController.cartItems[index];
                return ListTile(
                  leading: Image.network(item.product.image, width: 50),
                  title: Text(item.product.name),
                  subtitle: Text("Qty: ${item.quantity}"),
                  trailing: Text("₹${item.subtotal.toStringAsFixed(2)}"),
                );
              },
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("₹${cartController.totalPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (orderController.selectedAddress.value.isEmpty) {
                    Get.snackbar("Error", "Please select a shipping address");
                    return;
                  }
                  Get.to(() => PaymentMethodsPage(
                      selectedAddress: orderController.selectedAddress.value));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Proceed to Payment"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
