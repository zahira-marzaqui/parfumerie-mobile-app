import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/favorite_repository.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

/// Écran de détails produit
class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  
  const ProductDetailScreen({
    super.key,
    required this.productId,
  });
  
  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  // int _selectedImageIndex = 0; // Non utilisé pour l'instant
  String? _selectedVariantId;
  int _quantity = 1;
  
  Future<void> _addToCart() async {
    final userAsync = ref.read(currentUserProvider);
    final user = userAsync.value;
    
    if (user == null) {
      if (mounted) {
        context.push('/login');
      }
      return;
    }
    
    final productAsync = ref.read(productByIdProvider(widget.productId));
    final product = productAsync.value;
    
    if (product == null) return;
    
    // Utiliser la première variante si aucune sélectionnée
    final variantId = _selectedVariantId ?? 
        (product.variants.isNotEmpty 
            ? product.variants.first.id 
            : null);
    
    if (variantId == null) {
      // Pas de variante, utiliser le produit directement
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une variante')),
      );
      return;
    }
    
    try {
      final cartRepo = ref.read(cartRepositoryProvider);
      final cart = await cartRepo.getOrCreateCart(user.id);
      
      await cartRepo.addToCart(
        cartId: cart.id,
        variantId: variantId,
        quantity: _quantity,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produit ajouté au panier')),
        );
        ref.invalidate(cartProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }
  
  Future<void> _toggleFavorite() async {
    final userAsync = ref.read(currentUserProvider);
    final user = userAsync.value;
    
    if (user == null) {
      if (mounted) {
        context.push('/login');
      }
      return;
    }
    
    try {
      final favoriteRepo = ref.read(favoriteRepositoryProvider);
      final isFavorite = await favoriteRepo.isFavorite(user.id, widget.productId);
      
      if (isFavorite) {
        await favoriteRepo.removeFavorite(
          userId: user.id,
          productId: widget.productId,
        );
      } else {
        await favoriteRepo.addFavorite(
          userId: user.id,
          productId: widget.productId,
        );
      }
      
      ref.invalidate(isFavoriteProvider(widget.productId));
      ref.invalidate(favoritesProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productByIdProvider(widget.productId));
    final userAsync = ref.watch(currentUserProvider);
    final isFavoriteAsync = userAsync.value != null
        ? ref.watch(isFavoriteProvider(widget.productId))
        : null;
    
    return Scaffold(
      body: productAsync.when(
        data: (product) {
          if (product == null) {
            return const ErrorDisplayWidget(message: 'Produit introuvable');
          }
          
          final images = product.images.isNotEmpty
              ? product.images.map((img) => img.imageUrl).toList()
              : [''];
          
          final isFavorite = isFavoriteAsync?.value ?? false;
          
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: images.isNotEmpty && images.first.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: images.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.backgroundCard,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.goldPrimary,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.backgroundCard,
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.backgroundCard,
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.textSecondary,
                          ),
                        ),
                ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? AppColors.goldPrimary : AppColors.textPrimary,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                          Row(
                            children: [
                              if (product.rating != null) ...[
                                Icon(
                                  Icons.star,
                                  size: 18,
                                  color: AppColors.goldPrimary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  product.rating!.toStringAsFixed(1),
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                              ],
                          Text(
                            PriceFormatter.format(product.price),
                            style: AppTextStyles.price,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Variantes
                      if (product.variants.isNotEmpty) ...[
                        Text(
                          'Variantes',
                          style: AppTextStyles.label.copyWith(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: product.variants.map((variant) {
                            final isSelected = _selectedVariantId == variant.id;
                            return FilterChip(
                              label: Text('${variant.volumeMl}ml'),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedVariantId = selected ? variant.id : null;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Quantité
                      Text(
                        'Quantité',
                        style: AppTextStyles.label.copyWith(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: AppColors.goldPrimary,
                            ),
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          Text(
                            '$_quantity',
                            style: AppTextStyles.priceSmall.copyWith(
                              fontSize: 20,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: AppColors.goldPrimary,
                            ),
                            onPressed: () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Description
                      if (product.description != null) ...[
                        Text(
                          'Description',
                          style: AppTextStyles.label.copyWith(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          product.description!,
                          style: AppTextStyles.description,
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Notes
                      if (product.topNotes != null ||
                          product.heartNotes != null ||
                          product.baseNotes != null) ...[
                        Text(
                          'Notes',
                          style: AppTextStyles.label.copyWith(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (product.topNotes != null)
                          _NoteRow(label: 'Tête', notes: product.topNotes!),
                        if (product.heartNotes != null)
                          _NoteRow(label: 'Cœur', notes: product.heartNotes!),
                        if (product.baseNotes != null)
                          _NoteRow(label: 'Fond', notes: product.baseNotes!),
                        const SizedBox(height: 24),
                      ],
                      
                      // Informations supplémentaires
                      if (product.concentration != null ||
                          product.season != null ||
                          product.occasion != null) ...[
                        Text(
                          'Informations',
                          style: AppTextStyles.label.copyWith(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (product.concentration != null)
                          _InfoRow(label: 'Concentration', value: product.concentration!),
                        if (product.season != null)
                          _InfoRow(label: 'Saison', value: product.season!),
                        if (product.occasion != null)
                          _InfoRow(label: 'Occasion', value: product.occasion!),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorDisplayWidget(
          message: 'Erreur lors du chargement du produit',
          onRetry: () => ref.invalidate(productByIdProvider(widget.productId)),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _addToCart,
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Ajouter au panier'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  final String label;
  final String notes;
  
  const _NoteRow({
    required this.label,
    required this.notes,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child:                             Text(
                              notes,
                              style: AppTextStyles.description,
                            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  
  const _InfoRow({
    required this.label,
    required this.value,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child:                             Text(
                              value,
                              style: AppTextStyles.description,
                            ),
          ),
        ],
      ),
    );
  }
}
