import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/product_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/empty_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/text_styles.dart';

/// Écran de liste des produits
class ProductsListScreen extends ConsumerStatefulWidget {
  final String? category;
  final String? sort;
  
  const ProductsListScreen({
    super.key,
    this.category,
    this.sort,
  });
  
  @override
  ConsumerState<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends ConsumerState<ProductsListScreen> {
  final _searchController = TextEditingController();
  String? _searchQuery;
  int _page = 0;
  final int _pageSize = 20;
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Map<String, dynamic> _buildFilters() {
    return {
      'page': _page,
      'pageSize': _pageSize,
      'searchQuery': _searchQuery,
      'categoryId': widget.category,
      'sortBy': widget.sort == 'newest' ? 'newest' : widget.sort == 'top' ? 'rating' : null,
    };
  }
  
  @override
  Widget build(BuildContext context) {
    final filters = _buildFilters();
    final productsAsync = ref.watch(productsProvider(filters));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boutique'),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un parfum...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = null;
                            _searchController.clear();
                            _page = 0;
                          });
                        },
                      )
                    : null,
              ),
              onSubmitted: (value) {
                setState(() {
                  _searchQuery = value.isEmpty ? null : value;
                  _page = 0;
                });
              },
            ),
          ),
          
          // Liste des produits
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const EmptyWidget(
                    message: 'Aucun produit trouvé',
                    icon: Icons.search_off,
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _page = 0;
                    });
                    ref.invalidate(productsProvider(filters));
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          context.push('/products/${product.id}');
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingWidget(),
              error: (error, stack) => ErrorDisplayWidget(
                message: 'Erreur lors du chargement des produits',
                onRetry: () => ref.invalidate(productsProvider(filters)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
