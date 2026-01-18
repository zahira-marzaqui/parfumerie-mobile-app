import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/services/supabase_service.dart';

/// Provider du repository d'authentification
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider de l'utilisateur actuel
final currentUserProvider = StreamProvider<UserProfileModel?>((ref) async* {
  final authState = SupabaseService.client.auth.onAuthStateChange;
  
  await for (final state in authState) {
    if (state.session?.user != null) {
      final repo = ref.read(authRepositoryProvider);
      final profile = await repo.getCurrentUserProfile();
      yield profile;
    } else {
      yield null;
    }
  }
});

/// Provider pour vérifier si l'utilisateur est admin
final isAdminProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) => user?.isAdmin ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});
