import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onCancel;

  const BookingCard({super.key, required this.booking, this.onCancel});

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

  String _formatDateRange() {
    final start = DateTime.parse(booking.slotStartTime).toLocal();
    final end = DateTime.parse(booking.slotEndTime).toLocal();
    final dateFmt = DateFormat('d MMMM yyyy', 'tr_TR');
    final timeFmt = DateFormat('HH:mm');
    return '${dateFmt.format(start)}, ${timeFmt.format(start)} - ${timeFmt.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        booking.businessName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusLabel(),
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16),
                const SizedBox(width: 4),
                Text(_formatDateRange(),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            if (booking.note != null && booking.note!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                booking.note!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
            if (booking.status != 'Cancelled') ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('İptal Et'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
