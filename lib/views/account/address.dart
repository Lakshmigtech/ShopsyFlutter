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
      appBar: AppBar(
        title: const Text("My Addresses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.to(() => const AddAddressScreen()),
          )
        ],
      ),
      body: Obx(() {
        if (controller.addresses.isEmpty) {
          return const Center(child: Text("No addresses saved"));
        }
        return ListView.builder(
          itemCount: controller.addresses.length,
          itemBuilder: (context, index) {
            final addr = controller.addresses[index];
            return ListTile(
              title: Text(addr.name),
              subtitle: Text(addr.address),
              trailing: addr.isDefault ? const Icon(Icons.check_circle, color: Colors.green) : null,
              onTap: () => controller.setDefaultAddress(index),
            );
          },
        );
      }),
    );
  }
}
