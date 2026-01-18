import 'cart_item_model.dart';

/// Modèle de panier
class CartModel {
  final String id;
  final String userId;
  final DateTime? updatedAt;
  
  // Relations
  List<CartItemModel> items;
  
  CartModel({
    required this.id,
    required this.userId,
    this.updatedAt,
    this.items = const [],
  });
  
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      items: [],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  /// Nombre total d'articles
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
  
  /// Prix total du panier
  double get totalPrice {
    return items.fold(0.0, (sum, item) {
      final itemTotal = item.totalPrice ?? 0.0;
      return sum + itemTotal;
    });
  }
  
  /// Vérifie si le panier est vide
  bool get isEmpty => items.isEmpty;
  
  /// Vérifie si tous les articles sont en stock
  bool get allItemsInStock {
    return items.every((item) => item.isInStock);
  }
}
