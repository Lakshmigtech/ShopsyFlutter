import 'package:Shopsy/controller/auth_controller.dart';
import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/utils/screen_utils.dart';
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
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.blue50,
          radius: 6.w,
          child: Icon(icon, color: AppColors.primary, size: 6.w),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.chevron_right, size: 6.w),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.w),
        onTap: onTap ?? () {},
      ),
    );
  }

  void _showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        content: Text(
          "Are you sure you want to logout from Shopsy?",
          style: TextStyle(fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "CANCEL",
              style: TextStyle(
                color: const Color(0xff2874f0),
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: Text(
              "LOGOUT",
              style: TextStyle(
                color: const Color(0xff2874f0),
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.borderGrey,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.sp),
        ),
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
            SizedBox(height: 4.w),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(5.w),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 12.w,
                      backgroundColor: AppColors.blue100,
                      backgroundImage: controller.profileImage.value != null
                          ? FileImage(controller.profileImage.value!)
                          : null,
                      child: controller.profileImage.value == null
                          ? Icon(Icons.person, size: 12.w, color: AppColors.primary)
                          : null,
                    ),
                    SizedBox(height: 3.w),
                    Text(
                      displayName.isEmpty ? username : displayName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.w),
                    Text(
                      email.isEmpty ? "@$username" : email,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textGrey, fontSize: 16.sp),
                    ),
                    SizedBox(height: 4.w),
                    OutlinedButton(
                      onPressed: () => Get.to(() => const EditProfileScreen()),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(
                        "Edit Profile",
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 6.w),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Text(
                "My Account",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGrey,
                ),
              ),
            ),
            SizedBox(height: 2.w),
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
            SizedBox(height: 6.w),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: Text(
                "Settings",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGrey,
                ),
              ),
            ),
            SizedBox(height: 2.w),
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

            SizedBox(height: 6.w),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 4.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _showLogoutConfirmation,
                child: Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.w),
          ],
        );
      }),
    );
  }
}
