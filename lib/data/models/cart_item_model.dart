import 'product_variant_model.dart';
import 'product_model.dart';

/// Modèle d'élément du panier
class CartItemModel {
  final String id;
  final String cartId;
  final String variantId;
  final int quantity;
  
  // Relations (chargées séparément)
  ProductVariantModel? variant;
  ProductModel? product;
  
  CartItemModel({
    required this.id,
    required this.cartId,
    required this.variantId,
    required this.quantity,
    this.variant,
    this.product,
  });
  
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      cartId: json['cart_id'] as String,
      variantId: json['variant_id'] as String,
      quantity: json['quantity'] as int,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'variant_id': variantId,
      'quantity': quantity,
    };
  }
  
  /// Prix unitaire de l'élément
  double? get unitPrice {
    if (product == null || variant == null) return null;
    return variant!.getTotalPrice(product!.price);
  }
  
  /// Prix total de l'élément (unitaire * quantité)
  double? get totalPrice {
    final unit = unitPrice;
    if (unit == null) return null;
    return unit * quantity;
  }
  
  /// Vérifie si l'élément est en stock
  bool get isInStock {
    if (variant == null) return false;
    return variant!.stock >= quantity;
  }
}
