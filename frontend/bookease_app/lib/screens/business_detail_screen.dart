import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/business_provider.dart';

class BusinessDetailScreen extends ConsumerWidget {
  final String businessId;

  const BusinessDetailScreen({super.key, required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(businessDetailProvider(businessId));
    final servicesAsync = ref.watch(servicesProvider(businessId));

    return Scaffold(
      appBar: AppBar(
        title: businessAsync.maybeWhen(
          data: (b) => Text(b.name),
          orElse: () => const Text('İşletme Detayı'),
        ),
        centerTitle: true,
      ),
      body: businessAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('İşletme yüklenemedi')),
        data: (business) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text(business.category),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ],
                    ),
                    if (business.description != null &&
                        business.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(business.description!),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          business.owner.fullName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Hizmetler',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            servicesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  const Text('Hizmetler yüklenemedi'),
              data: (services) => services.isEmpty
                  ? const Text('Bu işletmede henüz hizmet bulunmuyor')
                  : Column(
                      children: services
                          .map(
                            (svc) => ListTile(
                              onTap: () => context.go(
                                '/services/${svc.id}/slots',
                                extra: svc.name,
                              ),
                              title: Text(svc.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                  '${svc.durationMinutes} dk  •  Kapasite: ${svc.capacity}'),
                              trailing: Text(
                                '₺${svc.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
