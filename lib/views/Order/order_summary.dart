import 'package:Shopsy/Controller/cart_controller.dart';
import 'package:Shopsy/Controller/navigation_controller.dart';
import 'package:Shopsy/Controller/order_controller.dart';
import 'package:Shopsy/Controller/address_controller.dart';
import 'package:Shopsy/views/Account/add_address.dart';
import 'package:Shopsy/views/Account/payment.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../TabBar/cart.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  final CartController cartController = Get.find<CartController>();
  final OrderController orderController = Get.find<OrderController>();
  final NavigationController navigationController = Get.find<NavigationController>();
  final AddressController addressController = Get.find<AddressController>();

  final RxString selectedAddress = "".obs;
  late Worker _worker;

  @override
  void initState() {
    super.initState();
    
    // Initial value setup
    _updateDefaultAddress();

    // Register ever() worker
    _worker = ever(addressController.addresses, (_) {
      _updateDefaultAddress();
    });
  }

  void _updateDefaultAddress() {
    if (selectedAddress.value.isEmpty && addressController.addresses.isNotEmpty) {
      final defaultAddr = addressController.addresses.firstWhere(
        (element) => element.isDefault,
        orElse: () => addressController.addresses.first,
      );
      selectedAddress.value = "${defaultAddr.name}, ${defaultAddr.address}";
    }
  }

  @override
  void dispose() {
    _worker.dispose(); // Cancel the worker
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                                  Text("Qty: ${item.quantity}"),
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
            onPressed: () {
              if (selectedAddress.value.isEmpty) {
                Get.snackbar("Error", "Please select a delivery address",
                    backgroundColor: Colors.red, colorText: Colors.white);
                return;
              }

              // Navigate to Payment page with selected address
              Get.to(() =>
                  PaymentMethodsPage(selectedAddress: selectedAddress.value));
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
