import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Shopsy/models/addressmodel.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulated list of addresses using the Address model
    final List<Address> addresses = [
      Address(
        name: "Lakshmi G",
        phone: "9876543210",
        address: "House No. 12, ABC Nagar, Kochi, Kerala - 682001",
        type: "Home",
        isDefault: true,
      ),
      Address(
        name: "Sarath Kumar",
        phone: "9123456780",
        address: "Tech Park, 3rd Floor, Kakkanad, Kochi",
        type: "Office",
        isDefault: false,
      ),
    ];

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
                onPressed: () {
                  // Logic to add new address
                },
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: addresses.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return AddressCard(addressData: addresses[index]);
        },
      ),
    );
  }
}

class AddressCard extends StatelessWidget {
  final Address addressData;

  const AddressCard({
    super.key,
    required this.addressData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + Default Tag
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
                    style: TextStyle(color: Colors.green),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          // Phone
          Text(
            addressData.phone,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),

          const SizedBox(height: 6),

          // Address
          Text(addressData.address, style: const TextStyle(fontSize: 16)),

          const SizedBox(height: 10),

          // Bottom Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tag (Home / Office)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(addressData.type),
              ),

              // Actions
              Row(
                children: const [
                  Text("Edit"),
                  SizedBox(width: 10),
                  Text("Delete", style: TextStyle(color: Colors.red)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
