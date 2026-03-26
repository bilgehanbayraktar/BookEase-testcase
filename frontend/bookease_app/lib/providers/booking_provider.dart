import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../models/booking.dart';
import '../models/paged_result.dart';

class BookingListState {
  const BookingListState({
    this.bookings,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.status,
  });

  final PagedResult<Booking>? bookings;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? status;

  BookingListState copyWith({
    PagedResult<Booking>? bookings,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    String? status,
    bool clearError = false,
  }) {
    return BookingListState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      status: status ?? this.status,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingListState> {
  BookingNotifier(this._ref) : super(const BookingListState());

  final Ref _ref;
  static const int _defaultPageSize = 10;

  Future<Booking?> createBooking(String slotId, {String? note}) async {
    final response = await _ref.read(dioProvider).post(
          '/bookings',
          data: {
            'slotId': slotId,
            if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
          },
        );
    return Booking.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> fetchMyBookings({
    String? status,
    int page = 1,
    int pageSize = _defaultPageSize,
  }) async {
    state = state.copyWith(
      isLoading: page == 1,
      isLoadingMore: page > 1,
      status: status,
      clearError: true,
    );

    try {
      final queryParameters = <String, dynamic>{
        'status': status,
        'page': page,
        'pageSize': pageSize,
      }..removeWhere((key, value) => value == null);

      final response = await _ref.read(dioProvider).get(
            '/bookings/my',
            queryParameters: queryParameters,
          );
      final result = PagedResult<Booking>.fromJson(
        response.data as Map<String, dynamic>,
        Booking.fromJson,
      );

      if (page > 1 && state.bookings != null) {
        state = state.copyWith(
          bookings: result.copyWith(
            items: [...state.bookings!.items, ...result.items],
          ),
          isLoading: false,
          isLoadingMore: false,
          clearError: true,
        );
        return;
      }

      state = state.copyWith(
        bookings: result,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: extractApiError(error),
      );
    }
  }

  Future<void> loadMore() async {
    final current = state.bookings;
    if (current == null ||
        state.isLoadingMore ||
        current.page >= current.totalPages) {
      return;
    }

    await fetchMyBookings(
      status: state.status,
      page: current.page + 1,
      pageSize: current.pageSize,
    );
  }

  Future<Booking?> cancelBooking(String id) async {
    try {
      final response = await _ref.read(dioProvider).put('/bookings/$id/cancel');
      final booking = Booking.fromJson(response.data as Map<String, dynamic>);

      final current = state.bookings;
      if (current != null) {
        final updatedItems = current.items
            .map((item) => item.id == id ? booking : item)
            .toList();
        state = state.copyWith(
          bookings: current.copyWith(items: updatedItems),
          clearError: true,
        );
      }
      return booking;
    } catch (error) {
      state = state.copyWith(errorMessage: extractApiError(error));
      return null;
    }
  }
}

final bookingProvider =
    StateNotifierProvider<BookingNotifier, BookingListState>((ref) {
  return BookingNotifier(ref);
});
