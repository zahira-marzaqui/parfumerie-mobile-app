import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/repositories/favorite_repository.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/error_widget.dart';

/// Écran des favoris
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes favoris'),
      ),
      body: favoritesAsync.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return const EmptyWidget(
              message: 'Aucun favori',
              icon: Icons.favorite_border,
            );
          }
          
          // Charger les produits
          final productIds = favorites.map((f) => f.productId).toList();
          
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(favoritesProvider);
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: productIds.length,
              itemBuilder: (context, index) {
                final productId = productIds[index];
                final productAsync = ref.watch(productByIdProvider(productId));
                
                return productAsync.when(
                  data: (product) {
                    if (product == null) {
                      return const SizedBox.shrink();
                    }
                    
                    return ProductCard(
                      product: product,
                      isFavorite: true,
                      onTap: () {
                        context.push('/products/${product.id}');
                      },
                      onFavoriteTap: () async {
                        final favoriteRepo = ref.read(favoriteRepositoryProvider);
                        final userAsync = ref.watch(currentUserProvider);
                        final user = userAsync.value;
                        
                        if (user != null) {
                          await favoriteRepo.removeFavorite(
                            userId: user.id,
                            productId: product.id,
                          );
                          ref.invalidate(favoritesProvider);
                        }
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) => const SizedBox.shrink(),
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorDisplayWidget(
          message: 'Erreur lors du chargement des favoris',
          onRetry: () => ref.invalidate(favoritesProvider),
        ),
      ),
    );
  }
}
