import 'package:Shopsy/Controller/auth_controller.dart';
import 'package:Shopsy/views/Account/address.dart';
import 'package:Shopsy/views/Account/notification.dart';
import 'package:Shopsy/views/Account/payment.dart';
import 'package:Shopsy/views/Account/wishlist.dart';
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
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap ?? () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        final displayName = controller.username.value;

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
                    const CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, size: 45, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      displayName,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () {},
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
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 10),
            menuItem(Icons.shopping_bag, "My Orders"),
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
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 10),
            menuItem(
              Icons.notifications,
              "Notifications",
              () => Get.to(() => NotificationScreen()),
            ),
            menuItem(Icons.privacy_tip, "Privacy Policy"),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: controller.logout,
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
