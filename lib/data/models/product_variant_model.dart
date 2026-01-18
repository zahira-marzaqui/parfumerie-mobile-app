/// Modèle de variante de produit
class ProductVariantModel {
  final String id;
  final String productId;
  final int volumeMl;
  final bool isGiftSet;
  final int stock;
  final double extraPrice;
  
  ProductVariantModel({
    required this.id,
    required this.productId,
    required this.volumeMl,
    required this.isGiftSet,
    required this.stock,
    required this.extraPrice,
  });
  
  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      volumeMl: json['volume_ml'] as int,
      isGiftSet: json['is_gift_set'] as bool? ?? false,
      stock: json['stock'] as int? ?? 0,
      extraPrice: (json['extra_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'volume_ml': volumeMl,
      'is_gift_set': isGiftSet,
      'stock': stock,
      'extra_price': extraPrice,
    };
  }
  
  /// Prix total de la variante (prix produit + extra)
  double getTotalPrice(double basePrice) {
    return basePrice + extraPrice;
  }
  
  /// Vérifie si la variante est en stock
  bool get isInStock => stock > 0;
}
