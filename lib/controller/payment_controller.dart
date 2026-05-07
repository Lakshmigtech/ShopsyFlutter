import 'package:Shopsy/controller/cart_controller.dart';
import 'package:Shopsy/controller/navigation_controller.dart';
import 'package:Shopsy/controller/notification_controller.dart';
import 'package:Shopsy/controller/order_controller.dart';
import 'package:Shopsy/models/ordermodel.dart';
import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/views/Bottom_Navigation/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentController extends GetxController {
  late Razorpay _razorpay;
  
  // Use environment variable for security
  final String razorpayKey = dotenv.env['RAZORPAY_KEY'] ?? "";

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout(double amount, String contact, String email) {
    if (razorpayKey.isEmpty) {
      Get.snackbar("Error", "Razorpay key not found in environment");
      return;
    }

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
        backgroundColor: AppColors.green, colorText: AppColors.white);
    
    // Add local notification
    Get.find<NotificationController>().addNotification(
      "Payment Successful", 
      "Your payment of ID ${response.paymentId} was successful. Order is confirmed!"
    );
    
    _finalizeOrder(response.paymentId ?? DateTime.now().millisecondsSinceEpoch.toString());
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    String message = response.message ?? "Payment Cancelled or Failed";
    Get.snackbar("Payment Info", message,
        backgroundColor: Colors.blueGrey, colorText: AppColors.white);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar("External Wallet", "Selected: ${response.walletName}",
        backgroundColor: AppColors.blue, colorText: AppColors.white);
  }

  void _finalizeOrder(String paymentId) async {
    final cartController = Get.find<CartController>();
    final orderController = Get.find<OrderController>();
    final navigationController = Get.find<NavigationController>();

    if (cartController.cartItems.isNotEmpty) {
      // Create order items from cart
      List<OrderItem> orderItems = cartController.cartItems.map((cartItem) {
        return OrderItem(
          productId: cartItem.product.id,
          productName: cartItem.product.name,
          productImage: cartItem.product.image,
          quantity: cartItem.quantity,
          price: cartItem.product.priceCents / 100.0,
        );
      }).toList();

      // Create new order
      OrderModel newOrder = OrderModel(
        orderId: paymentId,
        items: orderItems,
        totalAmount: cartController.totalPrice,
        address: orderController.selectedAddress.value,
        dateTime: DateTime.now(),
      );

      // Place order in history
      await orderController.placeOrder(newOrder);
      
      // Clear cart
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
