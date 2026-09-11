import 'package:Shopsy/constants/app_colors.dart';
import 'package:Shopsy/controller/address_controller.dart';
import 'package:Shopsy/models/address_model.dart';
import 'package:Shopsy/utils/screen_utils.dart';
import 'package:Shopsy/utils/validation_utils.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xfff1f2f6),
      appBar: AppBar(
        title: Text(
          _isEditing ? "Edit Address" : "Add New Address",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 6.w),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(5.w),
              child: Form(
                key: controller.addressFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Locate on Map"),
                    _buildMapCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Contact Details"),
                    _buildFormCard(
                      [
                        _buildTextField(
                          controller: controller.nameController,
                          label: "Full Name",
                          hint: "Enter your name",
                          validator: (value) => ValidationUtils.validateRequired(value, 'Full Name'),
                        ),
                        const SizedBox(height: 18),
                        _buildTextField(
                          controller: controller.phoneController,
                          label: "Phone Number",
                          hint: "10-digit mobile number",
                          keyboardType: TextInputType.phone,
                          validator: ValidationUtils.validatePhone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Address Details"),
                    _buildFormCard(
                      [
                        _buildTextField(
                          controller: controller.detailAddressController,
                          label: "Address Detail",
                          hint: _isFetchingAddress ? "Locating..." : "House No, Building, Street, Area",
                          maxLines: 3,
                          readOnly: _isFetchingAddress,
                          validator: (value) => ValidationUtils.validateRequired(value, 'Address Detail'),
                        ),
                        if (_isFetchingAddress)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: LinearProgressIndicator(minHeight: 3, color: Color(0xff2874f0)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Address Type"),
                    _buildFormCard(
                      [
                        Obx(() => Row(
                              children: [
                                _typeChip("Home"),
                                SizedBox(width: 4.w),
                                _typeChip("Office"),
                              ],
                            )),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildFormCard(
                      [
                        Obx(() => CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                "Set as default address",
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                              ),
                              value: controller.isDefault.value,
                              onChanged: (val) => controller.isDefault.value = val ?? false,
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: const Color(0xff2874f0),
                            )),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomBar(_isEditing),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return Container(
      height: 28.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.w),
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
                child: Icon(Icons.location_on, color: Colors.red, size: 45),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: FloatingActionButton(
                onPressed: _getCurrentLocation,
                backgroundColor: Colors.white,
                elevation: 3,
                mini: true,
                child: const Icon(Icons.my_location, color: Color(0xff2874f0)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: Colors.black54, fontWeight: FontWeight.w500),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15.sp),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xff2874f0), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _typeChip(String label) {
    bool isSelected = controller.addressType.value == label;
    return GestureDetector(
      onTap: () => controller.addressType.value = label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff2874f0).withOpacity(0.1) : AppColors.textWhite,
          borderRadius: BorderRadius.circular(6.w),
          border: Border.all(color: isSelected ? const Color(0xff2874f0) : AppColors.borderGrey, width: 1.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xff2874f0) : AppColors.textBlack,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 15.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isEditing) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderGrey, width: 0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
        ]
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isFetchingAddress ? null : _saveAddress,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xfffb641b),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
              child: Text(
                isEditing ? "UPDATE ADDRESS" : "SAVE ADDRESS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
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
    if (!(controller.addressFormKey.currentState?.validate() ?? false)) return;
    
    if (controller.detailAddressController.text == "Locating...") {
       Get.snackbar(
        "Wait",
        "Still locating your address. Please wait.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

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
  }
}
