import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/address_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/error_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';

/// Écran de gestion des adresses
class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(userAddressesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes adresses'),
      ),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return const EmptyWidget(
              message: 'Aucune adresse enregistrée',
              icon: Icons.location_on_outlined,
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userAddressesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Icon(
                      address.isDefault
                          ? Icons.home
                          : Icons.location_on_outlined,
                    ),
                    title: Text(address.fullAddress),
                    subtitle: address.isDefault
                        ? const Text('Adresse par défaut')
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: AppColors.goldPrimary,
                                  ),
                                  onPressed: () {
                                    context.push('/addresses/${address.id}/edit');
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: AppColors.error,
                                  onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Supprimer l\'adresse'),
                                content: const Text(
                                  'Êtes-vous sûr de vouloir supprimer cette adresse ?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Annuler'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirmed == true) {
                              final repo = ref.read(addressRepositoryProvider);
                              await repo.deleteAddress(address.id);
                              ref.invalidate(userAddressesProvider);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorDisplayWidget(
          message: 'Erreur lors du chargement des adresses',
          onRetry: () => ref.invalidate(userAddressesProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/addresses/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
