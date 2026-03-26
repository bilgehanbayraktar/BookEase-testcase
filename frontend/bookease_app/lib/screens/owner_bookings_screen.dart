import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../models/booking.dart';
import '../providers/owner_provider.dart';
import '../widgets/booking_card.dart';
import '../widgets/role_based_bottom_nav.dart';

class OwnerBookingsScreen extends ConsumerWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(ownerAllBookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gelen Rezervasyonlar')),
      body: bookingsAsync.when(
        data: (bookings) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(ownerAllBookingsProvider),
          child: bookings.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 240),
                    Center(child: Text('Rezervasyon bulunmuyor')),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return BookingCard(
                      booking: booking,
                      showCustomerName: true,
                      onConfirm: booking.status == 'Pending'
                          ? () => _handleAction(
                                context,
                                ref,
                                booking,
                                isConfirm: true,
                              )
                          : null,
                      onCancel: booking.status != 'Cancelled'
                          ? () => _handleAction(
                                context,
                                ref,
                                booking,
                                isConfirm: false,
                              )
                          : null,
                    );
                  },
                ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text(extractApiError(error))),
      ),
      bottomNavigationBar: const RoleBasedBottomNav(currentPath: '/owner-bookings'),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    Booking booking, {
    required bool isConfirm,
  }) async {
    try {
      if (isConfirm) {
        await ref.read(ownerActionsProvider).confirmBooking(booking.id);
      } else {
        await ref.read(ownerActionsProvider).cancelBooking(booking.id);
      }
      ref.invalidate(ownerAllBookingsProvider);
      ref.invalidate(myBusinessesProvider);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(extractApiError(error))),
        );
      }
    }
  }
}
