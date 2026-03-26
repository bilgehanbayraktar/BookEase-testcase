import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import '../core/storage_service.dart';
import '../models/auth_response.dart';
import '../models/user.dart';

class AuthState {
  final bool isLoggedIn;
  final AuthUser? currentUser;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.isLoggedIn = false,
    this.currentUser,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    AuthUser? currentUser,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearUser = false,
  }) =>
      AuthState(
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        currentUser: clearUser ? null : (currentUser ?? this.currentUser),
        isLoading: isLoading ?? this.isLoading,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio;
  final StorageService _storage;

  AuthNotifier(this._dio, this._storage) : super(const AuthState());

  Future<void> checkAuth() async {
    final token = await _storage.getAccessToken();
    final userMap = await _storage.getUser();
    if (token != null && userMap != null) {
      state = state.copyWith(
        isLoggedIn: true,
        currentUser: AuthUser.fromJson(userMap),
      );
    }
  }

  Future<AuthResponse?> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      await _storage.saveTokens(auth.accessToken, auth.refreshToken);
      await _storage.saveUser(auth.user.toJson());
      state = state.copyWith(
        isLoggedIn: true,
        currentUser: auth.user,
        isLoading: false,
      );
      return auth;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _parseError(e),
      );
      return null;
    }
  }

  Future<AuthResponse?> register(
      String email, String password, String fullName, String role) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'role': role,
        },
      );
      final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      await _storage.saveTokens(auth.accessToken, auth.refreshToken);
      await _storage.saveUser(auth.user.toJson());
      state = state.copyWith(
        isLoggedIn: true,
        currentUser: auth.user,
        isLoading: false,
      );
      return auth;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _parseError(e),
      );
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.clearTokens();
    state = const AuthState();
  }

  String _parseError(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'] as String;
    }
    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(storageServiceProvider);
  return AuthNotifier(dio, storage);
});
