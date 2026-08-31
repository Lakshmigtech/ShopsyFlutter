import 'dart:convert';
import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/controller/cart_controller.dart';
import 'package:Shopsy/controller/navigation_controller.dart';
import 'package:Shopsy/views/Bottom_Navigation/bottom_navigation.dart';
import 'package:Shopsy/views/account/payment.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';
import '../models/address_model.dart';
import 'address_controller.dart';

class OrderController extends GetxController {
  var orders = <OrderModel>[].obs;
  static const String _storageKey = 'my_orders';

  final selectedAddress = "".obs;
  final selectedAddressObject = Rxn<Address>();

  @override
  void onInit() {
    super.onInit();
    loadOrders();
    _updateDefaultAddress();
    final addressController = Get.find<AddressController>();
    ever(addressController.addresses, (_) => _updateDefaultAddress());
  }

  void _updateDefaultAddress() {
    final addressController = Get.find<AddressController>();
    if (addressController.addresses.isNotEmpty) {
      final defaultAddr = addressController.addresses.firstWhere(
        (element) => element.isDefault,
        orElse: () => addressController.addresses.first,
      );
      setOrderAddress(defaultAddr);
    } else {
      selectedAddress.value = "";
      selectedAddressObject.value = null;
    }
  }

  void setOrderAddress(Address addr) {
    selectedAddressObject.value = addr;
    selectedAddress.value = addr.fullAddressSummary;
  }

  void proceedToPayment() {
    if (selectedAddress.value.isEmpty) {
      Get.snackbar(
        "Address Required",
        "Please select a delivery address",
        backgroundColor: AppColors.backgroundAlert,
        colorText: AppColors.textWhite,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.to(() => PaymentMethodsPage(selectedAddress: selectedAddress.value));
  }

  /// Refactored COD Order Logic
  void confirmCODOrder(String deliveryAddress) {
    final cartController = Get.find<CartController>();
    final navigationController = Get.find<NavigationController>();

    Get.defaultDialog(
      title: "Confirm Order",
      middleText: "Place order with Cash on Delivery?",
      textConfirm: "Confirm",
      confirmTextColor: AppColors.textWhite,
      onConfirm: () async {
        final newOrder = OrderModel(
          orderId: DateTime.now().millisecondsSinceEpoch.toString(),
          items: cartController.cartItems.map((item) => OrderItem.fromCartItem(item)).toList(),
          totalAmount: cartController.totalPrice,
          address: deliveryAddress,
          dateTime: DateTime.now(),
          status: "Confirmed (COD)",
        );

        await placeOrder(newOrder);
        cartController.clearCart();
        navigationController.changeIndex(0);
        Get.offAll(() => const MainNavigation());

        Get.snackbar(
          "Success", 
          "Order placed successfully with COD!",
          backgroundColor: AppColors.textGreen, 
          colorText: AppColors.textWhite,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
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
    orders.insert(0, newOrder);
    await saveOrders();
  }

  Future<void> saveOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(orders.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
