import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/empty_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';

/// Écran d'accueil
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topProductsAsync = ref.watch(topProductsProvider);
    final newProductsAsync = ref.watch(newProductsProvider);
    final userAsync = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parfumerie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push('/products');
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              if (userAsync.value != null) {
                context.push('/cart');
              } else {
                context.push('/login');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(topProductsProvider);
          ref.invalidate(newProductsProvider);
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bannière luxe
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.goldPrimary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Stack(
                  children: [
                    // Overlay subtil
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.goldPrimary.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Découvrez notre collection',
                              style: AppTextStyles.sectionTitle.copyWith(
                                fontSize: 28,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 60,
                              height: 2,
                              color: AppColors.goldPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Catégories rapides
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Catégories',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _CategoryChip(
                      label: 'Homme',
                      icon: Icons.face,
                      onTap: () => context.push('/products?category=Homme'),
                    ),
                    const SizedBox(width: 12),
                    _CategoryChip(
                      label: 'Femme',
                      icon: Icons.face_3,
                      onTap: () => context.push('/products?category=Femme'),
                    ),
                    const SizedBox(width: 12),
                    _CategoryChip(
                      label: 'Unisexe',
                      icon: Icons.people,
                      onTap: () => context.push('/products?category=Unisexe'),
                    ),
                    const SizedBox(width: 12),
                    _CategoryChip(
                      label: 'Coffrets',
                      icon: Icons.card_giftcard,
                      onTap: () => context.push('/products?category=Coffrets'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Top ventes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Top ventes',
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                    ),
                    TextButton(
                      onPressed: () => context.push('/products?sort=top'),
                      child: Text(
                        'Voir tout',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.goldPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              topProductsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return SizedBox(
                          width: 180,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ProductCard(
                              product: product,
                              onTap: () {
                                context.push('/products/${product.id}');
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 280,
                  child: LoadingWidget(),
                ),
                error: (error, stack) => ErrorDisplayWidget(
                  message: 'Erreur lors du chargement',
                  onRetry: () => ref.invalidate(topProductsProvider),
                ),
              ),
              const SizedBox(height: 32),
              
              // Nouveautés
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nouveautés',
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                    ),
                    TextButton(
                      onPressed: () => context.push('/products?sort=newest'),
                      child: Text(
                        'Voir tout',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.goldPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              newProductsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const EmptyWidget(message: 'Aucun nouveau produit');
                  }
                  return SizedBox(
                    height: 280,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return SizedBox(
                          width: 180,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ProductCard(
                              product: product,
                              onTap: () {
                                context.push('/products/${product.id}');
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 280,
                  child: LoadingWidget(),
                ),
                error: (error, stack) => ErrorDisplayWidget(
                  message: 'Erreur lors du chargement',
                  onRetry: () => ref.invalidate(newProductsProvider),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.push('/products');
              break;
            case 2:
              if (userAsync.value != null) {
                context.push('/favorites');
              } else {
                context.push('/login');
              }
              break;
            case 3:
              if (userAsync.value != null) {
                context.push('/profile');
              } else {
                context.push('/login');
              }
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_outlined),
            selectedIcon: Icon(Icons.store),
            label: 'Boutique',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.divider,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: AppColors.goldPrimary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
