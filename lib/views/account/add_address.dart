import 'package:Shopsy/controller/address_controller.dart';
import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/models/addressmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddAddressScreen extends StatefulWidget {
  final Address? editAddress;
  final int? editIndex;

  const AddAddressScreen({super.key, this.editAddress, this.editIndex});

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
  void initState() {
    super.initState();
    if (widget.editAddress != null) {
      nameController.text = widget.editAddress!.name;
      phoneController.text = widget.editAddress!.phone;
      addressController.text = widget.editAddress!.address;
      type.value = widget.editAddress!.type;
      isDefault.value = widget.editAddress!.isDefault;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.editAddress != null;

    return Scaffold(
      backgroundColor: const Color(0xfff1f2f6),
      appBar: AppBar(
        title: Text(
          isEditing ? "Edit Address" : "Add New Address",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Contact Details"),
                  _buildFormCard([
                    _buildTextField(
                      controller: nameController,
                      label: "Full Name",
                      hint: "Enter your name",
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: phoneController,
                      label: "Phone Number",
                      hint: "10-digit mobile number",
                      keyboardType: TextInputType.phone,
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Address Details"),
                  _buildFormCard([
                    _buildTextField(
                      controller: addressController,
                      label: "Address Detail",
                      hint: "House No, Building, Street, Area",
                      maxLines: 3,
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Address Type"),
                  _buildFormCard([
                    Obx(() => Row(
                      children: [
                        _typeChip("Home"),
                        const SizedBox(width: 12),
                        _typeChip("Office"),
                      ],
                    )),
                  ]),
                  const SizedBox(height: 24),
                  _buildFormCard([
                    Obx(() => CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Set as default address", style: TextStyle(fontSize: 14)),
                      value: isDefault.value,
                      onChanged: (val) => isDefault.value = val ?? false,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: const Color(0xff2874f0),
                    )),
                  ]),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildBottomBar(isEditing),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xff2874f0))),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _typeChip(String label) {
    bool isSelected = type.value == label;
    return GestureDetector(
      onTap: () => type.value = label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff2874f0).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xff2874f0) : Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xff2874f0) : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isEditing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _saveAddress,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffff8c31),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            elevation: 0,
          ),
          child: Text(
            isEditing ? "UPDATE ADDRESS" : "SAVE ADDRESS",
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _saveAddress() async {
    if (nameController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        addressController.text.isNotEmpty) {
      
      final newAddress = Address(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        type: type.value,
        isDefault: isDefault.value,
      );

      if (widget.editAddress != null && widget.editIndex != null) {
        // Update logic: Remove old and add at same index or add new and remove old
        // For simplicity, let's add update to controller
        controller.addresses[widget.editIndex!] = newAddress;
        if (newAddress.isDefault) {
          // If we set this one to default, we need to handle others
          await controller.setDefaultAddress(widget.editIndex!);
        } else {
          await controller.saveAddresses();
        }
      } else {
        await controller.addAddress(newAddress);
      }

      Get.back();
      Get.snackbar("Success", widget.editAddress != null ? "Address updated" : "Address added",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } else {
      Get.snackbar("Error", "Please fill all mandatory fields",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }
}
