import '../services/supabase_service.dart';
import '../models/address_model.dart';

/// Repository pour les adresses
class AddressRepository {
  final _supabase = SupabaseService.client;
  
  /// Récupère les adresses d'un utilisateur
  Future<List<AddressModel>> getUserAddresses(String userId) async {
    final response = await _supabase
        .from('addresses')
        .select()
        .eq('user_id', userId)
        .order('is_default', ascending: false);
    
    return (response as List)
        .map((json) => AddressModel.fromJson(json))
        .toList();
  }
  
  /// Récupère l'adresse par défaut
  Future<AddressModel?> getDefaultAddress(String userId) async {
    final response = await _supabase
        .from('addresses')
        .select()
        .eq('user_id', userId)
        .eq('is_default', true)
        .maybeSingle();
    
    if (response == null) return null;
    return AddressModel.fromJson(response);
  }
  
  /// Crée une nouvelle adresse
  Future<AddressModel> createAddress({
    required String userId,
    required String city,
    required String addressLine,
    required String zip,
    bool isDefault = false,
  }) async {
    // Si c'est l'adresse par défaut, désactiver les autres
    if (isDefault) {
      await _supabase
          .from('addresses')
          .update({'is_default': false})
          .eq('user_id', userId);
    }
    
    final response = await _supabase
        .from('addresses')
        .insert({
          'user_id': userId,
          'city': city,
          'address_line': addressLine,
          'zip': zip,
          'is_default': isDefault,
        })
        .select()
        .single();
    
    return AddressModel.fromJson(response);
  }
  
  /// Met à jour une adresse
  Future<AddressModel> updateAddress(AddressModel address) async {
    // Si c'est l'adresse par défaut, désactiver les autres
    if (address.isDefault) {
      await _supabase
          .from('addresses')
          .update({'is_default': false})
          .eq('user_id', address.userId)
          .neq('id', address.id);
    }
    
    final response = await _supabase
        .from('addresses')
        .update(address.toJson())
        .eq('id', address.id)
        .select()
        .single();
    
    return AddressModel.fromJson(response);
  }
  
  /// Supprime une adresse
  Future<void> deleteAddress(String addressId) async {
    await _supabase.from('addresses').delete().eq('id', addressId);
  }
  
  /// Définit une adresse comme par défaut
  Future<void> setDefaultAddress(String userId, String addressId) async {
    // Désactiver toutes les autres adresses par défaut
    await _supabase
        .from('addresses')
        .update({'is_default': false})
        .eq('user_id', userId);
    
    // Activer cette adresse
    await _supabase
        .from('addresses')
        .update({'is_default': true})
        .eq('id', addressId);
  }
}
