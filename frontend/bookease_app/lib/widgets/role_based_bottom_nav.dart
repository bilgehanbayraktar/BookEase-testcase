import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleBasedBottomNav extends StatelessWidget {
  final String role;
  final int currentIndex;
  final Function(int) onTap;

  const RoleBasedBottomNav({
    Key? key,
    required this.role,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> items = [];

    if (role == 'Customer') {
      items = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'İşletmeler',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Rezervasyonlarım',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profilim',
        ),
      ];
    } else if (role == 'BusinessOwner') {
      items = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'İşletmelerim',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Gelen Rezervasyonlar',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profilim',
        ),
      ];
    } else if (role == 'Admin') {
      items = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Panel',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.store),
          label: 'İşletmeler',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profilim',
        ),
      ];
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
    );
  }
}