import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/order_provider.dart';
import '../../../data/repositories/order_repository.dart';
import '../../widgets/loading_widget.dart';

/// Écran de dashboard admin
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(allOrdersProvider(null));
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administration'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
              Tab(icon: Icon(Icons.shopping_bag), text: 'Commandes'),
              Tab(icon: Icon(Icons.inventory), text: 'Produits'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Dashboard
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistiques',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  ordersAsync.when(
                    data: (orders) {
                      final pending = orders.where((o) => o.status == 'pending').length;
                      final shipped = orders.where((o) => o.status == 'shipped').length;
                      final delivered = orders.where((o) => o.status == 'delivered').length;
                      
                      return Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'En attente',
                              value: pending.toString(),
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Expédiées',
                              value: shipped.toString(),
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Livrées',
                              value: delivered.toString(),
                              color: Colors.green,
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const LoadingWidget(),
                    error: (error, stack) => Text('Erreur: ${error.toString()}'),
                  ),
                ],
              ),
            ),
            // Commandes
            ordersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return const Center(child: Text('Aucune commande'));
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text('Commande #${order.id.substring(0, 8)}'),
                        subtitle: Text('${order.items.length} article(s)'),
                        trailing: DropdownButton<String>(
                          value: order.status,
                          items: const [
                            DropdownMenuItem(value: 'pending', child: Text('En attente')),
                            DropdownMenuItem(value: 'paid', child: Text('Payée')),
                            DropdownMenuItem(value: 'shipped', child: Text('Expédiée')),
                            DropdownMenuItem(value: 'delivered', child: Text('Livrée')),
                            DropdownMenuItem(value: 'cancelled', child: Text('Annulée')),
                          ],
                          onChanged: (value) async {
                            if (value != null) {
                              final orderRepo = ref.read(orderRepositoryProvider);
                              await orderRepo.updateOrderStatus(
                                orderId: order.id,
                                status: value,
                              );
                              ref.invalidate(allOrdersProvider(null));
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingWidget(),
              error: (error, stack) => Center(
                child: Text('Erreur: ${error.toString()}'),
              ),
            ),
            // Produits
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Gestion des produits'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      context.push('/admin/products');
                    },
                    child: const Text('Gérer les produits'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  
  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
