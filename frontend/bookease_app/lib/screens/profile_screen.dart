import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.read(storageServiceProvider);

    return FutureBuilder<Map<String, dynamic>?> (
      future: storage.getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Kullanıcı bilgileri yüklenemedi.'));
        }

        final user = snapshot.data!;
        final role = user['role'] == 'Customer'
            ? 'Müşteri'
            : user['role'] == 'BusinessOwner'
                ? 'İşletme Sahibi'
                : 'Admin';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profilim'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ad Soyad: ${user['fullName']}',
                    style: Theme.of(context).textTheme.headline6),
                const SizedBox(height: 8),
                Text('E-posta: ${user['email']}',
                    style: Theme.of(context).textTheme.bodyText1),
                const SizedBox(height: 8),
                Text('Rol: $role',
                    style: Theme.of(context).textTheme.bodyText1),
                const Spacer(),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await storage.clearTokens();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                    child: const Text('Çıkış Yap'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}