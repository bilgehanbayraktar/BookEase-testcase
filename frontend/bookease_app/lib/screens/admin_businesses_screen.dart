import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/api_client.dart';
import '../providers/admin_provider.dart';
import '../providers/business_provider.dart';
import '../widgets/business_card.dart';
import '../widgets/role_based_bottom_nav.dart';

class AdminBusinessesScreen extends ConsumerWidget {
  const AdminBusinessesScreen({super.key});

  Future<void> _showCreateBusinessDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final ownerIdController = TextEditingController();
    final descriptionController = TextEditingController();
    String? errorMessage;
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Isletme Olustur'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Isletme Adi'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: ownerIdController,
                      decoration: const InputDecoration(
                        labelText: 'BusinessOwner ID',
                        hintText: 'Olusturulan owner kullanicisinin ID degeri',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Aciklama'),
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
                            await ref.read(adminActionsProvider).createBusiness(
                                  name: nameController.text.trim(),
                                  category: categoryController.text.trim(),
                                  ownerId: ownerIdController.text.trim(),
                                  description: descriptionController.text.trim(),
                                );
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Isletme olusturuldu')),
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
    final businessesAsync = ref.watch(businessListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tum Isletmeleri Yonet')),
      body: businessesAsync.when(
        data: (businesses) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(businessListProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              final business = businesses[index];
              return BusinessCard(
                business: business,
                onTap: () => context.go('/admin/businesses/${business.id}/manage'),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(extractApiError(error))),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBusinessDialog(context, ref),
        icon: const Icon(Icons.add_business),
        label: const Text('Isletme Olustur'),
      ),
      bottomNavigationBar: const RoleBasedBottomNav(currentPath: '/admin/businesses'),
    );
  }
}
