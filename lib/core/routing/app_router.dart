import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/products/products_list_screen.dart';
import '../../presentation/screens/products/product_detail_screen.dart';
import '../../presentation/screens/cart/cart_screen.dart';
import '../../presentation/screens/checkout/checkout_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/orders/orders_screen.dart';
import '../../presentation/screens/favorites/favorites_screen.dart';
import '../../presentation/screens/admin/admin_dashboard_screen.dart';
import '../../presentation/screens/addresses/addresses_screen.dart';
import '../../presentation/screens/addresses/add_edit_address_screen.dart';
import '../../presentation/providers/auth_provider.dart';

/// Configuration du routing
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(currentUserProvider);
  final isAdmin = ref.watch(isAdminProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAdminRoute = state.matchedLocation.startsWith('/admin');
      final isAuthRoute = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/signup';
      
      // Rediriger vers login si accès à une route protégée
      if (!isLoggedIn && !isAuthRoute && 
          (state.matchedLocation.startsWith('/cart') ||
           state.matchedLocation.startsWith('/checkout') ||
           state.matchedLocation.startsWith('/profile') ||
           state.matchedLocation.startsWith('/orders') ||
           state.matchedLocation.startsWith('/favorites'))) {
        return '/login';
      }
      
      // Rediriger si admin essaie d'accéder à une route admin sans être admin
      if (isAdminRoute && (!isLoggedIn || !isAdmin)) {
        return '/';
      }
      
      // Rediriger vers home si déjà connecté et sur login/signup
      if (isLoggedIn && isAuthRoute) {
        return '/';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) {
          final category = state.uri.queryParameters['category'];
          final sort = state.uri.queryParameters['sort'];
          return ProductsListScreen(
            category: category,
            sort: sort,
          );
        },
      ),
      GoRoute(
        path: '/products/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id']!;
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/addresses',
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: '/addresses/add',
        builder: (context, state) => const AddEditAddressScreen(),
      ),
      GoRoute(
        path: '/addresses/:id/edit',
        builder: (context, state) {
          final addressId = state.pathParameters['id']!;
          return AddEditAddressScreen(addressId: addressId);
        },
      ),
    ],
  );
});
