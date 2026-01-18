import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../../core/utils/price_formatter.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/error_widget.dart';

/// Écran des commandes
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(userOrdersProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes commandes'),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyWidget(
              message: 'Aucune commande',
              icon: Icons.shopping_bag_outlined,
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userOrdersProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      context.push('/orders/${order.id}');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Commande #${order.id.substring(0, 8)}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(order.status),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  order.statusLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (order.createdAt != null)
                            Text(
                              dateFormat.format(order.createdAt!),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          const SizedBox(height: 8),
                          Text(
                            '${order.items.length} article(s)',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                PriceFormatter.format(order.totalWithShipping),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => ErrorDisplayWidget(
          message: 'Erreur lors du chargement des commandes',
          onRetry: () => ref.invalidate(userOrdersProvider),
        ),
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
