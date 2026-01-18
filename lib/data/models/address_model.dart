/// Modèle d'adresse
class AddressModel {
  final String id;
  final String userId;
  final String city;
  final String addressLine;
  final String zip;
  final bool isDefault;
  
  AddressModel({
    required this.id,
    required this.userId,
    required this.city,
    required this.addressLine,
    required this.zip,
    this.isDefault = false,
  });
  
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      city: json['city'] as String,
      addressLine: json['address_line'] as String,
      zip: json['zip'] as String,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'city': city,
      'address_line': addressLine,
      'zip': zip,
      'is_default': isDefault,
    };
  }
  
  String get fullAddress => '$addressLine, $city $zip';
}
