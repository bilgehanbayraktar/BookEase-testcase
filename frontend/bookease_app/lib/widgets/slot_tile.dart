import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/slot.dart';

class SlotTile extends StatelessWidget {
  final Slot slot;
  final VoidCallback? onTap;

  const SlotTile({super.key, required this.slot, this.onTap});

  @override
  Widget build(BuildContext context) {
    final start = DateTime.parse(slot.startTime).toLocal();
    final end = DateTime.parse(slot.endTime).toLocal();
    final timeFormat = DateFormat('HH:mm');
    final timeRange = '${timeFormat.format(start)} - ${timeFormat.format(end)}';
    final isFull = !slot.isAvailable;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isFull ? Colors.grey : Colors.green,
            width: 4,
          ),
        ),
        color: isFull
            ? Colors.grey.shade100
            : Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: isFull ? null : onTap,
        title: Text(
          timeRange,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isFull ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          '${slot.currentBookings}/${slot.capacity} rezervasyon',
          style: TextStyle(color: isFull ? Colors.grey : null),
        ),
        trailing: isFull
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Dolu',
                  style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              )
            : const Icon(Icons.chevron_right, color: Colors.green),
      ),
    );
  }
}
