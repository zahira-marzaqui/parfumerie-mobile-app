import '../services/supabase_service.dart';
import '../models/favorite_model.dart';

/// Repository pour les favoris
class FavoriteRepository {
  final _supabase = SupabaseService.client;
  
  /// Récupère les favoris d'un utilisateur
  Future<List<FavoriteModel>> getUserFavorites(String userId) async {
    final response = await _supabase
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((json) => FavoriteModel.fromJson(json))
        .toList();
  }
  
  /// Vérifie si un produit est en favoris
  Future<bool> isFavorite(String userId, String productId) async {
    final response = await _supabase
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();
    
    return response != null;
  }
  
  /// Ajoute un produit aux favoris
  Future<FavoriteModel> addFavorite({
    required String userId,
    required String productId,
  }) async {
    // Vérifier si déjà en favoris
    final existing = await _supabase
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .eq('product_id', productId)
        .maybeSingle();
    
    if (existing != null) {
      return FavoriteModel.fromJson(existing);
    }
    
    final response = await _supabase
        .from('favorites')
        .insert({
          'user_id': userId,
          'product_id': productId,
        })
        .select()
        .single();
    
    return FavoriteModel.fromJson(response);
  }
  
  /// Supprime un produit des favoris
  Future<void> removeFavorite({
    required String userId,
    required String productId,
  }) async {
    await _supabase
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }
}
