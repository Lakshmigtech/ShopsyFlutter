import 'package:Shopsy/controller/address_controller.dart';
import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/models/addressmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final AddressController controller = Get.find<AddressController>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  
  final RxString type = "Home".obs;
  final RxBool isDefault = false.obs;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Add New Address", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Contact Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Full Name*",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: "Phone Number*",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 25),
            const Text(
              "Address Details",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: "Address Detail*",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 25),
            const Text(
              "Address Type",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Obx(() => Row(
                  children: [
                    ChoiceChip(
                      label: const Text("Home"),
                      selected: type.value == "Home",
                      onSelected: (val) => type.value = "Home",
                      selectedColor:AppColors.blue100,
                    ),
                    const SizedBox(width: 15),
                    ChoiceChip(
                      label: const Text("Office"),
                      selected: type.value == "Office",
                      onSelected: (val) => type.value = "Office",
                      selectedColor: AppColors.blue100,
                    ),
                  ],
                )),
            const SizedBox(height: 20),
            Obx(() => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Set as default address"),
                  value: isDefault.value,
                  onChanged: (val) => isDefault.value = val ?? false,
                  controlAffinity: ListTileControlAffinity.leading,
                )),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      phoneController.text.isNotEmpty &&
                      addressController.text.isNotEmpty) {
                    final newAddress = Address(
                      name: nameController.text,
                      phone: phoneController.text,
                      address: addressController.text,
                      type: type.value,
                      isDefault: isDefault.value,
                    );
                    controller.addAddress(newAddress);
                    Get.back();
                    Get.snackbar("Success", "Address added successfully",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white);
                  } else {
                    Get.snackbar("Error", "Please fill all mandatory fields",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white);
                  }
                },
                child: const Text(
                  "SAVE ADDRESS",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
