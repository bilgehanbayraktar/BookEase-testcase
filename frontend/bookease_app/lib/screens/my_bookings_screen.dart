import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/booking_provider.dart';
import '../widgets/booking_card.dart';
import '../widgets/role_based_bottom_nav.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(bookingProvider.notifier).fetchMyBookings();
    });
  }

  Future<void> _load(String? status) async {
    _selectedStatus = status;
    await ref.read(bookingProvider.notifier).fetchMyBookings(status: status);
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    final result = bookingState.bookings;

    return Scaffold(
      appBar: AppBar(title: const Text('Rezervasyonlarım')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _StatusChip(
                  label: 'Tümü',
                  selected: _selectedStatus == null,
                  onSelected: () => _load(null),
                ),
                _StatusChip(
                  label: 'Bekleyen',
                  selected: _selectedStatus == 'Pending',
                  onSelected: () => _load('Pending'),
                ),
                _StatusChip(
                  label: 'Onaylı',
                  selected: _selectedStatus == 'Confirmed',
                  onSelected: () => _load('Confirmed'),
                ),
                _StatusChip(
                  label: 'İptal',
                  selected: _selectedStatus == 'Cancelled',
                  onSelected: () => _load('Cancelled'),
                ),
              ],
            ),
          ),
          Expanded(
            child: bookingState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : bookingState.errorMessage != null && result == null
                    ? Center(child: Text(bookingState.errorMessage!))
                    : RefreshIndicator(
                        onRefresh: () => _load(_selectedStatus),
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (result == null || result.items.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 120),
                                child: Center(
                                  child: Text('Rezervasyon bulunmuyor'),
                                ),
                              ),
                            if (result != null)
                              for (final booking in result.items)
                                BookingCard(
                                  booking: booking,
                                  onCancel: booking.status != 'Cancelled'
                                      ? () async {
                                          final messenger =
                                              ScaffoldMessenger.of(context);
                                          final cancelled = await ref
                                              .read(bookingProvider.notifier)
                                              .cancelBooking(booking.id);
                                          if (cancelled != null && mounted) {
                                            messenger.showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Rezervasyon iptal edildi',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      : null,
                                ),
                            if (bookingState.isLoadingMore)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            if (result != null &&
                                result.totalPages > result.page &&
                                !bookingState.isLoadingMore)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: OutlinedButton(
                                  onPressed: () => ref
                                      .read(bookingProvider.notifier)
                                      .loadMore(),
                                  child: const Text('Daha fazla yükle'),
                                ),
                              ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const RoleBasedBottomNav(currentPath: '/bookings'),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
