import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/models/cart_model.dart';
import 'auth_provider.dart';

/// Provider du repository de panier
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository();
});

/// Provider du panier de l'utilisateur actuel
final cartProvider = FutureProvider<CartModel?>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  
  if (user == null) return null;
  
  final repo = ref.read(cartRepositoryProvider);
  return await repo.getOrCreateCart(user.id);
});

/// Provider du nombre d'articles dans le panier
final cartItemCountProvider = Provider<int>((ref) {
  final cartAsync = ref.watch(cartProvider);
  return cartAsync.when(
    data: (cart) => cart?.totalItems ?? 0,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
