import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/models/order_model.dart';
import 'auth_provider.dart';

/// Provider du repository de commandes
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

/// Provider des commandes de l'utilisateur
final userOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  
  if (user == null) return [];
  
  final repo = ref.read(orderRepositoryProvider);
  return await repo.getUserOrders(user.id);
});

/// Provider de toutes les commandes (Admin)
final allOrdersProvider = FutureProvider.family<List<OrderModel>, String?>((ref, status) async {
  final repo = ref.read(orderRepositoryProvider);
  return await repo.getAllOrders(status: status);
});
