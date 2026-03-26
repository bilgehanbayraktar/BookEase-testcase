import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/role_utils.dart';
import '../providers/auth_provider.dart';
import '../widgets/role_based_bottom_nav.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profilim')),
      body: user == null
          ? const Center(child: Text('Kullanici bilgisi bulunamadi'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.fullName, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Text('E-posta: ${user.email}'),
                        const SizedBox(height: 8),
                        Text('Rol: ${roleLabelTr(user.role)}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  child: const Text('Cikis Yap'),
                ),
              ],
            ),
      bottomNavigationBar: const RoleBasedBottomNav(currentPath: '/profile'),
    );
  }
}
