import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/api_client.dart';
import '../models/slot.dart';

class CreateBookingScreen extends ConsumerStatefulWidget {
  final Slot slot;

  const CreateBookingScreen({super.key, required this.slot});

  @override
  ConsumerState<CreateBookingScreen> createState() =>
      _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  final _noteCtrl = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  String _formatSlotTime() {
    final start = DateTime.parse(widget.slot.startTime).toLocal();
    final end = DateTime.parse(widget.slot.endTime).toLocal();
    final dateFmt = DateFormat('d MMMM yyyy', 'tr_TR');
    final timeFmt = DateFormat('HH:mm');
    return '${dateFmt.format(start)}, ${timeFmt.format(start)} - ${timeFmt.format(end)}';
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final dio = ref.read(dioProvider);
      final note = _noteCtrl.text.trim();
      await dio.post('/bookings', data: {
        'slotId': widget.slot.id,
        if (note.isNotEmpty) 'note': note,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rezervasyon oluşturuldu!')),
        );
        context.go('/bookings');
      }
    } catch (e) {
      String msg = 'Bir hata oluştu.';
      if (e.toString().contains('409')) {
        msg = 'Bu slot doldu. Lütfen başka bir slot seçin.';
      }
      setState(() => _errorMessage = msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezervasyon Yap'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.slot.serviceName,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 18),
                            const SizedBox(width: 6),
                            Text(_formatSlotTime()),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.people_outline, size: 18),
                            const SizedBox(width: 6),
                            Text(
                                '${widget.slot.currentBookings}/${widget.slot.capacity} rezervasyon'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _noteCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notunuz (opsiyonel)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Rezervasyon Yap'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
