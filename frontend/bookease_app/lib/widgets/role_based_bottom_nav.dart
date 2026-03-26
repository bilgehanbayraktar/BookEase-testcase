import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/role_utils.dart';
import '../providers/auth_provider.dart';

class RoleBasedBottomNav extends ConsumerWidget {
  const RoleBasedBottomNav({
    super.key,
    required this.currentPath,
  });

  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).currentUser;
    final role = user?.role;

    final destinations = _destinationsForRole(role);
    final selectedIndex = destinations.indexWhere(
      (item) => currentPath == item.route || currentPath.startsWith('${item.route}/'),
    );

    return NavigationBar(
      selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
      onDestinationSelected: (index) {
        final item = destinations[index];
        context.go(item.route);
      },
      destinations: [
        for (final item in destinations)
          NavigationDestination(icon: Icon(item.icon), label: item.label),
      ],
    );
  }

  List<_NavItem> _destinationsForRole(String? role) {
    switch (role) {
      case businessOwnerRole:
        return const [
          _NavItem(route: '/my-businesses', label: 'Isletmelerim', icon: Icons.storefront),
          _NavItem(route: '/owner-bookings', label: 'Gelen Rezervasyonlar', icon: Icons.event_note),
          _NavItem(route: '/profile', label: 'Profilim', icon: Icons.person),
        ];
      case adminRole:
        return const [
          _NavItem(route: '/admin', label: 'Panel', icon: Icons.dashboard),
          _NavItem(route: '/businesses', label: 'Isletmeler', icon: Icons.store),
          _NavItem(route: '/profile', label: 'Profilim', icon: Icons.person),
        ];
      case customerRole:
      default:
        return const [
          _NavItem(route: '/businesses', label: 'Isletmeler', icon: Icons.store),
          _NavItem(route: '/bookings', label: 'Rezervasyonlarim', icon: Icons.calendar_month),
          _NavItem(route: '/profile', label: 'Profilim', icon: Icons.person),
        ];
    }
  }
}

class _NavItem {
  const _NavItem({
    required this.route,
    required this.label,
    required this.icon,
  });

  final String route;
  final String label;
  final IconData icon;
}
