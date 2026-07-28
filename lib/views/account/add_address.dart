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
  
  LatLng _cameraLatLng = _kDefaultLocation;
  bool _isMapReady = false;
  bool _isFetchingAddress = false;
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.editAddress != null;
    
    if (_isEditing) {
      controller.initForEditing(widget.editAddress!);
      _geocodeAddress(widget.editAddress!.address);
    } else {
      controller.clearFields();
      // Start fetching current location immediately when adding a new address
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getCurrentLocation();
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("Location Error", "Please enable location services in your settings.", 
          backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng currentPos = LatLng(position.latitude, position.longitude);
      
      setState(() => _cameraLatLng = currentPos);
      
      if (_isMapReady) {
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(currentPos, 16));
      }
      
      _updateAddressFromCoordinates(currentPos);
    } catch (e) {
      debugPrint("Error getting current location: $e");
    }
  }

  Future<void> _geocodeAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        LatLng pos = LatLng(locations[0].latitude, locations[0].longitude);
        setState(() => _cameraLatLng = pos);
        _mapController?.animateCamera(CameraUpdate.newLatLngZoom(pos, 16));
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
    }
  }

  Future<void> _updateAddressFromCoordinates(LatLng latLng) async {
    if (!mounted) return;
    setState(() => _isFetchingAddress = true);
    
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        List<String> parts = [
          if (place.name != null && place.name != place.street) place.name!,
          if (place.street != null) place.street!,
          if (place.subLocality != null) place.subLocality!,
          if (place.locality != null) place.locality!,
          if (place.subAdministrativeArea != null) place.subAdministrativeArea!,
          if (place.administrativeArea != null) place.administrativeArea!,
          if (place.postalCode != null) place.postalCode!,
        ];
        
        String address = parts.where((p) => p.isNotEmpty).join(", ");
        controller.detailAddressController.text = address;
      }
    } catch (e) {
      debugPrint("Reverse geocoding error: $e");
    } finally {
      if (mounted) setState(() => _isFetchingAddress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    return Scaffold(
      backgroundColor: const Color(0xfff1f2f6),
      appBar: AppBar(
        title: Text(
          _isEditing ? "Edit Address" : "Add New Address",
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
                  const SizedBox(height: 20),
                  _buildSectionTitle("Contact Details", screenWidth),
                  _buildFormCard(
                    [
                      _buildTextField(
                        controller: controller.nameController,
                        label: "Full Name",
                        hint: "Enter your name",
                        screenWidth: screenWidth,
                      ),
                      const SizedBox(height: 16),
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
                  const SizedBox(height: 20),
                  _buildSectionTitle("Address Details", screenWidth),
                  _buildFormCard(
                    [
                      _buildTextField(
                        controller: controller.detailAddressController,
                        label: "Address Detail",
                        hint: _isFetchingAddress ? "Locating..." : "House No, Building, Street, Area",
                        maxLines: 3,
                        screenWidth: screenWidth,
                        readOnly: _isFetchingAddress,
                      ),
                      if (_isFetchingAddress)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: LinearProgressIndicator(minHeight: 2, color: Color(0xff2874f0)),
                        ),
                    ],
                    screenWidth,
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildBottomBar(_isEditing, screenWidth, screenHeight),
        ],
      ),
    );
  }

  Widget _buildMapCard(double screenWidth, double screenHeight) {
    return Container(
      height: screenHeight * 0.25,
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
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _cameraLatLng,
                zoom: 15,
              ),
              onMapCreated: (mapController) {
                _mapController = mapController;
                _isMapReady = true;
              },
              onCameraMove: (position) {
                _cameraLatLng = position.target;
              },
              onCameraIdle: () {
                // Fetch address only if map moved and we're not already fetching
                if (_isMapReady) {
                  _updateAddressFromCoordinates(_cameraLatLng);
                }
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 35),
                child: Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: FloatingActionButton.small(
                onPressed: _getCurrentLocation,
                backgroundColor: Colors.white,
                elevation: 2,
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
      padding: EdgeInsets.only(left: 4, bottom: 12),
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
    bool readOnly = false,
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
          readOnly: readOnly,
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
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isFetchingAddress ? null : _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xfffb641b), // Flipkart Orange
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
                elevation: 0,
              ),
              child: Text(
                isEditing ? "UPDATE ADDRESS" : "SAVE ADDRESS",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
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
        controller.detailAddressController.text.isNotEmpty &&
        controller.detailAddressController.text != "Locating...") {
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
