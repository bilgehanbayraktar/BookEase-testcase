import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/slot_provider.dart';
import '../widgets/slot_tile.dart';

class SlotListScreen extends ConsumerStatefulWidget {
  const SlotListScreen({
    super.key,
    required this.serviceId,
    this.serviceName,
  });

  final String serviceId;
  final String? serviceName;

  @override
  ConsumerState<SlotListScreen> createState() => _SlotListScreenState();
}

class _SlotListScreenState extends ConsumerState<SlotListScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _selectedDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      locale: const Locale('tr', 'TR'),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = SlotQuery(serviceId: widget.serviceId, date: _selectedDate);
    final slotsAsync = ref.watch(slotsProvider(query));

    return Scaffold(
      appBar: AppBar(title: Text(widget.serviceName ?? 'Slotlar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.subtract(const Duration(days: 1));
                    });
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '< ${DateFormat('d MMMM yyyy', 'tr_TR').format(_selectedDate)} >',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.add(const Duration(days: 1));
                    });
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: slotsAsync.when(
              data: (slots) {
                if (slots.isEmpty) {
                  return const Center(child: Text('Bu tarihte slot bulunmuyor'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    return SlotTile(
                      slot: slot,
                      onTap: slot.isAvailable
                          ? () {
                              ref.read(selectedSlotProvider.notifier).state = slot;
                              context.go('/bookings/create?slotId=${slot.id}');
                            }
                          : null,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  const Center(child: Text('Slotlar yüklenemedi')),
            ),
          ),
        ],
      ),
    );
  }
}
