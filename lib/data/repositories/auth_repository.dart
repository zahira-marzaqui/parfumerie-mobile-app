import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/user_profile_model.dart';
import '../../core/constants/app_constants.dart';

/// Repository pour l'authentification
class AuthRepository {
  final _supabase = SupabaseService.client;
  
  /// Inscription avec email et mot de passe
  Future<User> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );
    
    if (response.user == null) {
      throw Exception('Erreur lors de l\'inscription');
    }
    
    // Créer le profil utilisateur
    await _supabase.from('users_profiles').insert({
      'id': response.user!.id,
      'full_name': fullName,
      'phone': phone,
      'role': AppConstants.roleClient,
    });
    
    return response.user!;
  }
  
  /// Connexion avec email et mot de passe
  Future<Session> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.session == null) {
      throw Exception('Erreur lors de la connexion');
    }
    
    return response.session!;
  }
  
  /// Déconnexion
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  
  /// Obtient le profil de l'utilisateur actuel
  Future<UserProfileModel?> getCurrentUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    
    final response = await _supabase
        .from('users_profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    
    if (response == null) return null;
    return UserProfileModel.fromJson(response);
  }
  
  /// Met à jour le profil utilisateur
  Future<void> updateProfile({
    String? fullName,
    String? phone,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');
    
    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    
    await _supabase
        .from('users_profiles')
        .update(updates)
        .eq('id', user.id);
  }
  
  /// Réinitialise le mot de passe
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
