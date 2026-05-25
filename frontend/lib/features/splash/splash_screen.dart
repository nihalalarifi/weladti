import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final onboardingDone = prefs.getBool(AppConstants.onboardingDoneKey) ?? false;

      if (!onboardingDone) {
        if (mounted) context.go('/onboarding');
        return;
      }

      await ref.read(authStateProvider.notifier).checkAuth();
      if (!mounted) return;
      final isAuth = ref.read(authStateProvider).isAuthenticated;
      context.go(isAuth ? '/dashboard' : '/auth/login');
    } catch (_) {
      if (mounted) context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                ),
                child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 50),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 28),

              Text(
                AppConstants.appNameAr,
                style: AppTextStyles.arabicDisplay(
                  size: 48,
                  color: Colors.white,
                  weight: FontWeight.w800,
                ),
              )
                  .animate(delay: 300.ms)
                  .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOut)
                  .fadeIn(duration: 600.ms),

              const SizedBox(height: 8),

              Text(
                AppConstants.appTaglineAr,
                style: AppTextStyles.arabicBody(
                  color: Colors.white.withOpacity(0.85),
                  size: 16,
                ),
              )
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 600.ms),

              const SizedBox(height: 60),

              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white.withOpacity(0.6),
                ),
              ).animate(delay: 800.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
