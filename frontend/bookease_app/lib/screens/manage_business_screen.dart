import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/api_client.dart';
import '../models/business.dart';
import '../models/service_model.dart';
import '../providers/business_provider.dart';
import '../providers/owner_provider.dart';
import '../widgets/role_based_bottom_nav.dart';

class ManageBusinessScreen extends ConsumerWidget {
  const ManageBusinessScreen({
    super.key,
    required this.businessId,
    this.bookingsRoute,
    this.bottomNavPath = '/my-businesses',
    this.showBottomNav = true,
  });

  final String businessId;
  final String? bookingsRoute;
  final String bottomNavPath;
  final bool showBottomNav;

  Future<void> _showAddServiceDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final durationController = TextEditingController();
    final priceController = TextEditingController();
    final capacityController = TextEditingController();
    String? errorMessage;
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Hizmet Ekle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Hizmet Adi'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Sure (dk)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Fiyat'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: capacityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Kapasite'),
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
                            await ref.read(ownerActionsProvider).createService(
                                  businessId: businessId,
                                  name: nameController.text.trim(),
                                  durationMinutes: int.parse(durationController.text),
                                  price: double.parse(priceController.text),
                                  capacity: int.parse(capacityController.text),
                                );
                            if (context.mounted) {
                              Navigator.of(context).pop();
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
                      : const Text('Ekle'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showCreateSlotDialog(
    BuildContext context,
    WidgetRef ref,
    ServiceModel service,
  ) async {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);
    String? errorMessage;
    bool isSaving = false;

    DateTime combine(TimeOfDay time) {
      return DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        time.hour,
        time.minute,
      );
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Slot Olustur', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Tarih'),
                    subtitle: Text(
                      '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Baslangic'),
                    subtitle: Text(startTime.format(context)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: startTime,
                      );
                      if (picked != null) {
                        setState(() => startTime = picked);
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Bitis'),
                    subtitle: Text(endTime.format(context)),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: endTime,
                      );
                      if (picked != null) {
                        setState(() => endTime = picked);
                      }
                    },
                  ),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            setState(() {
                              isSaving = true;
                              errorMessage = null;
                            });
                            try {
                              await ref.read(ownerActionsProvider).createSlot(
                                    serviceId: service.id,
                                    startTime: combine(startTime),
                                    endTime: combine(endTime),
                                  );
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Slot olusturuldu')),
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
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(businessDetailProvider(businessId));
    final servicesAsync = ref.watch(servicesProvider(businessId));

    return Scaffold(
      appBar: AppBar(title: const Text('Isletme Yonetimi')),
      body: businessAsync.when(
        data: (business) => servicesAsync.when(
          data: (services) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ManageBusinessHeader(
                business: business,
                onViewBookings: () => context.go(
                  bookingsRoute ?? '/my-businesses/$businessId/bookings',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hizmetler',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddServiceDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Ekle'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (services.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Text('Henuz hizmet eklenmedi'),
                )),
              for (final service in services)
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service.name, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('${service.durationMinutes} dk • ₺${service.price.toStringAsFixed(2)}'),
                        Text('Kapasite: ${service.capacity}'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () => _showCreateSlotDialog(context, ref, service),
                              child: const Text('Slot Olustur'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () async {
                                try {
                                  await ref.read(ownerActionsProvider).deleteService(
                                        businessId: businessId,
                                        serviceId: service.id,
                                      );
                                } catch (error) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(extractApiError(error))),
                                    );
                                  }
                                }
                              },
                              child: const Text('Sil'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text(extractApiError(error))),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(extractApiError(error))),
      ),
      bottomNavigationBar:
          showBottomNav ? RoleBasedBottomNav(currentPath: bottomNavPath) : null,
    );
  }
}

class _ManageBusinessHeader extends StatelessWidget {
  const _ManageBusinessHeader({
    required this.business,
    required this.onViewBookings,
  });

  final Business business;
  final VoidCallback onViewBookings;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(business.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Kategori: ${business.category}'),
            if ((business.description ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(business.description!),
            ],
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onViewBookings,
              child: const Text('Gelen Rezervasyonlar'),
            ),
          ],
        ),
      ),
    );
  }
}
