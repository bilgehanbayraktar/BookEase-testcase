import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/api_client.dart';
import '../models/slot.dart';
import '../providers/booking_provider.dart';
import '../providers/slot_provider.dart';

class CreateBookingScreen extends ConsumerStatefulWidget {
  const CreateBookingScreen({
    super.key,
    required this.slotId,
  });

  final String? slotId;

  @override
  ConsumerState<CreateBookingScreen> createState() =>
      _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  final _noteController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final slotId = widget.slotId;
    if (slotId == null || slotId.isEmpty) {
      setState(() => _errorMessage = 'Geçerli bir slot seçilmedi');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final booking = await ref.read(bookingProvider.notifier).createBooking(
            slotId,
            note: _noteController.text,
          );
      if (booking == null || !mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rezervasyon oluşturuldu!')),
      );
      context.go('/bookings');
    } on DioException catch (error) {
      setState(() {
        _errorMessage = error.response?.statusCode == 409
            ? 'Seçilen slot dolu.'
            : extractApiError(error);
      });
    } catch (error) {
      setState(() => _errorMessage = extractApiError(error));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedSlot = ref.watch(selectedSlotProvider);
    final effectiveSlot = selectedSlot?.id == widget.slotId ? selectedSlot : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Rezervasyon Yap')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SlotSummaryCard(slot: effectiveSlot, slotId: widget.slotId),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notunuz (opsiyonel)',
              hintText: 'Notunuz (opsiyonel)',
              alignLabelWithHint: true,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Rezervasyon Yap'),
          ),
        ],
      ),
    );
  }
}

class _SlotSummaryCard extends StatelessWidget {
  const _SlotSummaryCard({
    required this.slot,
    required this.slotId,
  });

  final Slot? slot;
  final String? slotId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: slot == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Slot Özeti',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('Slot ID: ${slotId ?? '-'}'),
                  const SizedBox(height: 8),
                  const Text(
                    'Bu ekranda slot özeti, listeden gelen seçim bilgisiyle gösterilir.',
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot!.serviceName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('d MMMM yyyy', 'tr_TR')
                        .format(DateTime.parse(slot!.startTime).toLocal()),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('HH:mm').format(DateTime.parse(slot!.startTime).toLocal())} - ${DateFormat('HH:mm').format(DateTime.parse(slot!.endTime).toLocal())}',
                  ),
                  const SizedBox(height: 4),
                  Text('${slot!.currentBookings}/${slot!.capacity} rezervasyon'),
                ],
              ),
      ),
    );
  }
}
