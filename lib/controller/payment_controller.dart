import 'package:Shopsy/controller/cart_controller.dart';
import 'package:Shopsy/controller/navigation_controller.dart';
import 'package:Shopsy/controller/notification_controller.dart';
import 'package:Shopsy/controller/order_controller.dart';
import 'package:Shopsy/models/order_model.dart';
import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/views/bottom_navigation/bottom_navigation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentController extends GetxController {
  late Razorpay _razorpay;
  
  String get razorpayKey => (dotenv.env['RAZORPAY_KEY'] ?? "").trim();

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout(double amount, String contact, String email) {
    if (razorpayKey.isEmpty || !razorpayKey.startsWith("rzp_")) {
      Get.snackbar("Error", "Invalid Razorpay Key configuration.");
      return;
    }

    var options = {
      'key': razorpayKey,
      'amount': (amount * 100).toInt(),
      'name': 'Shopsy Flutter',
      'description': 'Purchase Payment',
      'currency': 'INR',
      'prefill': {'contact': contact, 'email': email},
      'send_sms_hash': true,
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      Get.snackbar("Error", "Could not open checkout: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Get.snackbar("Success", "Payment Successful",
        backgroundColor: AppColors.backgroundSuccess, colorText: AppColors.textWhite);
    
    Get.find<NotificationController>().addNotification(
      "Payment Successful", 
      "Your order is confirmed!"
    );
    
    _finalizeOrder(response.paymentId ?? DateTime.now().millisecondsSinceEpoch.toString());
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar("Payment Failed", response.message ?? "Transaction failed",
        backgroundColor: AppColors.backgroundAlert, colorText: AppColors.textWhite);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar("Wallet", "Selected: ${response.walletName}");
  }

  /// Consolidated Order Finalization
  void _finalizeOrder(String paymentId) async {
    final cartController = Get.find<CartController>();
    final orderController = Get.find<OrderController>();
    final navigationController = Get.find<NavigationController>();

    if (cartController.cartItems.isNotEmpty) {
      final newOrder = OrderModel(
        orderId: paymentId,
        items: cartController.cartItems.map((item) => OrderItem.fromCartItem(item)).toList(),
        totalAmount: cartController.totalPrice,
        address: orderController.selectedAddress.value,
        dateTime: DateTime.now(),
        status: "Paid",
      );

      await orderController.placeOrder(newOrder);
      cartController.clearCart();
    }

    navigationController.changeIndex(0);
    Get.offAll(() => const MainNavigation());
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}
