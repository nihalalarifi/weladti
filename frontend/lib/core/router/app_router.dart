import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/profile_setup/profile_setup_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/health_tracking/health_input_screen.dart';
import '../../features/health_tracking/health_history_screen.dart';
import '../../features/smart_scale/smart_scale_screen.dart';
import '../../features/ai_predictions/ai_predictions_screen.dart';
import '../../features/insights/insights_screen.dart';
import '../../features/chatbot/chatbot_screen.dart';
import '../../features/doctor_panel/doctor_panel_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.primary, size: 60),
            const SizedBox(height: 16),
            Text('حدث خطأ', style: AppTextStyles.headline2),
            const SizedBox(height: 8),
            Text(state.error.toString(), style: AppTextStyles.arabicCaption(), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => context.go('/splash'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('العودة للرئيسية', style: AppTextStyles.buttonText),
              ),
            ),
          ],
        ),
      ),
    ),
    redirect: (context, state) {
      // Redirect bare "/" to splash
      if (state.matchedLocation == '/') return '/splash';
      return null;
    },
    routes: [
      GoRoute(path: '/splash',         builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding',     builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/auth/login',     builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/auth/register',  builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/profile-setup',  builder: (_, __) => const ProfileSetupScreen()),
      GoRoute(path: '/dashboard',      builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/health/input',   builder: (_, __) => const HealthInputScreen()),
      GoRoute(path: '/health/history', builder: (_, __) => const HealthHistoryScreen()),
      GoRoute(path: '/scale',          builder: (_, __) => const SmartScaleScreen()),
      GoRoute(path: '/predictions',    builder: (_, __) => const AiPredictionsScreen()),
      GoRoute(path: '/insights',       builder: (_, __) => const InsightsScreen()),
      GoRoute(path: '/chatbot',        builder: (_, __) => const ChatbotScreen()),
      GoRoute(path: '/doctor',         builder: (_, __) => const DoctorPanelScreen()),
      GoRoute(path: '/settings',       builder: (_, __) => const SettingsScreen()),
    ],
  );
});
