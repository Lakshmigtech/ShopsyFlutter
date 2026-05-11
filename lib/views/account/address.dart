import 'package:Shopsy/controller/address_controller.dart';
import 'package:Shopsy/views/account/add_address.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddressController>();

    return Scaffold(
      backgroundColor: const Color(0xfff1f2f6),

      appBar: AppBar(
        title: const Text(
          "My Addresses",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: Obx(() {
        if (controller.addresses.isEmpty) {
          return Column(
            children: [
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        size: 70,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "No addresses saved",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Add Address Button
              _buildBottomBar(),
            ],
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: controller.addresses.length,
                itemBuilder: (context, index) {
                  final addr = controller.addresses[index];

                  return _buildAddressItem(
                    addr,
                    controller,
                    index,
                  );
                },
              ),
            ),

            // Add Address Button
            _buildBottomBar(),
          ],
        );
      }),
    );
  }

  Widget _buildAddressItem(
      dynamic addr,
      AddressController controller,
      int index,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),

        border: addr.isDefault
            ? Border.all(
          color: const Color(0xff2874f0),
          width: 1.2,
        )
            : null,
      ),

      child: InkWell(
        onTap: () => controller.setDefaultAddress(index),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Icon(
                  addr.isDefault
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: addr.isDefault
                      ? const Color(0xff2874f0)
                      : Colors.grey,
                  size: 22,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    addr.name,
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
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),

                  child: Text(
                    addr.type.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                IconButton(
                  onPressed: () {
                    Get.defaultDialog(
                      title: "Delete Address",
                      middleText:
                      "Are you sure you want to delete this address?",

                      textConfirm: "Delete",
                      textCancel: "Cancel",

                      confirmTextColor: Colors.white,

                      onConfirm: () {
                        controller.removeAddress(index);
                        Get.back();
                      },
                    );
                  },

                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.only(left: 34),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    addr.address,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    addr.phone,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),

      child: SizedBox(
        width: double.infinity,
        height: 52,

        child: ElevatedButton.icon(
          onPressed: () {
            Get.to(() => const AddAddressScreen());
          },

          icon: const Icon(
            Icons.add_location_alt,
            color: Colors.white,
          ),

          label: const Text(
            "Add Address",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffff8c31),

            elevation: 0,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}