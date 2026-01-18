import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';

/// Service Supabase singleton
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  /// Initialise Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
  }
  
  /// Obtient l'utilisateur actuel
  User? get currentUser => client.auth.currentUser;
  
  /// Vérifie si l'utilisateur est connecté
  bool get isAuthenticated => currentUser != null;
  
  /// Stream des changements d'authentification
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
