import 'dart:io';
import '../services/supabase_service.dart';
import '../../core/config/supabase_config.dart';

/// Repository pour le stockage d'images
class StorageRepository {
  final _supabase = SupabaseService.client;
  
  /// Upload une image de produit
  Future<String> uploadProductImage({
    required File imageFile,
    required String productId,
    String? fileName,
  }) async {
    final finalFileName = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$productId/$finalFileName';
    
    await _supabase.storage
        .from(SupabaseConfig.productImagesBucket)
        .upload(path, imageFile);
    
    // Obtenir l'URL publique
    final url = _supabase.storage
        .from(SupabaseConfig.productImagesBucket)
        .getPublicUrl(path);
    
    return url;
  }
  
  /// Supprime une image de produit
  Future<void> deleteProductImage(String imagePath) async {
    await _supabase.storage
        .from(SupabaseConfig.productImagesBucket)
        .remove([imagePath]);
  }
  
  /// Obtient l'URL publique d'une image
  String getPublicUrl(String path) {
    return _supabase.storage
        .from(SupabaseConfig.productImagesBucket)
        .getPublicUrl(path);
  }
}
