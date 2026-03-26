import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/booking.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    this.showCustomerName = false,
    this.onConfirm,
    this.onCancel,
  });

  final Booking booking;
  final bool showCustomerName;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  Color _statusColor() {
    switch (booking.status) {
      case 'Confirmed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel() {
    switch (booking.status) {
      case 'Confirmed':
        return 'Onaylı';
      case 'Cancelled':
        return 'İptal';
      default:
        return 'Bekleyen';
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = DateTime.parse(booking.slotStartTime).toLocal();
    final end = DateTime.parse(booking.slotEndTime).toLocal();
    final statusColor = _statusColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(booking.businessName),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel(),
                    style: TextStyle(color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${DateFormat('d MMMM yyyy', 'tr_TR').format(start)}, ${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}',
            ),
            if (showCustomerName) ...[
              const SizedBox(height: 8),
              Text('Musteri: ${booking.customerName}'),
            ],
            if ((booking.note ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                booking.note!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (onConfirm != null || onCancel != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  spacing: 8,
                  children: [
                    if (onConfirm != null)
                      TextButton(
                        onPressed: onConfirm,
                        child: const Text('Onayla'),
                      ),
                    if (onCancel != null)
                      TextButton(
                        onPressed: onCancel,
                        child: const Text('Iptal Et'),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
