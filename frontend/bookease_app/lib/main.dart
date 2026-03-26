import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/api_client.dart';
import 'core/role_utils.dart';
import 'providers/auth_provider.dart';
import 'screens/admin_businesses_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/business_bookings_screen.dart';
import 'screens/business_detail_screen.dart';
import 'screens/business_list_screen.dart';
import 'screens/create_booking_screen.dart';
import 'screens/login_screen.dart';
import 'screens/manage_business_screen.dart';
import 'screens/my_businesses_screen.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/owner_bookings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/slot_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR');
  runApp(const ProviderScope(child: BookEaseApp()));
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final sessionManager = ref.watch(sessionManagerProvider);

  return GoRouter(
    initialLocation: '/businesses',
    refreshListenable: sessionManager,
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthRoute = path == '/login' || path == '/register';

      if (!sessionManager.isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (sessionManager.isLoggedIn && isAuthRoute) {
        return homeRouteForRole(sessionManager.currentUser?.role);
      }

      if (sessionManager.isLoggedIn &&
          !canAccessRouteForRole(sessionManager.currentUser?.role, path)) {
        return homeRouteForRole(sessionManager.currentUser?.role);
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/businesses',
        builder: (context, state) => const BusinessListScreen(),
      ),
      GoRoute(
        path: '/businesses/:id',
        builder: (context, state) => BusinessDetailScreen(
          businessId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/services/:serviceId/slots',
        builder: (context, state) => SlotListScreen(
          serviceId: state.pathParameters['serviceId']!,
          serviceName: state.uri.queryParameters['serviceName'],
        ),
      ),
      GoRoute(
        path: '/bookings/create',
        builder: (context, state) => CreateBookingScreen(
          slotId: state.uri.queryParameters['slotId'],
        ),
      ),
      GoRoute(
        path: '/bookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/my-businesses',
        builder: (context, state) => const MyBusinessesScreen(),
      ),
      GoRoute(
        path: '/my-businesses/:id',
        builder: (context, state) => ManageBusinessScreen(
          businessId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/my-businesses/:id/bookings',
        builder: (context, state) => BusinessBookingsScreen(
          businessId: state.pathParameters['id']!,
          showBottomNav: false,
        ),
      ),
      GoRoute(
        path: '/owner-bookings',
        builder: (context, state) => const OwnerBookingsScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminHomeScreen(),
      ),
      GoRoute(
        path: '/admin/businesses',
        builder: (context, state) => const AdminBusinessesScreen(),
      ),
      GoRoute(
        path: '/admin/businesses/:id/manage',
        builder: (context, state) => ManageBusinessScreen(
          businessId: state.pathParameters['id']!,
          bookingsRoute: '/admin/businesses/${state.pathParameters['id']!}/bookings',
          bottomNavPath: '/admin/businesses',
        ),
      ),
      GoRoute(
        path: '/admin/businesses/:id/bookings',
        builder: (context, state) => BusinessBookingsScreen(
          businessId: state.pathParameters['id']!,
          showBottomNav: false,
        ),
      ),
    ],
  );
});

class BookEaseApp extends ConsumerStatefulWidget {
  const BookEaseApp({super.key});

  @override
  ConsumerState<BookEaseApp> createState() => _BookEaseAppState();
}

class _BookEaseAppState extends ConsumerState<BookEaseApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authProvider.notifier).checkAuth());
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'BookEase',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      routerConfig: router,
    );
  }
}
