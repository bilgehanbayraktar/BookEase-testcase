import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api_client.dart';
import '../models/auth_response.dart';
import '../models/user.dart';

class AuthState {
  const AuthState({
    this.isLoggedIn = false,
    this.currentUser,
    this.isLoading = false,
    this.errorMessage,
    this.didInitialize = false,
  });

  final bool isLoggedIn;
  final AuthUser? currentUser;
  final bool isLoading;
  final String? errorMessage;
  final bool didInitialize;

  AuthState copyWith({
    bool? isLoggedIn,
    AuthUser? currentUser,
    bool? isLoading,
    String? errorMessage,
    bool? didInitialize,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      didInitialize: didInitialize ?? this.didInitialize,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(
    this._ref,
    this._sessionManager,
  ) : super(
          AuthState(
            isLoggedIn: _sessionManager.isLoggedIn,
            currentUser: _sessionManager.currentUser,
          ),
        ) {
    _sessionListener = () {
      state = state.copyWith(
        isLoggedIn: _sessionManager.isLoggedIn,
        currentUser: _sessionManager.currentUser,
        isLoading: false,
        didInitialize: true,
        clearError: true,
        clearUser: _sessionManager.currentUser == null,
      );
    };
    _sessionManager.addListener(_sessionListener);
  }

  final Ref _ref;
  final SessionManager _sessionManager;
  late final VoidCallback _sessionListener;

  @override
  void dispose() {
    _sessionManager.removeListener(_sessionListener);
    super.dispose();
  }

  Future<void> checkAuth() async {
    await _sessionManager.hydrate();
    state = state.copyWith(
      isLoggedIn: _sessionManager.isLoggedIn,
      currentUser: _sessionManager.currentUser,
      isLoading: false,
      didInitialize: true,
      clearError: true,
      clearUser: _sessionManager.currentUser == null,
    );
  }

  Future<AuthResponse?> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _ref.read(dioProvider).post(
            '/auth/login',
            data: {'email': email, 'password': password},
          );
      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _sessionManager.setSession(authResponse);
      return authResponse;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: extractApiError(error),
        didInitialize: true,
      );
      return null;
    }
  }

  Future<AuthResponse?> register(
    String email,
    String password,
    String fullName,
    String role,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _ref.read(dioProvider).post(
            '/auth/register',
            data: {
              'email': email,
              'password': password,
              'fullName': fullName,
              'role': role,
            },
          );
      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _sessionManager.setSession(authResponse);
      return authResponse;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: extractApiError(error),
        didInitialize: true,
      );
      return null;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _sessionManager.clearSession();
    state = const AuthState(didInitialize: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref,
    ref.watch(sessionManagerProvider),
  );
});
