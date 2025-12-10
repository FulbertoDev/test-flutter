import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/live/live_event_screen.dart';
import '../screens/product/product_detail_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            NoTransitionPage(key: state.pageKey, child: const HomeScreen()),
      ),

      GoRoute(
        path: '/live/:eventId',
        pageBuilder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return NoTransitionPage(
            key: state.pageKey,
            child: LiveEventScreen(eventId: eventId),
          );
        },
      ),
      GoRoute(
        path: '/product/:productId',
        pageBuilder: (context, state) {
          final productId = state.pathParameters['productId']!;
          return NoTransitionPage(
            key: state.pageKey,
            child: ProductDetailScreen(productId: productId),
          );
        },
      ),
      GoRoute(
        path: '/checkout',
        pageBuilder: (context, state) =>
            NoTransitionPage(key: state.pageKey, child: const CheckoutScreen()),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) =>
            NoTransitionPage(key: state.pageKey, child: const ProfileScreen()),
      ),
    ],
    errorBuilder: (context, state) => const HomeScreen(),
  );
}
