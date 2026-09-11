import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/controller/address_controller.dart';
import 'package:Shopsy/models/address_model.dart';
import 'package:Shopsy/utils/screen_utils.dart';
import 'package:Shopsy/views/account/add_address.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddressController>();

    return Scaffold(
      backgroundColor: const Color(0xfff1f2f6),
      appBar: AppBar(
        title: Text(
          "My Addresses",
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.textWhite,
        foregroundColor: AppColors.textBlack,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 4.w),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.addresses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off_outlined,
                  size: 12.w,
                  color: AppColors.borderGrey,
                ),
                SizedBox(height: 4.w),
                Text(
                  "No addresses saved yet",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.borderGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 4.w),
          itemCount: controller.addresses.length,
          itemBuilder: (context, index) {
            final addr = controller.addresses[index];
            return _buildAddressItem(context, addr, controller, index);
          },
        );
      }),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildAddressItem(
    BuildContext context,
    Address addr,
    AddressController controller,
    int index,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 4.w,
        vertical: 3.w,
      ),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(5.w),
        border: addr.isDefault
            ? Border.all(
                color: const Color(0xff2874f0),
                width: 2.0,
              )
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => controller.setDefaultAddress(index),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  addr.isDefault ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: addr.isDefault ? const Color(0xff2874f0) : AppColors.borderGrey,
                  size: 4.w,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    addr.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 2.w,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xfff5f5f5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    addr.type.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                // Edit Icon
                GestureDetector(
                  onTap: () {
                    Get.to(() => AddAddressScreen(
                          editAddress: addr,
                          editIndex: index,
                        ));
                  },
                  child: Icon(
                    Icons.edit_outlined,
                    color: const Color(0xff2874f0),
                    size: 8.w,
                  ),
                ),
                SizedBox(width: 5.w),
                // Delete Icon
                GestureDetector(
                  onTap: () {
                    _showDeleteDialog(context, addr, index, controller);
                  },
                  child: Icon(
                    Icons.delete_outline,
                    color: AppColors.redAccent,
                    size: 4.w,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.w),
            Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addr.address,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textBlack,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 3.w),
                  Text(
                    "Phone: ${addr.phone}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, Address addr, int index, AddressController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.w)),
        child: Padding(
          padding: EdgeInsets.all(7.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Are you sure you want to delete this address?",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              SizedBox(height: 5.w),
              Text(
                addr.address,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textGrey,
                ),
              ),
              SizedBox(height: 4.w),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 4.w),
                        side: const BorderSide(color: Color(0xff2874f0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                      ),
                      child: Text(
                        "No",
                        style: TextStyle(
                          color: const Color(0xff2874f0),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.removeAddress(index);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 4.w),
                        backgroundColor: const Color(0xff2874f0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                      ),
                      child: Text(
                        "Yes, delete",
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: 6.w,
        vertical: 4.w,
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 12.w,
          child: ElevatedButton(
            onPressed: () {
              Get.to(() => const AddAddressScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffff8c31),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.w),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_location_alt_outlined, color: AppColors.textWhite, size: 8.w),
                SizedBox(width: 3.w),
                Text(
                  "Add Address",
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
