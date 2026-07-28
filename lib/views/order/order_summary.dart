import 'package:Shopsy/controller/cart_controller.dart';
import 'package:Shopsy/controller/order_controller.dart';
import 'package:Shopsy/controller/address_controller.dart';
import 'package:Shopsy/models/address_model.dart';
import 'package:Shopsy/models/product_model.dart';
import 'package:Shopsy/utils/currency_utils.dart';
import 'package:Shopsy/views/account/add_address.dart';
import 'package:Shopsy/views/account/payment.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Shopsy/constants/app_colors.dart';

class OrderSummaryPage extends StatelessWidget {
  const OrderSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final orderController = Get.find<OrderController>();
    final addressController = Get.find<AddressController>();

    return Scaffold(
      backgroundColor: const Color(0xfff1f2f6),
      appBar: AppBar(
        title: const Text(
          "Order Summary",
          style: TextStyle(color: AppColors.textBlack, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0.5,
        backgroundColor: AppColors.textWhite,
        foregroundColor: AppColors.textBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 1. DELIVERY ADDRESS SECTION
                  Obx(() => _buildAddressSection(addressController, orderController)),

                  const SizedBox(height: 8),

                  /// 2. ORDER ITEMS LIST
                  Obx(() => ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cartController.cartItems.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 1),
                        itemBuilder: (context, index) {
                          final item = cartController.cartItems[index];
                          return _buildOrderItem(item);
                        },
                      )),

                  const SizedBox(height: 8),

                  /// 3. PRICE DETAILS SECTION
                  Obx(() => _buildPriceDetails(cartController)),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          /// 4. BOTTOM ACTION BAR
          _buildBottomBar(cartController, orderController),
        ],
      ),
    );
  }

  Widget _buildAddressSection(AddressController addressController, OrderController orderController) {
    final addresses = addressController.addresses;
    
    if (addresses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: AppColors.textWhite,
        child: Column(
          children: [
            const Text("No delivery address selected", style: TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Get.to(() => const AddAddressScreen()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2874f0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text("ADD ADDRESS", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final Address? selectedAddress = orderController.selectedAddressObject.value;
    if (selectedAddress == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.textWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Deliver to: ${selectedAddress.name}, ${selectedAddress.phone}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 36,
                child: OutlinedButton(
                  onPressed: () => _showAddressPicker(addresses, orderController),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xff2874f0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text("Change", style: TextStyle(color: Color(0xff2874f0), fontSize: 13)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            selectedAddress.address,
            style: const TextStyle(color: AppColors.textBlack, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.textWhite,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.textWhite,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Image.network(
              item.product.image,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 40, color: AppColors.textGrey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                if (item.size != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    "Size: ${item.size}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (item.color != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    "Shade: ${item.color}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  "₹${CurrencyUtils.formatPrice(item.subtotal)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Free Delivery",
                  style: TextStyle(color: Color(0xff388e3c), fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  "Qty: ${item.quantity}",
                  style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetails(CartController cartController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.textWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Price Details",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textGrey),
          ),
          const Divider(height: 24),
          _priceRow("Price (${cartController.itemCount} items)", "₹${CurrencyUtils.formatPrice(cartController.totalPrice)}"),
          const SizedBox(height: 12),
          _priceRow("Delivery Charges", "FREE", isGreen: true),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "₹${CurrencyUtils.formatPrice(cartController.totalPrice)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: isGreen ? const Color(0xff388e3c) : AppColors.textBlack,
            fontWeight: isGreen ? FontWeight.bold : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(CartController cartController, OrderController orderController) {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.textWhite,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textBlack.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "₹${CurrencyUtils.formatPrice(cartController.totalPrice)}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "View price details",
                        style: TextStyle(color: Color(0xff2874f0), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 48,
                  width: 160,
                  child: ElevatedButton(
                    onPressed: () {
                      if (orderController.selectedAddress.value.isEmpty) {
                        Get.snackbar("Address Required", "Please select a delivery address", backgroundColor: Colors.red, colorText: Colors.white);
                        return;
                      }
                      Get.to(() => PaymentMethodsPage(selectedAddress: orderController.selectedAddress.value));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffff8c31),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "CONTINUE",
                      style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showAddressPicker(List<Address> addresses, OrderController orderController) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.textWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Delivery Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final addr = addresses[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Obx(() => Radio<Address?>(
                      value: addr, 
                      groupValue: orderController.selectedAddressObject.value,
                      onChanged: (val) {
                        if (val != null) {
                          orderController.setOrderAddress(val);
                          Get.back();
                        }
                      },
                      activeColor: const Color(0xff2874f0),
                    )),
                    title: Text(addr.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(addr.address),
                    onTap: () {
                      orderController.setOrderAddress(addr);
                      Get.back();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Get.back();
                  Get.to(() => const AddAddressScreen());
                },
                icon: const Icon(Icons.add, color: Color(0xff2874f0)),
                label: const Text("Add New Address", style: TextStyle(color: Color(0xff2874f0))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
