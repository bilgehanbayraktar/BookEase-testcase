import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_service.dart';
import 'constants.dart';

Dio createDio(StorageService storage) {
  final dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshToken = await storage.getRefreshToken();
          if (refreshToken == null) {
            await storage.clearTokens();
            return handler.next(error);
          }
          try {
            final refreshDio = Dio(BaseOptions(baseUrl: apiBaseUrl));
            final response = await refreshDio.post(
              '/auth/refresh',
              data: {'refreshToken': refreshToken},
            );
            final newAccess = response.data['accessToken'] as String;
            final newRefresh = response.data['refreshToken'] as String;
            await storage.saveTokens(newAccess, newRefresh);

            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccess';
            final retryResponse = await dio.fetch(opts);
            return handler.resolve(retryResponse);
          } catch (_) {
            await storage.clearTokens();
            return handler.next(error);
          }
        }
        handler.next(error);
      },
    ),
  );

  return dio;
}

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return createDio(storage);
});
