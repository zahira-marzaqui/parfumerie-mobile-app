import '../services/supabase_service.dart';
import '../models/cart_model.dart';
import '../models/cart_item_model.dart';
import '../models/product_variant_model.dart';
import 'product_repository.dart';

/// Repository pour le panier
class CartRepository {
  final _supabase = SupabaseService.client;
  final _productRepo = ProductRepository();
  
  /// Obtient ou crée le panier de l'utilisateur
  Future<CartModel> getOrCreateCart(String userId) async {
    // Chercher un panier existant
    final response = await _supabase
        .from('carts')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    
    if (response != null) {
      final cart = CartModel.fromJson(response);
      cart.items = await getCartItems(cart.id);
      return cart;
    }
    
    // Créer un nouveau panier
    final newCartResponse = await _supabase
        .from('carts')
        .insert({'user_id': userId})
        .select()
        .single();
    
    return CartModel.fromJson(newCartResponse);
  }
  
  /// Récupère les éléments du panier avec leurs relations
  Future<List<CartItemModel>> getCartItems(String cartId) async {
    final response = await _supabase
        .from('cart_items')
        .select()
        .eq('cart_id', cartId);
    
    final items = (response as List)
        .map((json) => CartItemModel.fromJson(json))
        .toList();
    
    // Charger les variantes et produits
    for (final item in items) {
      try {
        final variant = await _supabase
            .from('product_variants')
            .select()
            .eq('id', item.variantId)
            .single();
        
        item.variant = ProductVariantModel.fromJson(variant);
        
        if (item.variant != null) {
          final product = await _productRepo.getProductById(item.variant!.productId);
          item.product = product;
        }
      } catch (e) {
        // Ignorer les erreurs (variante ou produit supprimé)
      }
    }
    
    return items;
  }
  
  /// Ajoute un article au panier
  Future<CartItemModel> addToCart({
    required String cartId,
    required String variantId,
    required int quantity,
  }) async {
    // Vérifier si l'article existe déjà
    final existing = await _supabase
        .from('cart_items')
        .select()
        .eq('cart_id', cartId)
        .eq('variant_id', variantId)
        .maybeSingle();
    
    if (existing != null) {
      // Mettre à jour la quantité
      final newQuantity = (existing['quantity'] as int) + quantity;
      final response = await _supabase
          .from('cart_items')
          .update({'quantity': newQuantity})
          .eq('id', existing['id'])
          .select()
          .single();
      
      return CartItemModel.fromJson(response);
    }
    
    // Créer un nouvel élément
    final response = await _supabase
        .from('cart_items')
        .insert({
          'cart_id': cartId,
          'variant_id': variantId,
          'quantity': quantity,
        })
        .select()
        .single();
    
    // Mettre à jour la date du panier
    await _supabase
        .from('carts')
        .update({'updated_at': DateTime.now().toIso8601String()})
        .eq('id', cartId);
    
    return CartItemModel.fromJson(response);
  }
  
  /// Met à jour la quantité d'un article
  Future<void> updateCartItemQuantity({
    required String itemId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      await removeFromCart(itemId);
      return;
    }
    
    await _supabase
        .from('cart_items')
        .update({'quantity': quantity})
        .eq('id', itemId);
  }
  
  /// Supprime un article du panier
  Future<void> removeFromCart(String itemId) async {
    await _supabase.from('cart_items').delete().eq('id', itemId);
  }
  
  /// Vide le panier
  Future<void> clearCart(String cartId) async {
    await _supabase.from('cart_items').delete().eq('cart_id', cartId);
    await _supabase
        .from('carts')
        .update({'updated_at': DateTime.now().toIso8601String()})
        .eq('id', cartId);
  }
}
