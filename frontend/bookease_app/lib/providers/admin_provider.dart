import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../models/auth_response.dart';
import '../models/business.dart';
import '../providers/business_provider.dart';

class AdminActions {
  AdminActions(this._ref);

  final Ref _ref;

  Future<AuthResponse> createUser({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final response = await _ref.read(dioProvider).post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'role': role,
      },
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> createAdmin({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _ref.read(dioProvider).post(
      '/auth/create-admin',
      data: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'role': 'admin',
      },
    );
  }

  Future<Business> createBusiness({
    required String name,
    required String category,
    required String ownerId,
    String? description,
  }) async {
    final response = await _ref.read(dioProvider).post(
      '/businesses',
      data: {
        'name': name,
        'category': category,
        'ownerId': ownerId,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
      },
    );
    _ref.invalidate(businessListProvider);
    return Business.fromJson(response.data as Map<String, dynamic>);
  }
}

final adminActionsProvider = Provider<AdminActions>((ref) {
  return AdminActions(ref);
});
