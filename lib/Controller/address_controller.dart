import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Shopsy/models/addressmodel.dart';

class AddressController extends GetxController {
  var addresses = <Address>[].obs;
  static const String _storageKey = 'saved_addresses';

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final String? addressesJson = prefs.getString(_storageKey);
    if (addressesJson != null) {
      final List<dynamic> decoded = jsonDecode(addressesJson);
      addresses.value = decoded.map((item) => Address.fromJson(item)).toList();
    } else {
      // Add dummy data if storage is empty for first time
      addresses.addAll([
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
  }

  Future<void> addAddress(Address address) async {
    if (address.isDefault) {
      // If new address is default, unmark others as default
      for (int i = 0; i < addresses.length; i++) {
        addresses[i] = Address(
          name: addresses[i].name,
          phone: addresses[i].phone,
          address: addresses[i].address,
          type: addresses[i].type,
          isDefault: false,
        );
      }
    }
    addresses.add(address);
    await saveAddresses();
  }

  Future<void> removeAddress(int index) async {
    addresses.removeAt(index);
    await saveAddresses();
  }

  Future<void> saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(addresses.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
