/// Modèle d'image de produit
class ProductImageModel {
  final String id;
  final String productId;
  final String imageUrl;
  final bool isCover;
  
  ProductImageModel({
    required this.id,
    required this.productId,
    required this.imageUrl,
    required this.isCover,
  });
  
  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      imageUrl: json['image_url'] as String,
      isCover: json['is_cover'] as bool? ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'image_url': imageUrl,
      'is_cover': isCover,
    };
  }
}
