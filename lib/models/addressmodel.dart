class Address {
  final String name;
  final String phone;
  final String address;
  final String type;
  final bool isDefault;

  Address({
    required this.name,
    required this.phone,
    required this.address,
    required this.type,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      type: json['type'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }
}
