import 'package:Shopsy/Controller/cart_controller.dart';
import 'package:Shopsy/Controller/navigation_controller.dart';
import 'package:Shopsy/Controller/order_controller.dart';
import 'package:Shopsy/Controller/address_controller.dart';
import 'package:Shopsy/models/ordermodel.dart';
import 'package:Shopsy/views/Account/add_address.dart';
import 'package:Shopsy/views/Bottom_Navigation/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../TabBar/cart.dart';

class OrderSummaryScreen extends StatelessWidget {
  OrderSummaryScreen({super.key});

  final CartController cartController = Get.find<CartController>();
  final OrderController orderController = Get.put(OrderController());
  final NavigationController navigationController = Get.find<NavigationController>();
  final AddressController addressController = Get.find<AddressController>();

  @override
  Widget build(BuildContext context) {
    // Current selected address - Initialize with default or first saved address
    final RxString selectedAddress = "".obs;
    
    // Use an effect or a worker if you want to react to address changes while this screen is open
    ever(addressController.addresses, (_) {
      if (selectedAddress.value.isEmpty && addressController.addresses.isNotEmpty) {
        final defaultAddr = addressController.addresses.firstWhere(
          (element) => element.isDefault,
          orElse: () => addressController.addresses.first,
        );
        selectedAddress.value = "${defaultAddr.name}, ${defaultAddr.address}";
      }
    });

    // Initial value setup
    if (addressController.addresses.isNotEmpty) {
      final defaultAddr = addressController.addresses.firstWhere(
        (element) => element.isDefault,
        orElse: () => addressController.addresses.first,
      );
      selectedAddress.value = "${defaultAddr.name}, ${defaultAddr.address}";
    }

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
                          _showAddressBottomSheet(context, selectedAddress);
                        },
                        child: const Text("Change"),
                      ),
                    ],
                  ),
                  Obx(() => Text(
                        selectedAddress.value.isEmpty 
                            ? "No address selected. Please add an address." 
                            : selectedAddress.value,
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
                    itemCount: cartController.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartController.cartItems[index];
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
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
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
                    title: "Price (${cartController.itemCount} items)",
                    value: "₹${cartController.totalPrice.toStringAsFixed(2)}",
                  ),
                  const PriceRow(
                    title: "Delivery Charges",
                    value: "FREE",
                    isGreen: true,
                  ),
                  const Divider(),
                  PriceRow(
                    title: "Total Amount",
                    value: "₹${cartController.totalPrice.toStringAsFixed(2)}",
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
            onPressed: () async {
              if (selectedAddress.value.isEmpty) {
                Get.snackbar("Error", "Please select a delivery address", backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }

              // 1. Create Order object
              final newOrder = OrderModel(
                orderId: DateTime.now().millisecondsSinceEpoch.toString(),
                items: cartController.cartItems
                    .map((item) => OrderItem(
                          productId: item.product.id,
                          productName: item.product.name,
                          productImage: item.product.image,
                          quantity: item.quantity.value,
                          price: item.subtotal,
                        ))
                    .toList(),
                totalAmount: cartController.totalPrice,
                address: selectedAddress.value,
                dateTime: DateTime.now(),
              );

              // 2. Save to local storage via Controller
              await orderController.placeOrder(newOrder);

              // 3. Clear Cart
              cartController.cartItems.clear();

              // 4. Reset Navigation to Home (Index 0)
              navigationController.changeIndex(0);

              // 5. Navigate to Main Navigation (Home)
              Get.offAll(() => const MainNavigation());

              // 6. Show success
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

  void _showAddressBottomSheet(BuildContext context, RxString currentAddress) {
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
              child: Obx(() => ListView.separated(
                shrinkWrap: true,
                itemCount: addressController.addresses.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final addr = addressController.addresses[index];
                  final fullAddrString = "${addr.name}, ${addr.address}";
                  return Obx(() {
                    final isSelected = currentAddress.value == fullAddrString;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected ? Colors.orange : Colors.grey,
                      ),
                      title: Text(
                        addr.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(addr.address),
                      onTap: () {
                        currentAddress.value = fullAddrString;
                        Get.back();
                      },
                    );
                  });
                },
              )),
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
                  // Navigate to AddAddressScreen directly
                  Get.to(() => const AddAddressScreen());
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
}
