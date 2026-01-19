import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';
import '../../widgets/loading_widget.dart';

/// Écran de profil
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final isAdmin = ref.watch(isAdminProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Vous n\'êtes pas connecté'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.push('/login'),
                    child: const Text('Se connecter'),
                  ),
                ],
              ),
            );
          }
          
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Informations utilisateur
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            child: Text(
                              user.fullName?.isNotEmpty == true
                                  ? user.fullName![0].toUpperCase()
                                  : user.id[0].toUpperCase(),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child:                               Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName ?? 'Utilisateur',
                                    style: AppTextStyles.productTitle.copyWith(fontSize: 18),
                                  ),
                                  if (user.phone != null)
                                    Text(
                                      user.phone!,
                                      style: AppTextStyles.description,
                                    ),
                                ],
                              ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Menu
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.shopping_bag_outlined),
                      title: const Text('Mes commandes'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/orders'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.favorite_outline),
                      title: const Text('Mes favoris'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/favorites'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: const Text('Mes adresses'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/addresses'),
                    ),
                    if (isAdmin) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.admin_panel_settings),
                        title: const Text('Administration'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/admin'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Déconnexion
              FilledButton.icon(
                onPressed: () async {
                  final repo = ref.read(authRepositoryProvider);
                  await repo.signOut();
                  if (context.mounted) {
                    context.go('/');
                  }
                },
                icon: const Icon(Icons.logout),
                label: Text(
                  'DÉCONNEXION',
                  style: AppTextStyles.button,
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
