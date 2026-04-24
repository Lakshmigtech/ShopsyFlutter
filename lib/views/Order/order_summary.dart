import 'package:Shopsy/Controller/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../TabBar/cart.dart';

class OrderSummaryScreen extends StatelessWidget {
  const OrderSummaryScreen({super.key});

  CartController get controller => Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    // Current selected address
    final RxString selectedAddress =
        "123, Street Name, City, State, 123456".obs;

    // Dummy list of saved addresses
    final List<String> savedAddresses = [
      "123, Street Name, City, State, 123456",
      "456, Apartment Block, Business District, City, 654321",
      "789, Green Villa, Suburban Area, City, 987654",
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text("Order Summary"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Delivery Address Section
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Deliver to:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _showAddressBottomSheet(
                              context, selectedAddress, savedAddresses);
                        },
                        child: const Text("Change"),
                      ),
                    ],
                  ),
                  Obx(() => Text(
                        selectedAddress.value,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      )),
                ],
              ),
            ),

            // Order Items Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Order Details",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = controller.cartItems[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product.image,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Text("Qty: ${item.quantity.value}"),
                                ],
                              ),
                            ),
                            Text(
                              "₹${item.subtotal.toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Price Details
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
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
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
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
            onPressed: () {
              Get.snackbar(
                "Order Placed",
                "Your order has been placed successfully!",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text(
              "CONFIRM ORDER",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddressBottomSheet(BuildContext context, RxString currentAddress,
      List<String> savedAddresses) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
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
                  'Select Delivery Address',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: savedAddresses.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final address = savedAddresses[index];
                  return Obx(() {
                    final isSelected = currentAddress.value == address;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected ? Colors.orange : Colors.grey,
                      ),
                      title: Text(
                        address,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        currentAddress.value = address;
                        Get.back();
                      },
                    );
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Get.back();
                  _showAddNewAddressDialog(context, currentAddress);
                },
                icon: const Icon(Icons.add, color: Colors.orange),
                label: const Text(
                  "Add New Address",
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showAddNewAddressDialog(BuildContext context, RxString currentAddress) {
    final TextEditingController addressEditController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Address"),
        content: TextField(
          controller: addressEditController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Enter complete address",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (addressEditController.text.isNotEmpty) {
                currentAddress.value = addressEditController.text;
                Navigator.pop(context);
              }
            },
            child: const Text("Save & Use"),
          ),
        ],
      ),
    );
  }
}
