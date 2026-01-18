import '../../core/constants/app_constants.dart';
import 'order_item_model.dart';
import 'address_model.dart';

/// Modèle de commande
class OrderModel {
  final String id;
  final String userId;
  final String? addressId;
  final String deliveryMode;
  final String paymentMethod;
  final String status;
  final double total;
  final double shippingFee;
  final DateTime? createdAt;
  
  // Relations (chargées séparément)
  List<OrderItemModel> items;
  AddressModel? address;
  
  OrderModel({
    required this.id,
    required this.userId,
    this.addressId,
    required this.deliveryMode,
    this.paymentMethod = AppConstants.paymentMethodCOD,
    required this.status,
    required this.total,
    required this.shippingFee,
    this.createdAt,
    this.items = const [],
    this.address,
  });
  
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      addressId: json['address_id'] as String?,
      deliveryMode: json['delivery_mode'] as String,
      paymentMethod: json['payment_method'] as String? ?? AppConstants.paymentMethodCOD,
      status: json['status'] as String,
      total: (json['total'] as num).toDouble(),
      shippingFee: (json['shipping_fee'] as num).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      items: [],
      address: null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'address_id': addressId,
      'delivery_mode': deliveryMode,
      'payment_method': paymentMethod,
      'status': status,
      'total': total,
      'shipping_fee': shippingFee,
      'created_at': createdAt?.toIso8601String(),
    };
  }
  
  /// Prix total avec frais de livraison
  double get totalWithShipping => total + shippingFee;
  
  /// Vérifie si la commande peut être annulée
  bool get canBeCancelled {
    return status == AppConstants.orderStatusPending ||
        status == AppConstants.orderStatusPaid;
  }
  
  /// Libellé du statut en français
  String get statusLabel {
    switch (status) {
      case AppConstants.orderStatusPending:
        return 'En attente';
      case AppConstants.orderStatusPaid:
        return 'Payée';
      case AppConstants.orderStatusShipped:
        return 'Expédiée';
      case AppConstants.orderStatusDelivered:
        return 'Livrée';
      case AppConstants.orderStatusCancelled:
        return 'Annulée';
      default:
        return status;
    }
  }
}
