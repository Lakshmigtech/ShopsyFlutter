import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Shopsy/models/addressmodel.dart';

class AddressController extends GetxController {
  // Reactive list of addresses using GetX .obs
  final addresses = <Address>[].obs;
  static const String _storageKey = 'saved_addresses';

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  // --- Persistence Methods ---

  /// Load addresses from SharedPreferences and populate the reactive list
  Future<void> loadAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? addressesJson = prefs.getString(_storageKey);
      
      if (addressesJson != null) {
        final List<dynamic> decoded = jsonDecode(addressesJson);
        addresses.assignAll(decoded.map((item) => Address.fromJson(item)).toList());
      } else {
        // Initial setup with dummy data if storage is empty for first-time user experience
        _loadDefaultSeedData();
      }
    } catch (e) {
      Get.log("Error loading addresses: $e");
    }
  }

  /// Initial data for first-time users to showcase the UI
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

  /// Persist current address list to SharedPreferences
  Future<void> saveAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(addresses.map((item) => item.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      Get.log("Error saving addresses: $e");
    }
  }

  // --- CRUD Actions ---

  /// Add a new address and optionally set it as default
  Future<void> addAddress(Address address) async {
    if (address.isDefault) {
      _makeAllNonDefault();
    }
    addresses.add(address);
    await saveAddresses();
  }

  /// Update an existing address at the given index
  Future<void> updateAddress(int index, Address updatedAddress) async {
    if (index >= 0 && index < addresses.length) {
      if (updatedAddress.isDefault) {
        _makeAllNonDefault();
      }
      addresses[index] = updatedAddress;
      await saveAddresses();
    }
  }

  /// Remove an address by index and handle default logic
  Future<void> removeAddress(int index) async {
    if (index >= 0 && index < addresses.length) {
      bool wasDefault = addresses[index].isDefault;
      addresses.removeAt(index);
      
      // If we removed the default address and others exist, nominate a new default
      if (wasDefault && addresses.isNotEmpty) {
        await setDefaultAddress(0);
      } else {
        await saveAddresses();
      }
    }
  }

  /// Toggle an address as the default shipping address
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

  // --- Helpers ---

  /// Internal helper to clear isDefault status from all addresses
  /// to ensure only one address is marked as default at a time
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
}
