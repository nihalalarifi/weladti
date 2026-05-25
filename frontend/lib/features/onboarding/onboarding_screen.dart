import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_button.dart';

class _OnboardingPage {
  final String titleAr;
  final String bodyAr;
  final IconData icon;
  final Gradient gradient;

  const _OnboardingPage({
    required this.titleAr,
    required this.bodyAr,
    required this.icon,
    required this.gradient,
  });
}

const _pages = [
  _OnboardingPage(
    titleAr: 'مرحباً بكِ في ولادتي',
    bodyAr: 'رفيقتك الذكية خلال رحلة الحمل.\nنراقب صحتك ونحميكِ بتقنية الذكاء الاصطناعي.',
    icon: Icons.favorite_rounded,
    gradient: AppColors.primaryGradient,
  ),
  _OnboardingPage(
    titleAr: 'رصد تسمم الحمل',
    bodyAr: 'نحلل ضغط دمكِ، وزنكِ، وأعراضكِ يومياً\nلاكتشاف مؤشرات تسمم الحمل مبكراً.',
    icon: Icons.monitor_heart_rounded,
    gradient: LinearGradient(
      colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  _OnboardingPage(
    titleAr: 'الميزان الذكي',
    bodyAr: 'تكامل مع Withings Body Scan\nلقياس تكوين جسمكِ والكشف عن احتباس السوائل.',
    icon: Icons.scale_rounded,
    gradient: LinearGradient(
      colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  _OnboardingPage(
    titleAr: 'مساعدتكِ الذكية "نور"',
    bodyAr: 'اسألي "نور" أي سؤال طبي في أي وقت.\nتقارير طبية بالعربية مولّدة بالذكاء الاصطناعي.',
    icon: Icons.chat_rounded,
    gradient: LinearGradient(
      colors: [Color(0xFFFF5722), Color(0xFFE91E8C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _current = 0;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingDoneKey, true);
    if (mounted) context.go('/auth/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) => _OnboardingPageView(page: _pages[i]),
          ),
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: const WormEffect(
                      dotColor: Colors.white38,
                      activeDotColor: Colors.white,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _current == _pages.length - 1
                      ? GradientButton(
                          label: 'ابدئي الآن',
                          onTap: _finish,
                          gradient: const LinearGradient(
                            colors: [Colors.white, Color(0xFFF8BBD0)],
                          ),
                        )
                      : Row(
                          children: [
                            TextButton(
                              onPressed: _finish,
                              child: Text(
                                'تخطي',
                                style: AppTextStyles.arabicBody(color: Colors.white70),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _controller.nextPage(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                              ),
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white38),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;

  const _OnboardingPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: page.gradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(page.icon, size: 72, color: Colors.white),
              )
                  .animate()
                  .scale(duration: 500.ms, curve: Curves.elasticOut),

              const SizedBox(height: 48),

              Text(
                page.titleAr,
                style: AppTextStyles.arabicDisplay(color: Colors.white, size: 30),
                textAlign: TextAlign.center,
              ).animate(delay: 100.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2),

              const SizedBox(height: 16),

              Text(
                page.bodyAr,
                style: AppTextStyles.arabicBody(
                  color: Colors.white.withOpacity(0.88),
                  size: 16,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 200.ms).fadeIn(duration: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}
