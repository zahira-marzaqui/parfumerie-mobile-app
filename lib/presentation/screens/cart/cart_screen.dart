import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_widget.dart';

/// Écran du panier
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panier'),
      ),
      body: cartAsync.when(
        data: (cart) {
          if (cart == null || cart.isEmpty) {
            return const EmptyWidget(
              message: 'Votre panier est vide',
              icon: Icons.shopping_cart_outlined,
            );
          }
          
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    final product = item.product;
                    final variant = item.variant;
                    
                    if (product == null || variant == null) {
                      return const SizedBox.shrink();
                    }
                    
                    final coverImage = product.coverImage;
                    final imageUrl = coverImage?.imageUrl;
                    final unitPrice = item.unitPrice ?? 0;
                    final totalPrice = item.totalPrice ?? 0;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: imageUrl != null && imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image_not_supported),
                              ),
                        title: Text(product.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${variant.volumeMl}ml'),
                            Text(
                              PriceFormatter.format(unitPrice),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () async {
                                    final cartRepo = ref.read(cartRepositoryProvider);
                                    await cartRepo.updateCartItemQuantity(
                                      itemId: item.id,
                                      quantity: item.quantity - 1,
                                    );
                                    ref.invalidate(cartProvider);
                                  },
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () async {
                                    final cartRepo = ref.read(cartRepositoryProvider);
                                    await cartRepo.updateCartItemQuantity(
                                      itemId: item.id,
                                      quantity: item.quantity + 1,
                                    );
                                    ref.invalidate(cartProvider);
                                  },
                                ),
                              ],
                            ),
                            Text(
                              PriceFormatter.format(totalPrice),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              onPressed: () async {
                                final cartRepo = ref.read(cartRepositoryProvider);
                                await cartRepo.removeFromCart(item.id);
                                ref.invalidate(cartProvider);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sous-total',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          PriceFormatter.format(cart.totalPrice),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Frais de livraison',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text(
                          PriceFormatter.format(AppConstants.standardShippingFee),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          PriceFormatter.format(
                            cart.totalPrice + AppConstants.standardShippingFee,
                          ),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: cart.allItemsInStock
                          ? () => context.push('/checkout')
                          : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 0),
                      ),
                      child: const Text('Passer la commande'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => Center(
          child: Text('Erreur: ${error.toString()}'),
        ),
      ),
    );
  }
}
