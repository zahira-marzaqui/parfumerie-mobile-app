/// Modèle d'élément de commande
class OrderItemModel {
  final String id;
  final String orderId;
  final String variantId;
  final double unitPrice;
  final int quantity;
  
  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.variantId,
    required this.unitPrice,
    required this.quantity,
  });
  
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      variantId: json['variant_id'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'variant_id': variantId,
      'unit_price': unitPrice,
      'quantity': quantity,
    };
  }
  
  /// Prix total de l'élément
  double get totalPrice => unitPrice * quantity;
}
