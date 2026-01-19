import '../services/supabase_service.dart';
import '../models/product_model.dart';
import '../models/product_image_model.dart';
import '../models/product_variant_model.dart';
import '../models/category_model.dart';
import '../models/brand_model.dart';

/// Repository pour les produits
class ProductRepository {
  final _supabase = SupabaseService.client;
  
  /// Récupère tous les produits avec pagination
  Future<List<ProductModel>> getProducts({
    int page = 0,
    int pageSize = 20,
    String? searchQuery,
    String? brandId,
    String? categoryId,
    String? concentration,
    double? minPrice,
    double? maxPrice,
    String? sortBy, // 'price_asc', 'price_desc', 'rating', 'newest'
  }) async {
    try {
      var query = _supabase.from('products').select();
      
      // Filtres
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$searchQuery%');
      }
      if (brandId != null) {
        query = query.eq('brand_id', brandId);
      }
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      if (concentration != null) {
        query = query.eq('concentration', concentration);
      }
      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }
      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }
      
      // Tri
      String orderColumn = 'id'; // Utiliser 'id' par défaut au lieu de 'created_at'
      bool ascending = false;
      if (sortBy != null) {
        switch (sortBy) {
          case 'price_asc':
            orderColumn = 'price';
            ascending = true;
            break;
          case 'price_desc':
            orderColumn = 'price';
            ascending = false;
            break;
          case 'rating':
            orderColumn = 'rating';
            ascending = false;
            break;
          case 'newest':
            // Essayer created_at, sinon utiliser id
            orderColumn = 'id';
            ascending = false;
            break;
        }
      }
      
      // Exécuter la requête avec tri et pagination
      try {
        final response = await query
            .order(orderColumn, ascending: ascending)
            .range(page * pageSize, (page + 1) * pageSize - 1);
        
        return (response as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();
      } catch (e) {
        // Si la colonne de tri n'existe pas, essayer avec 'id'
        if (orderColumn != 'id') {
          try {
            final fallbackResponse = await query
                .order('id', ascending: false)
                .range(page * pageSize, (page + 1) * pageSize - 1);
            
            return (fallbackResponse as List)
                .map((json) => ProductModel.fromJson(json))
                .toList();
          } catch (_) {
            // Si même 'id' ne fonctionne pas, retourner liste vide
            return [];
          }
        }
        // Si on était déjà sur 'id', retourner liste vide
        return [];
      }
    } catch (e) {
      // Si la table n'existe pas ou erreur, retourner une liste vide
      print('Erreur lors de la récupération des produits: $e');
      return [];
    }
  }
  
  /// Récupère un produit par ID avec ses relations
  Future<ProductModel?> getProductById(String id) async {
    final response = await _supabase
        .from('products')
        .select()
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;
    
    final product = ProductModel.fromJson(response);
    
    // Charger les images
    product.images = await getProductImages(id);
    
    // Charger les variantes
    product.variants = await getProductVariants(id);
    
    return product;
  }
  
  /// Récupère les images d'un produit
  Future<List<ProductImageModel>> getProductImages(String productId) async {
    final response = await _supabase
        .from('product_images')
        .select()
        .eq('product_id', productId)
        .order('is_cover', ascending: false);
    
    return (response as List)
        .map((json) => ProductImageModel.fromJson(json))
        .toList();
  }
  
  /// Récupère les variantes d'un produit
  Future<List<ProductVariantModel>> getProductVariants(String productId) async {
    final response = await _supabase
        .from('product_variants')
        .select()
        .eq('product_id', productId);
    
    return (response as List)
        .map((json) => ProductVariantModel.fromJson(json))
        .toList();
  }
  
  /// Récupère les produits top ventes
  Future<List<ProductModel>> getTopProducts({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('is_top', true)
          .order('rating', ascending: false)
          .limit(limit);
      
      return (response as List)
          .map((json) => ProductModel.fromJson(json))
          .toList();
    } catch (e) {
      // Si la table n'existe pas ou erreur, retourner une liste vide
      print('Erreur lors de la récupération des top produits: $e');
      return [];
    }
  }
  
  /// Récupère les nouveaux produits
  Future<List<ProductModel>> getNewProducts({int limit = 10}) async {
    try {
      var query = _supabase
          .from('products')
          .select()
          .eq('is_new', true);
      
      // Essayer avec created_at, sinon utiliser id
      try {
        final response = await query
            .order('created_at', ascending: false)
            .limit(limit);
        
        return (response as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();
      } catch (e) {
        // Si created_at n'existe pas, utiliser id
        final response = await query
            .order('id', ascending: false)
            .limit(limit);
        
        return (response as List)
            .map((json) => ProductModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      // Si la table n'existe pas ou erreur, retourner une liste vide
      print('Erreur lors de la récupération des nouveaux produits: $e');
      return [];
    }
  }
  
  /// Récupère toutes les catégories
  Future<List<CategoryModel>> getCategories() async {
    final response = await _supabase.from('categories').select();
    return (response as List)
        .map((json) => CategoryModel.fromJson(json))
        .toList();
  }
  
  /// Récupère toutes les marques
  Future<List<BrandModel>> getBrands() async {
    final response = await _supabase.from('brands').select();
    return (response as List)
        .map((json) => BrandModel.fromJson(json))
        .toList();
  }
  
  // ========== Méthodes Admin ==========
  
  /// Crée un nouveau produit (Admin)
  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await _supabase
        .from('products')
        .insert(product.toJson())
        .select()
        .single();
    
    return ProductModel.fromJson(response);
  }
  
  /// Met à jour un produit (Admin)
  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await _supabase
        .from('products')
        .update(product.toJson())
        .eq('id', product.id)
        .select()
        .single();
    
    return ProductModel.fromJson(response);
  }
  
  /// Supprime un produit (Admin)
  Future<void> deleteProduct(String id) async {
    await _supabase.from('products').delete().eq('id', id);
  }
  
  /// Ajoute une image à un produit (Admin)
  Future<ProductImageModel> addProductImage({
    required String productId,
    required String imageUrl,
    bool isCover = false,
  }) async {
    // Si c'est une image de couverture, désactiver les autres
    if (isCover) {
      await _supabase
          .from('product_images')
          .update({'is_cover': false})
          .eq('product_id', productId);
    }
    
    final response = await _supabase
        .from('product_images')
        .insert({
          'product_id': productId,
          'image_url': imageUrl,
          'is_cover': isCover,
        })
        .select()
        .single();
    
    return ProductImageModel.fromJson(response);
  }
  
  /// Supprime une image de produit (Admin)
  Future<void> deleteProductImage(String imageId) async {
    await _supabase.from('product_images').delete().eq('id', imageId);
  }
  
  /// Crée une variante de produit (Admin)
  Future<ProductVariantModel> createVariant(ProductVariantModel variant) async {
    final response = await _supabase
        .from('product_variants')
        .insert(variant.toJson())
        .select()
        .single();
    
    return ProductVariantModel.fromJson(response);
  }
  
  /// Met à jour une variante (Admin)
  Future<ProductVariantModel> updateVariant(ProductVariantModel variant) async {
    final response = await _supabase
        .from('product_variants')
        .update(variant.toJson())
        .eq('id', variant.id)
        .select()
        .single();
    
    return ProductVariantModel.fromJson(response);
  }
  
  /// Supprime une variante (Admin)
  Future<void> deleteVariant(String variantId) async {
    await _supabase.from('product_variants').delete().eq('id', variantId);
  }
}
