import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/models/product_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/brand_model.dart';

/// Provider du repository de produits
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

/// Provider des produits avec filtres
final productsProvider = FutureProvider.family<List<ProductModel>, Map<String, dynamic>>((ref, filters) async {
  final repo = ref.read(productRepositoryProvider);
  return await repo.getProducts(
    page: filters['page'] ?? 0,
    pageSize: filters['pageSize'] ?? 20,
    searchQuery: filters['searchQuery'],
    brandId: filters['brandId'],
    categoryId: filters['categoryId'],
    concentration: filters['concentration'],
    minPrice: filters['minPrice'],
    maxPrice: filters['maxPrice'],
    sortBy: filters['sortBy'],
  );
});

/// Provider d'un produit par ID
final productByIdProvider = FutureProvider.family<ProductModel?, String>((ref, id) async {
  final repo = ref.read(productRepositoryProvider);
  return await repo.getProductById(id);
});

/// Provider des produits top ventes
final topProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.read(productRepositoryProvider);
  return await repo.getTopProducts();
});

/// Provider des nouveaux produits
final newProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final repo = ref.read(productRepositoryProvider);
  return await repo.getNewProducts();
});

/// Provider des catégories
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repo = ref.read(productRepositoryProvider);
  return await repo.getCategories();
});

/// Provider des marques
final brandsProvider = FutureProvider<List<BrandModel>>((ref) async {
  final repo = ref.read(productRepositoryProvider);
  return await repo.getBrands();
});
