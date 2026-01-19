import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/repositories/cart_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_widget.dart';

/// Écran de checkout
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String? _selectedAddressId;
  String _deliveryMode = AppConstants.deliveryModeStandard;
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  
  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
  
  Future<void> _placeOrder() async {
    final userAsync = ref.read(currentUserProvider);
    final user = userAsync.value;
    final cartAsync = ref.read(cartProvider);
    final cart = cartAsync.value;
    
    if (user == null || cart == null || cart.isEmpty) {
      return;
    }
    
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une adresse')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final orderRepo = ref.read(orderRepositoryProvider);
      
      // Préparer les items de commande
      final items = cart.items.map((item) {
        return {
          'variant_id': item.variantId,
          'quantity': item.quantity,
          'unit_price': item.unitPrice ?? 0,
        };
      }).toList();
      
      await orderRepo.createOrder(
        userId: user.id,
        addressId: _selectedAddressId,
        deliveryMode: _deliveryMode,
        total: cart.totalPrice,
        items: items,
      );
      
      // Vider le panier
      final cartRepo = ref.read(cartRepositoryProvider);
      await cartRepo.clearCart(cart.id);
      
      if (!mounted) return;
      
      ref.invalidate(cartProvider);
      ref.invalidate(userOrdersProvider);
      if (mounted) {
        context.go('/orders');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commande passée avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);
    final addressesAsync = ref.watch(userAddressesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commande'),
      ),
      body: cartAsync.when(
        data: (cart) {
          if (cart == null || cart.isEmpty) {
            return const EmptyWidget(
              message: 'Votre panier est vide',
              icon: Icons.shopping_cart_outlined,
            );
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Adresse
                Text(
                  'Adresse de livraison',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 12),
                addressesAsync.when(
                  data: (addresses) {
                    if (addresses.isEmpty) {
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.add_location),
                          title: const Text('Ajouter une adresse'),
                          onTap: () {
                            context.push('/addresses/add');
                          },
                        ),
                      );
                    }
                    
                    return Column(
                    children: addresses.map((address) {
                      return Card(
                        child: RadioListTile<String>(
                          value: address.id,
                          groupValue: _selectedAddressId,
                          onChanged: (value) {
                            setState(() {
                              _selectedAddressId = value;
                            });
                          },
                            title: Text(address.fullAddress),
                            subtitle: address.isDefault
                                ? const Text('Adresse par défaut')
                                : null,
                            secondary: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                context.push('/addresses/${address.id}/edit');
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const LoadingWidget(),
                  error: (error, stack) => Text('Erreur: ${error.toString()}'),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    context.push('/addresses/add');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une nouvelle adresse'),
                ),
                const SizedBox(height: 24),
                
                // Mode de livraison
                Text(
                  'Mode de livraison',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        value: AppConstants.deliveryModeStandard,
                        groupValue: _deliveryMode,
                        onChanged: (value) {
                          setState(() {
                            _deliveryMode = value!;
                          });
                        },
                        title: const Text('Livraison standard'),
                        subtitle: Text(
                          PriceFormatter.format(AppConstants.standardShippingFee),
                        ),
                      ),
                      RadioListTile<String>(
                        value: AppConstants.deliveryModeExpress,
                        groupValue: _deliveryMode,
                        onChanged: (value) {
                          setState(() {
                            _deliveryMode = value!;
                          });
                        },
                        title: const Text('Livraison express'),
                        subtitle: Text(
                          PriceFormatter.format(AppConstants.expressShippingFee),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Téléphone
                Text(
                  'Téléphone',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Numéro de téléphone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Résumé
                Text(
                  'Résumé',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                              PriceFormatter.format(
                                _deliveryMode == AppConstants.deliveryModeExpress
                                    ? AppConstants.expressShippingFee
                                    : AppConstants.standardShippingFee,
                              ),
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
                                cart.totalPrice +
                                    (_deliveryMode == AppConstants.deliveryModeExpress
                                        ? AppConstants.expressShippingFee
                                        : AppConstants.standardShippingFee),
                              ),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Bouton de commande
                FilledButton(
                  onPressed: _isLoading ? null : _placeOrder,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.backgroundPrimary,
                          ),
                        )
                      : Text(
                          'CONFIRMER LA COMMANDE',
                          style: AppTextStyles.button,
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ),
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
