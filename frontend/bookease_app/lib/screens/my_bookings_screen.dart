import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_card.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  String? _statusFilter;

  static const _filters = [
    (label: 'Tümü', value: null),
    (label: 'Bekleyen', value: 'Pending'),
    (label: 'Onaylı', value: 'Confirmed'),
    (label: 'İptal', value: 'Cancelled'),
  ];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    Future.microtask(() => ref
        .read(bookingListProvider.notifier)
        .fetchMyBookings(status: _statusFilter));
  }

  Future<void> _cancelBooking(String id) async {
    final ok =
        await ref.read(bookingListProvider.notifier).cancelBooking(id);
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rezervasyon iptal edildi')),
      );
      _loadBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsState = ref.watch(bookingListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezervasyonlarım'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: _filters.map((filter) {
                final selected = _statusFilter == filter.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter.label),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _statusFilter = filter.value);
                      _loadBookings();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: bookingsState.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Center(
                  child: Text('Rezervasyonlar yüklenemedi')),
              data: (paged) => paged.items.isEmpty
                  ? const Center(
                      child: Text('Rezervasyon bulunamadı',
                          style: TextStyle(fontSize: 16)))
                  : RefreshIndicator(
                      onRefresh: () async => _loadBookings(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: paged.items.length +
                            (paged.page < paged.totalPages ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == paged.items.length) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: ElevatedButton(
                                onPressed: () => ref
                                    .read(bookingListProvider.notifier)
                                    .loadMore(),
                                child: const Text('Daha fazla yükle'),
                              ),
                            );
                          }
                          final booking = paged.items[index];
                          return BookingCard(
                            booking: booking,
                            onCancel: booking.status == 'Cancelled'
                                ? null
                                : () => _cancelBooking(booking.id),
                          );
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
