import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // On 401/403 clear token so user gets sent to login
          if (error.response?.statusCode == 401 ||
              error.response?.statusCode == 403) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove(AppConstants.tokenKey);
          }
          return handler.next(error);
        },
      ),
    );
  }

  factory ApiClient() => _instance ??= ApiClient._();

  // ── Auth ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final res = await _dio.post('/auth/register', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post('/auth/login',
        data: {'email': email, 'password': password});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get('/auth/me');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final res = await _dio.put('/auth/profile', data: data);
    return res.data as Map<String, dynamic>;
  }

  // ── Health Records ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> createHealthRecord(
      Map<String, dynamic> data) async {
    final res = await _dio.post('/health/records', data: data);
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getHealthRecords({int limit = 30}) async {
    final res = await _dio.get('/health/records',
        queryParameters: {'limit': limit});
    return res.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getDashboard() async {
    final res = await _dio.get('/health/dashboard');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getLatestRecord() async {
    final res = await _dio.get('/health/records/latest');
    return res.data as Map<String, dynamic>;
  }

  // ── AI Predictions ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> analyzeHealth(
      {bool generateReport = false}) async {
    final res = await _dio.post('/predictions/analyze',
        queryParameters: {'generate_report': generateReport});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getLatestPrediction() async {
    final res = await _dio.get('/predictions/latest');
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getPredictionHistory() async {
    final res = await _dio.get('/predictions/history');
    return res.data as List<dynamic>;
  }

  // ── Smart Scale ───────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getScaleStatus() async {
    final res = await _dio.get('/scale/status');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> takeMeasurement() async {
    final res = await _dio.post('/scale/measure');
    return res.data as Map<String, dynamic>;
  }

  // ── AI Insights ───────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> chat(String message,
      {String language = 'ar'}) async {
    final res = await _dio.post('/insights/chat',
        data: {'message': message, 'language': language});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getWeeklySummary() async {
    final res = await _dio.get('/insights/weekly-summary');
    return res.data as Map<String, dynamic>;
  }

  // ── Token Management ──────────────────────────────────────────────────────
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userIdKey);
  }

  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }
}
