import 'package:Shopsy/Controller/cart_controller.dart';
import 'package:Shopsy/Controller/navigation_controller.dart';
import 'package:Shopsy/Controller/notification_controller.dart';
import 'package:Shopsy/views/Bottom_Navigation/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentController extends GetxController {
  late Razorpay _razorpay;
  
  // IMPORTANT: Replace 'rzp_test_YOUR_KEY_HERE' with your actual Test Key from Razorpay Dashboard
  static const String razorpayKey = "rzp_test_SipsQzbPDlXMlt";

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout(double amount, String contact, String email) {
    var options = {
      'key': razorpayKey,
      'amount': (amount * 100).toInt(), // amount in paise
      'name': 'Shopsy Flutter',
      'description': 'Test Payment',
      'timeout': 300,
      'prefill': {
        'contact': contact,
        'email': email
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
      Get.snackbar("Error", "Could not open Razorpay checkout");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Get.snackbar("Success", "Payment Successful: ${response.paymentId}",
        backgroundColor: Colors.green, colorText: Colors.white);
    
    // Add local notification
    Get.find<NotificationController>().addNotification(
      "Payment Successful", 
      "Your payment of ID ${response.paymentId} was successful. Order is confirmed!"
    );
    
    _finalizeOrder();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    String message = response.message ?? "Payment Cancelled or Failed";
    Get.snackbar("Payment Info", message,
        backgroundColor: Colors.blueGrey, colorText: Colors.white);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar("External Wallet", "Selected: ${response.walletName}",
        backgroundColor: Colors.blue, colorText: Colors.white);
  }

  void _finalizeOrder() {
    final cartController = Get.find<CartController>();
    final navigationController = Get.find<NavigationController>();

    cartController.cartItems.clear();
    navigationController.changeIndex(0);
    Get.offAll(() => const MainNavigation());
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}
