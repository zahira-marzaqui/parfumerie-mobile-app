/// Modèle de marque
class BrandModel {
  final String id;
  final String name;
  
  BrandModel({
    required this.id,
    required this.name,
  });
  
  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
