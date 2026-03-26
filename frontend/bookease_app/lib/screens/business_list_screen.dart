import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/business_provider.dart';
import '../widgets/business_card.dart';
import '../widgets/role_based_bottom_nav.dart';

class BusinessListScreen extends ConsumerWidget {
  const BusinessListScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(businessListProvider);
    await ref.read(businessListProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('İşletmeler')),
      body: businessesAsync.when(
        data: (businesses) => RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: businesses.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 240),
                    Center(child: Text('İşletme bulunamadı')),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: businesses.length,
                  itemBuilder: (context, index) {
                    final business = businesses[index];
                    return BusinessCard(
                      business: business,
                      onTap: () => context.go('/businesses/${business.id}'),
                    );
                  },
                ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('İşletmeler yüklenemedi'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(businessListProvider),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const RoleBasedBottomNav(currentPath: '/businesses'),
    );
  }
}
