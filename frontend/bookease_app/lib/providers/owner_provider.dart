import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../models/booking.dart';
import '../models/business.dart';
import '../models/paged_result.dart';
import '../models/service_model.dart';
import '../providers/auth_provider.dart';
import '../providers/business_provider.dart';

final myBusinessesProvider = FutureProvider<List<Business>>((ref) async {
  final currentUser = ref.watch(authProvider).currentUser;
  final businesses = await ref.watch(businessListProvider.future);

  if (currentUser == null) {
    return const [];
  }

  return businesses
      .where((business) => business.owner.id == currentUser.id)
      .toList();
});

final businessBookingsProvider =
    FutureProvider.family<List<Booking>, String>((ref, businessId) async {
  final response = await ref.read(dioProvider).get(
        '/businesses/$businessId/bookings',
        queryParameters: const {
          'page': 1,
          'pageSize': 100,
        },
      );
  final paged = PagedResult<Booking>.fromJson(
    response.data as Map<String, dynamic>,
    Booking.fromJson,
  );
  return paged.items;
});

final ownerAllBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final businesses = await ref.watch(myBusinessesProvider.future);
  final dio = ref.read(dioProvider);
  final bookings = <Booking>[];

  for (final business in businesses) {
    final response = await dio.get(
      '/businesses/${business.id}/bookings',
      queryParameters: const {
        'page': 1,
        'pageSize': 100,
      },
    );
    final paged = PagedResult<Booking>.fromJson(
      response.data as Map<String, dynamic>,
      Booking.fromJson,
    );
    bookings.addAll(paged.items);
  }

  bookings.sort(
    (a, b) => DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)),
  );
  return bookings;
});

class OwnerActions {
  OwnerActions(this._ref);

  final Ref _ref;

  Future<void> createBusiness({
    required String name,
    required String category,
    String? description,
  }) async {
    await _ref.read(dioProvider).post(
      '/businesses',
      data: {
        'name': name,
        'category': category,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
      },
    );
    _ref.invalidate(businessListProvider);
    _ref.invalidate(myBusinessesProvider);
  }

  Future<ServiceModel> createService({
    required String businessId,
    required String name,
    required int durationMinutes,
    required double price,
    required int capacity,
  }) async {
    final response = await _ref.read(dioProvider).post(
      '/businesses/$businessId/services',
      data: {
        'name': name,
        'durationMinutes': durationMinutes,
        'price': price,
        'capacity': capacity,
      },
    );
    _ref.invalidate(servicesProvider(businessId));
    return ServiceModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteService({
    required String businessId,
    required String serviceId,
  }) async {
    await _ref.read(dioProvider).delete('/businesses/$businessId/services/$serviceId');
    _ref.invalidate(servicesProvider(businessId));
  }

  Future<void> createSlot({
    required String serviceId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    await _ref.read(dioProvider).post(
      '/services/$serviceId/slots',
      data: {
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
      },
    );
  }

  Future<Booking> confirmBooking(String bookingId) async {
    final response = await _ref.read(dioProvider).put('/bookings/$bookingId/confirm');
    return Booking.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Booking> cancelBooking(String bookingId) async {
    final response = await _ref.read(dioProvider).put('/bookings/$bookingId/cancel');
    return Booking.fromJson(response.data as Map<String, dynamic>);
  }
}

final ownerActionsProvider = Provider<OwnerActions>((ref) => OwnerActions(ref));
