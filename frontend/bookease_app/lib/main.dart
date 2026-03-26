import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/slot.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/business_list_screen.dart';
import 'screens/business_detail_screen.dart';
import 'screens/slot_list_screen.dart';
import 'screens/create_booking_screen.dart';
import 'screens/my_bookings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  runApp(const ProviderScope(child: BookEaseApp()));
}

final _router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    // Redirect logic is handled inside the router via refreshListenable.
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(
        path: '/businesses', builder: (_, __) => const BusinessListScreen()),
    GoRoute(
      path: '/businesses/:id',
      builder: (_, state) =>
          BusinessDetailScreen(businessId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/services/:serviceId/slots',
      builder: (_, state) => SlotListScreen(
        serviceId: state.pathParameters['serviceId']!,
        serviceName: state.extra as String?,
      ),
    ),
    GoRoute(
      path: '/bookings/create',
      builder: (_, state) => CreateBookingScreen(slot: state.extra as Slot),
    ),
    GoRoute(path: '/bookings', builder: (_, __) => const MyBookingsScreen()),
  ],
);

class BookEaseApp extends ConsumerWidget {
  const BookEaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'BookEase',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      routerConfig: _router,
    );
  }
}
