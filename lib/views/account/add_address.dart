import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/controller/address_controller.dart';
import 'package:Shopsy/models/address_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddAddressScreen extends StatefulWidget {
  final Address? editAddress;
  final int? editIndex;

  const AddAddressScreen({super.key, this.editAddress, this.editIndex});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final AddressController controller = Get.find<AddressController>();
  GoogleMapController? _mapController;
  
  static const LatLng _kDefaultLocation = LatLng(10.0159, 76.3419); // Kochi
  
  final Rx<LatLng> _currentLatLng = _kDefaultLocation.obs;
  final RxSet<Marker> _markers = <Marker>{}.obs;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    if (widget.editAddress != null) {
      controller.initForEditing(widget.editAddress!);
      _geocodeAddress(widget.editAddress!.address);
    } else {
      controller.clearFields();
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Location Error", "Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    try {
      Position position = await Geolocator.getCurrentPosition();
      _updateLocation(LatLng(position.latitude, position.longitude));
    } catch (e) {
      debugPrint("Error getting current location: $e");
    }
  }

  Future<void> _geocodeAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        _updateLocation(LatLng(locations[0].latitude, locations[0].longitude));
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
    }
  }

  void _updateLocation(LatLng latLng) async {
    _currentLatLng.value = latLng;
    
    _markers.assign(
      Marker(
        markerId: const MarkerId("picked_location"),
        position: latLng,
        draggable: true,
        onDragEnd: (newPosition) => _onMapTap(newPosition),
      )
    );
    
    if (_isMapReady) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = "${place.name ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.postalCode ?? ''}";
        address = address.replaceAll(RegExp(r'^, +'), '').replaceAll(RegExp(r', ,'), ',');
        controller.detailAddressController.text = address;
      }
    } catch (e) {
      debugPrint("Reverse geocoding error: $e");
    }
  }

  void _onMapTap(LatLng latLng) {
    _updateLocation(latLng);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.editAddress != null;
    final size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    return Scaffold(
      backgroundColor: const Color(0xfff1f2f6),
      appBar: AppBar(
        title: Text(
          isEditing ? "Edit Address" : "Add New Address",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.045,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: screenWidth * 0.06),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Locate on Map", screenWidth),
                  _buildMapCard(screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.03),
                  _buildSectionTitle("Contact Details", screenWidth),
                  _buildFormCard(
                    [
                      _buildTextField(
                        controller: controller.nameController,
                        label: "Full Name",
                        hint: "Enter your name",
                        screenWidth: screenWidth,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      _buildTextField(
                        controller: controller.phoneController,
                        label: "Phone Number",
                        hint: "10-digit mobile number",
                        keyboardType: TextInputType.phone,
                        screenWidth: screenWidth,
                      ),
                    ],
                    screenWidth,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  _buildSectionTitle("Address Details", screenWidth),
                  _buildFormCard(
                    [
                      _buildTextField(
                        controller: controller.detailAddressController,
                        label: "Address Detail",
                        hint: "House No, Building, Street, Area",
                        maxLines: 3,
                        screenWidth: screenWidth,
                      ),
                    ],
                    screenWidth,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  _buildSectionTitle("Address Type", screenWidth),
                  _buildFormCard(
                    [
                      Obx(() => Row(
                            children: [
                              _typeChip("Home", screenWidth),
                              SizedBox(width: screenWidth * 0.03),
                              _typeChip("Office", screenWidth),
                            ],
                          )),
                    ],
                    screenWidth,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  _buildFormCard(
                    [
                      Obx(() => CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              "Set as default address",
                              style: TextStyle(fontSize: screenWidth * 0.035),
                            ),
                            value: controller.isDefault.value,
                            onChanged: (val) => controller.isDefault.value = val ?? false,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: const Color(0xff2874f0),
                          )),
                    ],
                    screenWidth,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
          _buildBottomBar(isEditing, screenWidth, screenHeight),
        ],
      ),
    );
  }

  Widget _buildMapCard(double screenWidth, double screenHeight) {
    return Container(
      height: screenHeight * 0.3,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
        child: Stack(
          children: [
            Obx(() => GoogleMap(
              // REMOVED UniqueKey() - this was causing the blank screen/crash
              initialCameraPosition: CameraPosition(
                target: _currentLatLng.value,
                zoom: 15,
              ),
              onMapCreated: (mapController) {
                _mapController = mapController;
                _isMapReady = true;
                _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLatLng.value));
              },
              markers: _markers,
              onTap: _onMapTap,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            )),
            Positioned(
              right: 12,
              bottom: 12,
              child: FloatingActionButton.small(
                onPressed: _getCurrentLocation,
                backgroundColor: Colors.white,
                child: const Icon(Icons.my_location, color: Color(0xff2874f0)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * 0.01, bottom: screenWidth * 0.03),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.035,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required double screenWidth,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: screenWidth * 0.032, color: Colors.black54),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: screenWidth * 0.038,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: screenWidth * 0.035),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xff2874f0)),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
          ),
        ),
      ],
    );
  }

  Widget _typeChip(String label, double screenWidth) {
    bool isSelected = controller.addressType.value == label;
    return GestureDetector(
      onTap: () => controller.addressType.value = label,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenWidth * 0.02,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff2874f0).withOpacity(0.1) : AppColors.textWhite,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          border: Border.all(color: isSelected ? const Color(0xff2874f0) : AppColors.borderGrey),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xff2874f0) : AppColors.textBlack,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: screenWidth * 0.035,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isEditing, double screenWidth, double screenHeight) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderGrey)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: SizedBox(
            width: double.infinity,
            height: screenHeight * 0.065,
            child: ElevatedButton(
              onPressed: _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffff8c31),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.01),
                ),
                elevation: 0,
              ),
              child: Text(
                isEditing ? "UPDATE ADDRESS" : "SAVE ADDRESS",
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveAddress() async {
    if (controller.nameController.text.isNotEmpty &&
        controller.phoneController.text.isNotEmpty &&
        controller.detailAddressController.text.isNotEmpty) {
      final newAddress = Address(
        name: controller.nameController.text.trim(),
        phone: controller.phoneController.text.trim(),
        address: controller.detailAddressController.text.trim(),
        type: controller.addressType.value,
        isDefault: controller.isDefault.value,
      );

      if (widget.editAddress != null && widget.editIndex != null) {
        controller.addresses[widget.editIndex!] = newAddress;
        if (newAddress.isDefault) {
          await controller.setDefaultAddress(widget.editIndex!);
        } else {
          await controller.saveAddresses();
        }
      } else {
        await controller.addAddress(newAddress);
      }

      Get.back();
      Get.snackbar(
        "Success",
        widget.editAddress != null ? "Address updated" : "Address added",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.backgroundSuccess,
        colorText: AppColors.textWhite,
      );
    } else {
      Get.snackbar(
        "Error",
        "Please fill all mandatory fields",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.backgroundAlert,
        colorText: AppColors.textWhite,
      );
    }
  }
}
