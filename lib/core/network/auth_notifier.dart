import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';
import 'api_client.dart';

class AuthState {
  final bool isLoggedIn;
  final String? userId;
  final String? role;
  final String? storeName;

  const AuthState({
    this.isLoggedIn = false,
    this.userId,
    this.role,
    this.storeName,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? userId,
    String? role,
    String? storeName,
  }) =>
      AuthState(
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        userId: userId ?? this.userId,
        role: role ?? this.role,
        storeName: storeName ?? this.storeName,
      );
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  static const _storage = FlutterSecureStorage();

  @override
  AuthState build() {
    _checkExistingAuth();
    return const AuthState();
  }

  Future<void> _checkExistingAuth() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token != null) {
        return const AuthState(isLoggedIn: true);
      }
      return const AuthState();
    });
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      final token = data['access_token'] ?? data['token'];
      final user = data['user'] ?? {};

      if (token != null) {
        await _storage.write(key: AppConstants.tokenKey, value: token);
      }

      return AuthState(
        isLoggedIn: true,
        userId: user['id']?.toString(),
        role: user['role']?.toString(),
        storeName: user['storeName']?.toString(),
      );
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String storeName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final apiClient = ref.read(apiClientProvider);
      await apiClient.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'storeName': storeName,
      });
      return const AuthState();
    });
  }

  Future<void> logout() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
    state = const AsyncValue.data(AuthState());
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
