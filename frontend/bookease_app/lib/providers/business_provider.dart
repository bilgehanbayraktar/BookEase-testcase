import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../models/business.dart';
import '../models/service_model.dart';

final businessListProvider = FutureProvider<List<Business>>((ref) async {
  final response = await ref.read(dioProvider).get('/businesses');
  final data = response.data as List<dynamic>;
  return data
      .map((item) => Business.fromJson(item as Map<String, dynamic>))
      .toList();
});

final businessDetailProvider =
    FutureProvider.family<Business, String>((ref, businessId) async {
  final response = await ref.read(dioProvider).get('/businesses/$businessId');
  return Business.fromJson(response.data as Map<String, dynamic>);
});

final servicesProvider =
    FutureProvider.family<List<ServiceModel>, String>((ref, businessId) async {
  final response =
      await ref.read(dioProvider).get('/businesses/$businessId/services');
  final data = response.data as List<dynamic>;
  return data
      .map((item) => ServiceModel.fromJson(item as Map<String, dynamic>))
      .toList();
});
