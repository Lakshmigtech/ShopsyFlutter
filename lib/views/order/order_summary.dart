import 'package:Shopsy/controller/cart_controller.dart';
import 'package:Shopsy/controller/order_controller.dart';
import 'package:Shopsy/controller/address_controller.dart';
import 'package:Shopsy/views/account/add_address.dart';
import 'package:Shopsy/views/account/payment.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderSummaryPage extends StatelessWidget {
  const OrderSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final orderController = Get.find<OrderController>();
    final addressController = Get.find<AddressController>();

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

      appBar: AppBar(
        title: const Text(
          "Order Summary",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            /// DELIVERY ADDRESS
            const Text(
              "Delivery Address",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Obx(() {

              final addresses = addressController.addresses;

              // NO ADDRESS
              if (addresses.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        "No address added",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        height: 45,

                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.to(() => const AddAddressScreen());
                          },

                          icon: const Icon(Icons.add_location_alt),

                          label: const Text(
                            "Add Address",
                          ),

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // SELECTED / DEFAULT ADDRESS
              final selectedAddress = addresses.firstWhere(
                    (e) => e.isDefault,
                orElse: () => addresses.first,
              );

              final fullAddress =
                  "${selectedAddress.name}\n"
                  "${selectedAddress.address}\n"
                  "${selectedAddress.phone}";

              // SAVE SELECTED ADDRESS
              orderController.selectedAddress.value = fullAddress;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.deepPurple.shade100,
                  ),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Row(
                      children: [

                        const Icon(
                          Icons.location_on,
                          color: Colors.deepPurple,
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            selectedAddress.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),

                          child: Text(
                            selectedAddress.type.toUpperCase(),

                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      selectedAddress.address,

                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [

                        const Icon(
                          Icons.phone,
                          size: 18,
                          color: Colors.grey,
                        ),

                        const SizedBox(width: 6),

                        Text(
                          selectedAddress.phone,

                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 42,

                      child: OutlinedButton.icon(
                        onPressed: () {

                          Get.bottomSheet(
                            Container(
                              padding: const EdgeInsets.all(16),

                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),

                              child: Column(
                                mainAxisSize: MainAxisSize.min,

                                children: [

                                  const Text(
                                    "Select Address",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  ListView.builder(
                                    shrinkWrap: true,

                                    itemCount: addresses.length,

                                    itemBuilder: (context, index) {

                                      final addr = addresses[index];

                                      return Card(
                                        elevation: 1,

                                        child: ListTile(

                                          leading: Icon(
                                            addr.isDefault
                                                ? Icons.radio_button_checked
                                                : Icons.radio_button_off,
                                            color: Colors.deepPurple,
                                          ),

                                          title: Text(addr.name),

                                          subtitle: Text(
                                            "${addr.address}\n${addr.phone}",
                                          ),

                                          isThreeLine: true,

                                          trailing: Text(
                                            addr.type.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          onTap: () {

                                            addressController
                                                .setDefaultAddress(index);

                                            final updatedAddress =
                                                "${addr.name}\n"
                                                "${addr.address}\n"
                                                "${addr.phone}";

                                            orderController
                                                .selectedAddress
                                                .value = updatedAddress;

                                            Get.back();
                                          },
                                        ),
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 10),

                                  SizedBox(
                                    width: double.infinity,
                                    height: 45,

                                    child: ElevatedButton.icon(
                                      onPressed: () {

                                        Get.back();

                                        Get.to(
                                              () => const AddAddressScreen(),
                                        );
                                      },

                                      icon: const Icon(Icons.add),

                                      label: const Text("Add New Address"),

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },

                        icon: const Icon(Icons.edit_location_alt),

                        label: const Text(
                          "Change Address",
                        ),

                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          side: const BorderSide(
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 25),

            /// ORDER ITEMS
            const Text(
              "Order Items",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              itemCount: cartController.cartItems.length,

              itemBuilder: (context, index) {

                final item = cartController.cartItems[index];

                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 10),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(10),

                    child: Row(
                      children: [

                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),

                          child: Image.network(
                            item.product.image,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,

                            errorBuilder:
                                (context, error, stackTrace) {
                              return Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image),
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              Text(
                                item.product.name,

                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "Quantity: ${item.quantity}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                "₹${item.subtotal.toStringAsFixed(2)}",

                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            /// TOTAL
            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),

              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: [

                  const Text(
                    "Total Amount",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "₹${cartController.totalPrice.toStringAsFixed(2)}",

                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// PAYMENT BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(
                onPressed: () {

                  if (orderController
                      .selectedAddress.value
                      .isEmpty) {

                    Get.snackbar(
                      "Address Required",
                      "Please add/select delivery address",

                      snackPosition: SnackPosition.BOTTOM,
                    );

                    return;
                  }

                  Get.to(
                        () => PaymentMethodsPage(
                      selectedAddress:
                      orderController.selectedAddress.value,
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                child: const Text(
                  "Proceed to Payment",

                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}