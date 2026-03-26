import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../models/business.dart';
import '../models/service_model.dart';

class BusinessNotifier extends StateNotifier<AsyncValue<List<Business>>> {
  final Dio _dio;

  BusinessNotifier(this._dio) : super(const AsyncValue.loading());

  Future<void> fetchBusinesses() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/businesses');
      final list = (response.data as List<dynamic>)
          .map((e) => Business.fromJson(e as Map<String, dynamic>))
          .toList();
      state = AsyncValue.data(list);
    } on DioException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final businessProvider =
    StateNotifierProvider<BusinessNotifier, AsyncValue<List<Business>>>((ref) {
  final dio = ref.watch(dioProvider);
  return BusinessNotifier(dio);
});

final businessDetailProvider =
    FutureProvider.family<Business, String>((ref, id) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/businesses/$id');
  return Business.fromJson(response.data as Map<String, dynamic>);
});

final servicesProvider =
    FutureProvider.family<List<ServiceModel>, String>((ref, businessId) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/businesses/$businessId/services');
  return (response.data as List<dynamic>)
      .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
      .toList();
});
