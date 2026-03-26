import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/business.dart';
import '../models/service_model.dart';
import '../providers/business_provider.dart';

class BusinessDetailScreen extends ConsumerWidget {
  const BusinessDetailScreen({
    super.key,
    required this.businessId,
  });

  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(businessDetailProvider(businessId));
    final servicesAsync = ref.watch(servicesProvider(businessId));

    return Scaffold(
      appBar: AppBar(
        title: businessAsync.maybeWhen(
          data: (business) => Text(business.name),
          orElse: () => const Text('İşletme Detayı'),
        ),
      ),
      body: businessAsync.when(
        data: (business) => servicesAsync.when(
          data: (services) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _BusinessInfoCard(business: business),
              const SizedBox(height: 16),
              Text(
                'Hizmetler',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(height: 24),
              if (services.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(child: Text('Aktif hizmet bulunmuyor')),
                ),
              for (final service in services)
                _ServiceRow(
                  service: service,
                  onTap: () => context.go(
                    Uri(
                      path: '/services/${service.id}/slots',
                      queryParameters: {'serviceName': service.name},
                    ).toString(),
                  ),
                ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              const Center(child: Text('Hizmetler yüklenemedi')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            const Center(child: Text('İşletme bilgisi yüklenemedi')),
      ),
    );
  }
}

class _BusinessInfoCard extends StatelessWidget {
  const _BusinessInfoCard({required this.business});

  final Business business;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(business.category)),
                if (business.isActive)
                  const Chip(
                    avatar: Icon(Icons.check_circle, size: 18),
                    label: Text('Aktif'),
                  ),
              ],
            ),
            if ((business.description ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(business.description!),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person_outline),
                const SizedBox(width: 8),
                Expanded(child: Text(business.owner.fullName)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.service,
    required this.onTap,
  });

  final ServiceModel service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        title: Text(service.name),
        subtitle: Text('${service.durationMinutes} dk'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('₺${service.price.toStringAsFixed(2)}'),
            Text('Kapasite: ${service.capacity}'),
          ],
        ),
      ),
    );
  }
}
