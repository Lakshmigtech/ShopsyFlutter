import '../models/address_model.dart';

class AddressUIHelper {
  static String getContactInfo(Address address) {
    return "${address.name}, ${address.phone}";
  }

  static String getFullAddressSummary(Address address) {
    return "${address.name}, ${address.address}, ${address.phone}";
  }
}
