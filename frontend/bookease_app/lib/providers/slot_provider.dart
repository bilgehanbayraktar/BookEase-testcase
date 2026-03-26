import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/slot.dart';

class SlotParams {
  final String serviceId;
  final String? date;

  const SlotParams({required this.serviceId, this.date});

  @override
  bool operator ==(Object other) =>
      other is SlotParams &&
      other.serviceId == serviceId &&
      other.date == date;

  @override
  int get hashCode => Object.hash(serviceId, date);
}

final slotProvider =
    FutureProvider.family<List<Slot>, SlotParams>((ref, params) async {
  final dio = ref.watch(dioProvider);
  final queryParams = <String, dynamic>{};
  if (params.date != null) queryParams['date'] = params.date;
  final response = await dio.get(
    '/services/${params.serviceId}/slots',
    queryParameters: queryParams.isNotEmpty ? queryParams : null,
  );
  return (response.data as List<dynamic>)
      .map((e) => Slot.fromJson(e as Map<String, dynamic>))
      .toList();
});
