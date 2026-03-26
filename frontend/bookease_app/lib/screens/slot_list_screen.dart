import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/slot_provider.dart';
import '../widgets/slot_tile.dart';

class SlotListScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final String? serviceName;

  const SlotListScreen(
      {super.key, required this.serviceId, this.serviceName});

  @override
  ConsumerState<SlotListScreen> createState() => _SlotListScreenState();
}

class _SlotListScreenState extends ConsumerState<SlotListScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
  }

  String get _dateParam => DateFormat('yyyy-MM-dd').format(_selectedDate);

  String _formatDisplayDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'tr_TR').format(date);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final slotsAsync = ref.watch(
      slotProvider(SlotParams(serviceId: widget.serviceId, date: _dateParam)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceName ?? 'Slotlar'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _selectedDate =
                      _selectedDate.subtract(const Duration(days: 1))),
                ),
                TextButton(
                  onPressed: _pickDate,
                  child: Text(
                    _formatDisplayDate(_selectedDate),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() =>
                      _selectedDate = _selectedDate.add(const Duration(days: 1))),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: slotsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Center(child: Text('Slotlar yüklenemedi')),
              data: (slots) => slots.isEmpty
                  ? const Center(
                      child: Text('Bu tarihte slot bulunmuyor',
                          style: TextStyle(fontSize: 16)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: slots.length,
                      itemBuilder: (context, i) => SlotTile(
                        slot: slots[i],
                        onTap: slots[i].isAvailable
                            ? () => context.go(
                                  '/bookings/create',
                                  extra: slots[i],
                                )
                            : null,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
