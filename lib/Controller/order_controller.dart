import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ordermodel.dart';
import 'address_controller.dart';

class OrderController extends GetxController {
  var orders = <OrderModel>[].obs;
  static const String _storageKey = 'my_orders';

  // Observable for selected address
  final selectedAddress = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();

    // Initialize default address
    _updateDefaultAddress();

    // Worker to update selected address when addresses change
    final addressController = Get.find<AddressController>();
    ever(addressController.addresses, (_) => _updateDefaultAddress());
  }

  void _updateDefaultAddress() {
    final addressController = Get.find<AddressController>();
    if (selectedAddress.value.isEmpty && addressController.addresses.isNotEmpty) {
      final defaultAddr = addressController.addresses.firstWhere(
        (element) => element.isDefault,
        orElse: () => addressController.addresses.first,
      );
      selectedAddress.value = "${defaultAddr.name}, ${defaultAddr.address}";
    }
  }

  Future<void> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? ordersJson = prefs.getString(_storageKey);
    if (ordersJson != null) {
      final List<dynamic> decoded = jsonDecode(ordersJson);
      orders.value = decoded.map((item) => OrderModel.fromJson(item)).toList();
    }
  }

  Future<void> placeOrder(OrderModel newOrder) async {
    orders.insert(0, newOrder); // Add new order to the top of the list
    await saveOrders();
  }

  Future<void> saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(orders.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
