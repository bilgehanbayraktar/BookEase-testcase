import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/api_client.dart';
import '../providers/admin_provider.dart';
import '../widgets/role_based_bottom_nav.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  Future<void> _showCreateUserDialog(BuildContext context, WidgetRef ref) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final fullNameController = TextEditingController();
    String selectedRole = 'business_owner';
    String? errorMessage;
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Kullanici Olustur'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: fullNameController,
                      decoration: const InputDecoration(labelText: 'Ad Soyad'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'E-posta'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Sifre'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: const [
                        DropdownMenuItem(
                          value: 'customer',
                          child: Text('Musteri'),
                        ),
                        DropdownMenuItem(
                          value: 'business_owner',
                          child: Text('Isletme Sahibi'),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text('Admin'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => selectedRole = value);
                        }
                      },
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Iptal'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setState(() {
                            isSaving = true;
                            errorMessage = null;
                          });
                          try {
                            if (selectedRole == 'admin') {
                              await ref.read(adminActionsProvider).createAdmin(
                                    email: emailController.text.trim(),
                                    password: passwordController.text,
                                    fullName: fullNameController.text.trim(),
                                  );
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Admin olusturuldu')),
                                );
                              }
                            } else {
                              final user = await ref.read(adminActionsProvider).createUser(
                                    email: emailController.text.trim(),
                                    password: passwordController.text,
                                    fullName: fullNameController.text.trim(),
                                    role: selectedRole,
                                  );
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Kullanici olusturuldu. ID: ${user.user.id}',
                                    ),
                                    duration: const Duration(seconds: 6),
                                  ),
                                );
                              }
                            }
                          } catch (error) {
                            setState(() => errorMessage = extractApiError(error));
                          } finally {
                            if (context.mounted) {
                              setState(() => isSaving = false);
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Olustur'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showCreateAdminDialog(BuildContext context, WidgetRef ref) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final fullNameController = TextEditingController();
    String? errorMessage;
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Admin Olustur'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: fullNameController,
                      decoration: const InputDecoration(labelText: 'Ad Soyad'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'E-posta'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Sifre'),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Iptal'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setState(() {
                            isSaving = true;
                            errorMessage = null;
                          });
                          try {
                            await ref.read(adminActionsProvider).createAdmin(
                                  email: emailController.text.trim(),
                                  password: passwordController.text,
                                  fullName: fullNameController.text.trim(),
                                );
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Admin olusturuldu')),
                              );
                            }
                          } catch (error) {
                            setState(() => errorMessage = extractApiError(error));
                          } finally {
                            if (context.mounted) {
                              setState(() => isSaving = false);
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Olustur'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Paneli')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/businesses'),
                    child: const Text('Tum Isletmeler'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.go('/admin/businesses'),
                    child: const Text('Isletmeleri Yonet'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _showCreateUserDialog(context, ref),
                    child: const Text('Kullanici Olustur'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _showCreateAdminDialog(context, ref),
                    child: const Text('Admin Olustur'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const RoleBasedBottomNav(currentPath: '/admin'),
    );
  }
}
