import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/slot.dart';

class SlotTile extends StatelessWidget {
  const SlotTile({
    super.key,
    required this.slot,
    this.onTap,
  });

  final Slot slot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final start = DateTime.parse(slot.startTime).toLocal();
    final end = DateTime.parse(slot.endTime).toLocal();
    final isAvailable = slot.isAvailable;

    return Card(
      color: isAvailable ? null : Colors.grey.shade100,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isAvailable ? Colors.green : Colors.grey,
                width: 6,
              ),
            ),
          ),
          child: ListTile(
            title: Text(
              '${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}',
            ),
            subtitle: Text('${slot.currentBookings}/${slot.capacity}'),
            trailing: isAvailable
                ? const Icon(Icons.chevron_right)
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Dolu',
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
