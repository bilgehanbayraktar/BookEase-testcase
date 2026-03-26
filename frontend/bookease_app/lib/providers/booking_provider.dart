import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/booking.dart';
import '../models/paged_result.dart';

final createBookingProvider =
    FutureProvider.family<Booking, Map<String, dynamic>>((ref, data) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.post('/bookings', data: data);
  return Booking.fromJson(response.data as Map<String, dynamic>);
});

class BookingListNotifier extends StateNotifier<AsyncValue<PagedResult<Booking>>> {
  final Dio _dio;
  String? _statusFilter;
  int _currentPage = 1;

  BookingListNotifier(this._dio) : super(const AsyncValue.loading());

  Future<void> fetchMyBookings({String? status, int page = 1, int pageSize = 10}) async {
    _statusFilter = status;
    _currentPage = page;
    if (page == 1) state = const AsyncValue.loading();
    try {
      final params = <String, dynamic>{'page': page, 'pageSize': pageSize};
      if (status != null) params['status'] = status;
      final response = await _dio.get('/bookings/my', queryParameters: params);
      final result = PagedResult.fromJson(
        response.data as Map<String, dynamic>,
        Booking.fromJson,
      );
      if (page == 1) {
        state = AsyncValue.data(result);
      } else {
        final prev = state.valueOrNull;
        if (prev != null) {
          state = AsyncValue.data(PagedResult(
            items: [...prev.items, ...result.items],
            totalCount: result.totalCount,
            page: result.page,
            pageSize: result.pageSize,
            totalPages: result.totalPages,
          ));
        } else {
          state = AsyncValue.data(result);
        }
      }
    } on DioException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> loadMore({int pageSize = 10}) async {
    await fetchMyBookings(
        status: _statusFilter, page: _currentPage + 1, pageSize: pageSize);
  }

  Future<bool> cancelBooking(String id) async {
    try {
      await _dio.put('/bookings/$id/cancel');
      return true;
    } catch (_) {
      return false;
    }
  }
}

final bookingListProvider =
    StateNotifierProvider<BookingListNotifier, AsyncValue<PagedResult<Booking>>>(
        (ref) {
  final dio = ref.watch(dioProvider);
  return BookingListNotifier(dio);
});
