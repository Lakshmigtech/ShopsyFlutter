import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/controller/address_controller.dart';
import 'package:Shopsy/models/address_model.dart';
import 'package:Shopsy/views/account/add_address.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddressController>();
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;

    return Scaffold(
      backgroundColor: const Color(0xfff1f2f6),
      appBar: AppBar(
        title: Text(
          "My Addresses",
          style: TextStyle(
            color: AppColors.textBlack,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.045,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.textWhite,
        foregroundColor: AppColors.textBlack,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: screenWidth * 0.05),
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
                  size: screenWidth * 0.18,
                  color: AppColors.borderGrey,
                ),
                SizedBox(height: screenWidth * 0.04),
                Text(
                  "No addresses saved yet",
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: AppColors.borderGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
          itemCount: controller.addresses.length,
          itemBuilder: (context, index) {
            final addr = controller.addresses[index];
            return _buildAddressItem(context, addr, controller, screenWidth, index);
          },
        );
      }),
      bottomNavigationBar: _buildBottomBar(context, screenWidth),
    );
  }

  Widget _buildAddressItem(
    BuildContext context,
    Address addr,
    AddressController controller,
    double screenWidth,
    int index,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.02,
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: addr.isDefault
            ? Border.all(
                color: const Color(0xff2874f0),
                width: 1.2,
              )
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: addr.isDefault ? const Color(0xff2874f0) :AppColors.borderGrey,
                  size: screenWidth * 0.055,
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Text(
                    addr.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.025,
                    vertical: screenWidth * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xfff5f5f5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    addr.type.toUpperCase(),
                    style: TextStyle(
                      fontSize: screenWidth * 0.025,
                      fontWeight: FontWeight.bold,
                      color: AppColors.borderGrey,
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
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
                    size: screenWidth * 0.05,
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                // Delete Icon
                GestureDetector(
                  onTap: () {
                    _showDeleteDialog(context, addr, index, controller, screenWidth);
                  },
                  child: Icon(
                    Icons.delete_outline,
                    color:AppColors.redAccent,
                    size: screenWidth * 0.05,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.03),
            Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.085),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addr.address,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: AppColors.textBlack,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.015),
                  Text(
                    addr.phone,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth * 0.035,
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

  void _showDeleteDialog(BuildContext context, Address addr, int index, AddressController controller, double screenWidth) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(screenWidth * 0.05)),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Are you sure you want to delete this address?",
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color:AppColors.textBlack,
                ),
              ),
              SizedBox(height: screenWidth * 0.04),
              Text(
                addr.address,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color:AppColors.borderGrey,
                ),
              ),
              SizedBox(height: screenWidth * 0.06),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
                        side: const BorderSide(color: Color(0xff2874f0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                      ),
                      child: Text(
                        "No",
                        style: TextStyle(
                          color: const Color(0xff2874f0),
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.removeAddress(index);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
                        backgroundColor: const Color(0xff2874f0),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                      ),
                      child: Text(
                        "Yes, delete",
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.035,
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

  Widget _buildBottomBar(BuildContext context, double screenWidth) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.03,
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: screenWidth * 0.135,
          child: ElevatedButton(
            onPressed: () {
              Get.to(() => const AddAddressScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffff8c31),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.025),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_location_alt_outlined, color:AppColors.textWhite, size: screenWidth * 0.05),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  "Add Address",
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: screenWidth * 0.04,
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
