import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/api_client.dart';
import '../models/slot.dart';

class SlotQuery {
  const SlotQuery({
    required this.serviceId,
    required this.date,
  });

  final String serviceId;
  final DateTime date;

  String get formattedDate => DateFormat('yyyy-MM-dd').format(date);

  @override
  bool operator ==(Object other) {
    return other is SlotQuery &&
        other.serviceId == serviceId &&
        other.formattedDate == formattedDate;
  }

  @override
  int get hashCode => Object.hash(serviceId, formattedDate);
}

final selectedSlotProvider = StateProvider<Slot?>((ref) => null);

final slotsProvider =
    FutureProvider.family<List<Slot>, SlotQuery>((ref, query) async {
  final response = await ref.read(dioProvider).get(
        '/services/${query.serviceId}/slots',
        queryParameters: {'date': query.formattedDate},
      );
  final data = response.data as List<dynamic>;
  return data
      .map((item) => Slot.fromJson(item as Map<String, dynamic>))
      .toList();
});
