import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../core/constants/app_constants.dart';

class AuthState {
  final bool isAuthenticated;
  final Map<String, dynamic>? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    Map<String, dynamic>? user,
    bool? isLoading,
    String? error,
  }) =>
      AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  String get fullName => user?['full_name'] ?? '';
  bool get profileComplete => user?['profile_complete'] ?? false;
  String get role => user?['role'] ?? 'patient';
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _api;

  AuthNotifier(this._api) : super(const AuthState());

  Future<void> checkAuth() async {
    final hasToken = await _api.hasToken();
    if (!hasToken) {
      state = state.copyWith(isAuthenticated: false);
      return;
    }
    try {
      final user = await _api.getMe();
      state = state.copyWith(isAuthenticated: true, user: user);
    } catch (e) {
      // Token invalid (e.g. server restarted) — clear and send to login
      await _api.clearToken();
      state = state.copyWith(isAuthenticated: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _api.login(email, password);
      await _api.saveToken(data['access_token']);
      state = state.copyWith(isAuthenticated: true, user: data, isLoading: false);
      return true;
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: 'فشل تسجيل الدخول. تحقق من بياناتك.');
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _api.register(data);
      await _api.saveToken(result['access_token']);
      state = state.copyWith(isAuthenticated: true, user: result, isLoading: false);
      return true;
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: 'فشل إنشاء الحساب. البريد الإلكتروني مسجل مسبقاً.');
      return false;
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userIdKey);
    state = const AuthState();
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      final updated = await _api.updateProfile(data);
      state = state.copyWith(user: updated, isLoading: false);
      return true;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ApiClient()),
);
