import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/business_provider.dart';
import '../widgets/business_card.dart';

class BusinessListScreen extends ConsumerStatefulWidget {
  const BusinessListScreen({super.key});

  @override
  ConsumerState<BusinessListScreen> createState() =>
      _BusinessListScreenState();
}

class _BusinessListScreenState extends ConsumerState<BusinessListScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(businessProvider.notifier).fetchBusinesses());
  }

  @override
  Widget build(BuildContext context) {
    final businessState = ref.watch(businessProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İşletmeler'),
        centerTitle: true,
      ),
      body: businessState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              const Text('Veriler yüklenemedi'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.read(businessProvider.notifier).fetchBusinesses(),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
        data: (businesses) => RefreshIndicator(
          onRefresh: () =>
              ref.read(businessProvider.notifier).fetchBusinesses(),
          child: businesses.isEmpty
              ? const Center(child: Text('Henüz işletme bulunmuyor'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: businesses.length,
                  itemBuilder: (context, index) => BusinessCard(
                    business: businesses[index],
                    onTap: () =>
                        context.go('/businesses/${businesses[index].id}'),
                  ),
                ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (index) {
          setState(() => _navIndex = index);
          if (index == 1) {
            context.go('/bookings');
          } else if (index == 2) {
            ref.read(authProvider.notifier).logout();
            context.go('/login');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.store), label: 'İşletmeler'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month), label: 'Rezervasyonlarım'),
          NavigationDestination(icon: Icon(Icons.logout), label: 'Çıkış'),
        ],
      ),
    );
  }
}
