import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Shopsy/models/address_model.dart';

class AddressController extends GetxController {
  final addresses = <Address>[].obs;
  static const String _storageKey = 'saved_addresses';

  // Form Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final detailAddressController = TextEditingController();
  final addressType = "Home".obs;
  final isDefault = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  void clearFields() {
    nameController.clear();
    phoneController.clear();
    detailAddressController.clear();
    addressType.value = "Home";
    isDefault.value = false;
  }

  void initForEditing(Address address) {
    nameController.text = address.name;
    phoneController.text = address.phone;
    detailAddressController.text = address.address;
    addressType.value = address.type;
    isDefault.value = address.isDefault;
  }

  Future<void> loadAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? addressesJson = prefs.getString(_storageKey);
      
      if (addressesJson != null) {
        final List<dynamic> decoded = jsonDecode(addressesJson);
        addresses.assignAll(decoded.map((item) => Address.fromJson(item)).toList());
      } else {
        _loadDefaultSeedData();
      }
    } catch (e) {
      Get.log("Error loading addresses: $e");
    }
  }

  void _loadDefaultSeedData() {
    addresses.assignAll([
      Address(
        name: "Lakshmi G",
        phone: "9876543210",
        address: "House No. 12, ABC Nagar, Kochi, Kerala - 682001",
        type: "Home",
        isDefault: true,
      ),
    ]);
    saveAddresses();
  }

  Future<void> saveAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(addresses.map((item) => item.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      Get.log("Error saving addresses: $e");
    }
  }

  Future<void> addAddress(Address address) async {
    if (address.isDefault) {
      _makeAllNonDefault();
    }
    addresses.add(address);
    await saveAddresses();
  }

  Future<void> updateAddress(int index, Address updatedAddress) async {
    if (index >= 0 && index < addresses.length) {
      if (updatedAddress.isDefault) {
        _makeAllNonDefault();
      }
      addresses[index] = updatedAddress;
      await saveAddresses();
    }
  }

  Future<void> removeAddress(int index) async {
    if (index >= 0 && index < addresses.length) {
      bool wasDefault = addresses[index].isDefault;
      addresses.removeAt(index);
      
      if (wasDefault && addresses.isNotEmpty) {
        await setDefaultAddress(0);
      } else {
        await saveAddresses();
      }
    }
  }

  Future<void> setDefaultAddress(int index) async {
    if (index >= 0 && index < addresses.length) {
      _makeAllNonDefault();
      
      final target = addresses[index];
      addresses[index] = Address(
        name: target.name,
        phone: target.phone,
        address: target.address,
        type: target.type,
        isDefault: true,
      );
      await saveAddresses();
    }
  }

  void _makeAllNonDefault() {
    for (int i = 0; i < addresses.length; i++) {
      if (addresses[i].isDefault) {
        addresses[i] = Address(
          name: addresses[i].name,
          phone: addresses[i].phone,
          address: addresses[i].address,
          type: addresses[i].type,
          isDefault: false,
        );
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    detailAddressController.dispose();
    super.onClose();
  }
}
