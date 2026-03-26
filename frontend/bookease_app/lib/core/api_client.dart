import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_response.dart';
import '../models/user.dart';
import 'constants.dart';
import 'storage_service.dart';

class SessionManager extends ChangeNotifier {
  SessionManager(this._storage);

  final StorageService _storage;

  bool _isLoggedIn = false;
  AuthUser? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  AuthUser? get currentUser => _currentUser;

  Future<void> hydrate() async {
    final accessToken = await _storage.getAccessToken();
    final userMap = await _storage.getUser();
    _isLoggedIn = accessToken != null && userMap != null;
    _currentUser = userMap == null ? null : AuthUser.fromJson(userMap);
    notifyListeners();
  }

  Future<void> setSession(AuthResponse response) async {
    await _storage.saveTokens(response.accessToken, response.refreshToken);
    await _storage.saveUser(response.user.toJson());
    _isLoggedIn = true;
    _currentUser = response.user;
    notifyListeners();
  }

  Future<void> clearSession() async {
    await _storage.clearTokens();
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }
}

final sessionManagerProvider = Provider<SessionManager>((ref) {
  final manager = SessionManager(ref.watch(storageServiceProvider));
  ref.onDispose(manager.dispose);
  return manager;
});

String extractApiError(Object error) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map<String, dynamic> && data['message'] is String) {
      return data['message'] as String;
    }
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
  }

  return 'Bir hata oluştu. Lütfen tekrar deneyin.';
}

Dio createDio({
  required StorageService storage,
  required SessionManager sessionManager,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: const {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final isUnauthorized = error.response?.statusCode == 401;
        final alreadyRetried =
            error.requestOptions.extra['retriedWithRefresh'] == true;

        if (!isUnauthorized || alreadyRetried) {
          handler.next(error);
          return;
        }

        final refreshToken = await storage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          await sessionManager.clearSession();
          handler.next(error);
          return;
        }

        try {
          final refreshDio = Dio(BaseOptions(baseUrl: apiBaseUrl));
          final refreshResponse = await refreshDio.post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
          );
          final authResponse = AuthResponse.fromJson(
            refreshResponse.data as Map<String, dynamic>,
          );
          await sessionManager.setSession(authResponse);

          final requestOptions = error.requestOptions;
          requestOptions.headers['Authorization'] =
              'Bearer ${authResponse.accessToken}';
          requestOptions.extra['retriedWithRefresh'] = true;

          final response = await dio.fetch(requestOptions);
          handler.resolve(response);
        } catch (_) {
          await sessionManager.clearSession();
          handler.next(error);
        }
      },
    ),
  );

  return dio;
}

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final sessionManager = ref.watch(sessionManagerProvider);
  return createDio(storage: storage, sessionManager: sessionManager);
});
