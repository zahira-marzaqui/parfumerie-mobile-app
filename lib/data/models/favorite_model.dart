/// Modèle de favori
class FavoriteModel {
  final String id;
  final String userId;
  final String productId;
  final DateTime? createdAt;
  
  FavoriteModel({
    required this.id,
    required this.userId,
    required this.productId,
    this.createdAt,
  });
  
  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
