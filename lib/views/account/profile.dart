import 'package:Shopsy/controller/auth_controller.dart';
import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/views/account/address.dart';
import 'package:Shopsy/views/account/edit_profile.dart';
import 'package:Shopsy/views/account/notification.dart';
import 'package:Shopsy/views/account/payment.dart';
import 'package:Shopsy/views/account/wishlist.dart';
import 'package:Shopsy/views/order/my_orders.dart';
import 'package:Shopsy/views/account/privacy_policy.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends GetView<AuthController> {
  const ProfilePage({super.key});

  Widget menuItem(IconData icon, String title, [VoidCallback? onTap]) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.blue50,
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap ?? () {},
      ),
    );
  }

  void _showLogoutConfirmation() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.textWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Logout",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Are you sure you want to logout from this app?",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "CANCEL",
                      style: TextStyle(color: AppColors.textBlack, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      controller.logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffff8c00), // Flipkart Orange
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "LOGOUT",
                      style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.borderGrey,
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        final firstName = controller.firstName.value;
        final lastName = controller.lastName.value;
        final email = controller.email.value;
        final username = controller.username.value;
        
        final displayName = "${firstName} ${lastName}".trim();

        return ListView(
          children: [
            const SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: AppColors.blue100,
                      backgroundImage: controller.profileImage.value != null
                          ? FileImage(controller.profileImage.value!)
                          : null,
                      child: controller.profileImage.value == null
                          ? const Icon(Icons.person, size: 45, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      displayName.isEmpty ? username : displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email.isEmpty ? "@$username" : email,
                      style: TextStyle(color: AppColors.textBlack),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () => Get.to(() => const EditProfileScreen()),
                      child: const Text("Edit Profile"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "My Account",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGrey,
                ),
              ),
            ),
            const SizedBox(height: 10),
            menuItem(
              Icons.shopping_bag,
              "My Orders",
                  () => Get.to(() => MyOrdersScreen()),
            ),
            menuItem(
              Icons.favorite,
              "Wishlist",
                  () => Get.to(() => const WishlistScreen()),
            ),
            menuItem(
              Icons.location_on,
              "Saved Addresses",
              () => Get.to(() => const AddressScreen()),
            ),
            menuItem(
              Icons.credit_card,
              "Payment Methods",
              () => Get.to(() => const PaymentMethodsPage()),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Settings",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGrey,
                ),
              ),
            ),
            const SizedBox(height: 10),
            menuItem(
              Icons.notifications,
              "Notifications",
              () => Get.to(() => const NotificationScreen()),
            ),
            menuItem(
              Icons.privacy_tip,
              "Privacy Policy",
                  () => Get.to(() => const PrivacyPolicyScreen()),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _showLogoutConfirmation,
                child: const Text("Logout"),
              ),
            ),
            const SizedBox(height: 30),
          ],
        );
      }),
    );
  }
}
