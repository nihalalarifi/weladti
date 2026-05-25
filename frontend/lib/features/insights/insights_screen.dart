import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/network/api_client.dart';
import '../../core/widgets/gradient_button.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  String? _summary;
  bool _loading = false;
  final _api = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _loading = true);
    try {
      final res = await _api.getWeeklySummary();
      setState(() {
        _summary = res['summary'] as String?;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('رؤى أسبوعية', style: AppTextStyles.headline2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadSummary,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header hero
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 36),
                  const SizedBox(height: 10),
                  Text('تقريرك الأسبوعي', style: AppTextStyles.whiteHeadline),
                  Text(
                    'مولَّد بالذكاء الاصطناعي Gemini',
                    style: AppTextStyles.whitebody,
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 20),

            // Quick facts
            Row(
              children: [
                Expanded(child: _FactCard(
                  icon: Iconsax.calendar,
                  label: 'اليوم',
                  value: _dayOfWeekAr(),
                  color: AppColors.primary,
                )),
                const SizedBox(width: 12),
                Expanded(child: _FactCard(
                  icon: Iconsax.book_1,
                  label: 'الملخص',
                  value: 'أسبوعي',
                  color: AppColors.secondary,
                )),
              ],
            ).animate(delay: 100.ms).fadeIn(),

            const SizedBox(height: 20),

            // Weekly summary from Gemini
            if (_loading)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.cardShadow,
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (_summary != null)
              _SummaryCard(summary: _summary!).animate(delay: 200.ms).fadeIn()
            else
              _NoSummaryState(onRetry: _loadSummary),

            const SizedBox(height: 20),

            // Pregnancy week milestones
            _PregnancyMilestonesCard().animate(delay: 300.ms).fadeIn(),

            const SizedBox(height: 20),

            // Tips
            _WeeklyTipsCard().animate(delay: 400.ms).fadeIn(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _dayOfWeekAr() {
    const days = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    return days[DateTime.now().weekday % 7];
  }
}

class _FactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _FactCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTextStyles.arabicBody(color: color, weight: FontWeight.w700)),
              Text(label, style: AppTextStyles.arabicCaption()),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String summary;
  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('ملخص الأسبوع', style: AppTextStyles.headline3),
            ],
          ),
          const Divider(height: 20, color: AppColors.divider),
          Text(
            summary,
            style: AppTextStyles.arabicBody(size: 14),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

class _NoSummaryState extends StatelessWidget {
  final VoidCallback onRetry;
  const _NoSummaryState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Icon(Iconsax.book_1, size: 56, color: AppColors.primary.withOpacity(0.25)),
          const SizedBox(height: 12),
          Text('لا يوجد ملخص حتى الآن', style: AppTextStyles.headline3),
          const SizedBox(height: 8),
          Text(
            'أضيفي بعض القراءات الصحية أولاً',
            style: AppTextStyles.arabicBody(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          GradientButton(label: 'إعادة المحاولة', onTap: onRetry, width: 160, height: 44),
        ],
      ),
    );
  }
}

class _PregnancyMilestonesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final milestones = [
      (week: 'الأسبوع 20-24', event: 'حركات الجنين تبدأ بالوضوح', icon: '👶'),
      (week: 'الأسبوع 24-28', event: 'فحص سكر الحمل المهم', icon: '🩸'),
      (week: 'الأسبوع 28-32', event: 'مرحلة المراقبة المكثفة للضغط', icon: '❤️'),
      (week: 'الأسبوع 36-40', event: 'التحضير للولادة', icon: '🌸'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('محطات مهمة في الحمل', style: AppTextStyles.headline3),
          const SizedBox(height: 14),
          ...milestones.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(m.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.week,
                              style: AppTextStyles.arabicCaption(
                                  color: AppColors.primary, weight: FontWeight.w700)),
                          Text(m.event, style: AppTextStyles.arabicBody(size: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _WeeklyTipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tips = [
      'قيسي ضغط دمكِ كل يوم في نفس الوقت وسجّليه في التطبيق',
      'اشربي 8-10 أكواب ماء يومياً لتقليل احتباس السوائل',
      'تجنّبي الوقوف لفترات طويلة — ارفعي قدميكِ عند الجلوس',
      'تناولي الأطعمة الغنية بالكالسيوم — تساعد في تنظيم الضغط',
      'لا تتجاهلي أي صداع شديد أو اضطراب في الرؤية',
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text('نصائح هذا الأسبوع', style: AppTextStyles.headline3),
            ],
          ),
          const SizedBox(height: 14),
          ...tips.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6, height: 6,
                      margin: const EdgeInsets.only(top: 7, left: 8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(e.value, style: AppTextStyles.arabicBody(size: 14)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
