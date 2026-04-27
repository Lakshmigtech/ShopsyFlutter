import 'package:Shopsy/Controller/address_controller.dart';
import 'package:Shopsy/views/Account/add_address.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Shopsy/models/addressmodel.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddressController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Addresses", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.black),
                onPressed: () => Get.to(() => const AddAddressScreen()),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() => ListView.separated(
            itemCount: controller.addresses.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return AddressCard(
                addressData: controller.addresses[index],
                onDelete: () => controller.removeAddress(index),
              );
            },
          )),
    );
  }
}

class AddressCard extends StatelessWidget {
  final Address addressData;
  final VoidCallback onDelete;

  const AddressCard({
    super.key,
    required this.addressData,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                addressData.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (addressData.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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
          const SizedBox(height: 6),
          Text(
            addressData.phone,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(addressData.address, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(addressData.type, style: const TextStyle(fontSize: 12)),
              ),
              Row(
                children: [
                  const Text("Edit", style: TextStyle(color: Colors.blue)),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Text("Delete", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
