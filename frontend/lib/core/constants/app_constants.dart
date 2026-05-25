class AppConstants {
  AppConstants._();

  // ── API ─────────────────────────────────────────────────────────────────
  // For iOS Simulator: use localhost — same machine as the Docker backend
  static const String baseUrl = 'http://localhost:8000/api/v1';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ── Storage Keys ─────────────────────────────────────────────────────────
  static const String tokenKey = 'weladti_token';
  static const String userIdKey = 'weladti_user_id';
  static const String onboardingDoneKey = 'weladti_onboarding_done';
  static const String languageKey = 'weladti_language';

  // ── App ──────────────────────────────────────────────────────────────────
  static const String appNameAr = 'ولادتي';
  static const String appNameEn = 'Weladti';
  static const String appTaglineAr = 'رفيقتك في رحلة الأمومة';
  static const String appTaglineEn = 'Your companion in motherhood';

  // ── Blood Pressure Thresholds ────────────────────────────────────────────
  static const double normalSystolicMax = 139.0;
  static const double normalDiastolicMax = 89.0;
  static const double highSystolicThreshold = 140.0;
  static const double highDiastolicThreshold = 90.0;
  static const double severeSystolicThreshold = 160.0;
  static const double severeDiastolicThreshold = 110.0;

  // ── Pregnancy ─────────────────────────────────────────────────────────────
  static const int pregnancyDurationWeeks = 40;
  static const int thirdTrimesterStart = 28;
  static const int secondTrimesterStart = 14;
}
