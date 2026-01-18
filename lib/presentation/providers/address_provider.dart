import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/address_repository.dart';
import '../../data/models/address_model.dart';
import 'auth_provider.dart';

/// Provider du repository d'adresses
final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepository();
});

/// Provider des adresses de l'utilisateur
final userAddressesProvider = FutureProvider<List<AddressModel>>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  
  if (user == null) return [];
  
  final repo = ref.read(addressRepositoryProvider);
  return await repo.getUserAddresses(user.id);
});

/// Provider de l'adresse par défaut
final defaultAddressProvider = FutureProvider<AddressModel?>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.value;
  
  if (user == null) return null;
  
  final repo = ref.read(addressRepositoryProvider);
  return await repo.getDefaultAddress(user.id);
});
