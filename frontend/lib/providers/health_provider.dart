import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';

class HealthState {
  final Map<String, dynamic>? dashboard;
  final List<dynamic> records;
  final Map<String, dynamic>? latestPrediction;
  final Map<String, dynamic>? scaleData;
  final bool isLoading;
  final String? error;

  const HealthState({
    this.dashboard,
    this.records = const [],
    this.latestPrediction,
    this.scaleData,
    this.isLoading = false,
    this.error,
  });

  HealthState copyWith({
    Map<String, dynamic>? dashboard,
    List<dynamic>? records,
    Map<String, dynamic>? latestPrediction,
    Map<String, dynamic>? scaleData,
    bool? isLoading,
    String? error,
  }) =>
      HealthState(
        dashboard: dashboard ?? this.dashboard,
        records: records ?? this.records,
        latestPrediction: latestPrediction ?? this.latestPrediction,
        scaleData: scaleData ?? this.scaleData,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class HealthNotifier extends StateNotifier<HealthState> {
  final ApiClient _api;

  HealthNotifier(this._api) : super(const HealthState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _api.getDashboard();
      state = state.copyWith(dashboard: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadRecords() async {
    try {
      final data = await _api.getHealthRecords();
      state = state.copyWith(records: data);
    } catch (_) {}
  }

  Future<bool> submitHealthRecord(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    try {
      await _api.createHealthRecord(data);
      await loadDashboard();
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<Map<String, dynamic>?> runAiAnalysis({bool withReport = false}) async {
    state = state.copyWith(isLoading: true);
    try {
      final pred = await _api.analyzeHealth(generateReport: withReport);
      state = state.copyWith(latestPrediction: pred, isLoading: false);
      return pred;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<void> loadLatestPrediction() async {
    try {
      final pred = await _api.getLatestPrediction();
      state = state.copyWith(latestPrediction: pred);
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> takeScaleMeasurement() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _api.takeMeasurement();
      state = state.copyWith(scaleData: data, isLoading: false);
      return data;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }
}

final healthProvider = StateNotifierProvider<HealthNotifier, HealthState>(
  (ref) => HealthNotifier(ApiClient()),
);
