import '../services/supabase_service.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../models/address_model.dart';
import '../../core/constants/app_constants.dart';

/// Repository pour les commandes
class OrderRepository {
  final _supabase = SupabaseService.client;
  
  /// Crée une nouvelle commande
  Future<OrderModel> createOrder({
    required String userId,
    required String? addressId,
    required String deliveryMode,
    required double total,
    required List<Map<String, dynamic>> items, // [{variant_id, quantity, unit_price}]
  }) async {
    final shippingFee = deliveryMode == AppConstants.deliveryModeExpress
        ? AppConstants.expressShippingFee
        : AppConstants.standardShippingFee;
    
    // Créer la commande
    final orderResponse = await _supabase
        .from('orders')
        .insert({
          'user_id': userId,
          'address_id': addressId,
          'delivery_mode': deliveryMode,
          'payment_method': AppConstants.paymentMethodCOD,
          'status': AppConstants.orderStatusPending,
          'total': total,
          'shipping_fee': shippingFee,
        })
        .select()
        .single();
    
    final order = OrderModel.fromJson(orderResponse);
    
    // Créer les éléments de commande
    final orderItems = <OrderItemModel>[];
    for (final item in items) {
      final itemResponse = await _supabase
          .from('order_items')
          .insert({
            'order_id': order.id,
            'variant_id': item['variant_id'],
            'quantity': item['quantity'],
            'unit_price': item['unit_price'],
          })
          .select()
          .single();
      
      orderItems.add(OrderItemModel.fromJson(itemResponse));
      
      // Décrémenter le stock
      try {
        await _supabase.rpc('decrement_stock', params: {
          'variant_id': item['variant_id'],
          'quantity': item['quantity'],
        });
      } catch (e) {
        // Si la fonction RPC n'existe pas, décrémenter manuellement
        final variant = await _supabase
            .from('product_variants')
            .select('stock')
            .eq('id', item['variant_id'])
            .single();
        
        if (variant['stock'] < item['quantity']) {
          throw Exception('Stock insuffisant');
        }
        
        await _supabase
            .from('product_variants')
            .update({'stock': variant['stock'] - item['quantity']})
            .eq('id', item['variant_id']);
      }
    }
    
    order.items = orderItems;
    return order;
  }
  
  /// Récupère les commandes d'un utilisateur
  Future<List<OrderModel>> getUserOrders(String userId) async {
    final response = await _supabase
        .from('orders')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    final orders = (response as List)
        .map((json) => OrderModel.fromJson(json))
        .toList();
    
    // Charger les éléments et adresses
    for (final order in orders) {
      order.items = await getOrderItems(order.id);
      if (order.addressId != null) {
        order.address = await getAddress(order.addressId!);
      }
    }
    
    return orders;
  }
  
  /// Récupère une commande par ID
  Future<OrderModel?> getOrderById(String orderId) async {
    final response = await _supabase
        .from('orders')
        .select()
        .eq('id', orderId)
        .maybeSingle();
    
    if (response == null) return null;
    
    final order = OrderModel.fromJson(response);
    order.items = await getOrderItems(order.id);
    if (order.addressId != null) {
      order.address = await getAddress(order.addressId!);
    }
    
    return order;
  }
  
  /// Récupère les éléments d'une commande
  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    final response = await _supabase
        .from('order_items')
        .select()
        .eq('order_id', orderId);
    
    return (response as List)
        .map((json) => OrderItemModel.fromJson(json))
        .toList();
  }
  
  /// Récupère une adresse
  Future<AddressModel?> getAddress(String addressId) async {
    final response = await _supabase
        .from('addresses')
        .select()
        .eq('id', addressId)
        .maybeSingle();
    
    if (response == null) return null;
    return AddressModel.fromJson(response);
  }
  
  // ========== Méthodes Admin ==========
  
  /// Récupère toutes les commandes (Admin)
  Future<List<OrderModel>> getAllOrders({
    String? status,
  }) async {
    var query = _supabase.from('orders').select();
    
    if (status != null) {
      query = query.eq('status', status);
    }
    
    final response = await query.order('created_at', ascending: false);
    final orders = (response as List)
        .map((json) => OrderModel.fromJson(json))
        .toList();
    
    // Charger les éléments et adresses
    for (final order in orders) {
      order.items = await getOrderItems(order.id);
      if (order.addressId != null) {
        order.address = await getAddress(order.addressId!);
      }
    }
    
    return orders;
  }
  
  /// Met à jour le statut d'une commande (Admin)
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final response = await _supabase
        .from('orders')
        .update({'status': status})
        .eq('id', orderId)
        .select()
        .maybeSingle();
    
    if (response == null) {
      throw Exception('Commande non trouvée');
    }
    return OrderModel.fromJson(response);
  }
  
  /// Annule une commande
  Future<void> cancelOrder(String orderId) async {
    final order = await getOrderById(orderId);
    if (order == null || !order.canBeCancelled) {
      throw Exception('Cette commande ne peut pas être annulée');
    }
    
    // Restaurer le stock
    for (final item in order.items) {
      try {
        await _supabase.rpc('increment_stock', params: {
          'variant_id': item.variantId,
          'quantity': item.quantity,
        });
      } catch (e) {
        // Si la fonction RPC n'existe pas, incrémenter manuellement
        final variant = await _supabase
            .from('product_variants')
            .select('stock')
            .eq('id', item.variantId)
            .single();
        
        await _supabase
            .from('product_variants')
            .update({'stock': variant['stock'] + item.quantity})
            .eq('id', item.variantId);
      }
    }
    
    // Mettre à jour le statut
    await _supabase
        .from('orders')
        .update({'status': AppConstants.orderStatusCancelled})
        .eq('id', orderId);
  }
}
