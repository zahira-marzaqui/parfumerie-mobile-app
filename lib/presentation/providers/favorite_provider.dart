import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/favorite_repository.dart';
import '../../data/models/favorite_model.dart';
import 'auth_provider.dart';

/// Provider du repository de favoris
final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepository();
});

/// Provider des favoris de l'utilisateur
final favoritesProvider = FutureProvider<List<FavoriteModel>>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  
  if (user == null) return [];
  
  final repo = ref.read(favoriteRepositoryProvider);
  return await repo.getUserFavorites(user.id);
});

/// Provider pour vérifier si un produit est en favoris
final isFavoriteProvider = FutureProvider.family<bool, String>((ref, productId) async {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  
  if (user == null) return false;
  
  final repo = ref.read(favoriteRepositoryProvider);
  return await repo.isFavorite(user.id, productId);
});
