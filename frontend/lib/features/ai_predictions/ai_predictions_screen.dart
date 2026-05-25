import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/health_card.dart';
import '../../providers/health_provider.dart';

class AiPredictionsScreen extends ConsumerStatefulWidget {
  const AiPredictionsScreen({super.key});

  @override
  ConsumerState<AiPredictionsScreen> createState() => _AiPredictionsScreenState();
}

class _AiPredictionsScreenState extends ConsumerState<AiPredictionsScreen> {
  bool _withReport = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthProvider.notifier).loadLatestPrediction();
    });
  }

  Future<void> _analyze() async {
    final result = await ref.read(healthProvider.notifier).runAiAnalysis(withReport: _withReport);
    if (result == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'أضيفي قراءة صحية أولاً لبدء التحليل',
            style: AppTextStyles.arabicBody(color: Colors.white),
          ),
          backgroundColor: AppColors.riskModerate,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'إضافة قراءة',
            textColor: Colors.white,
            onPressed: () => context.push('/health/input'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final health = ref.watch(healthProvider);
    final prediction = health.latestPrediction;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('التحليل الذكي', style: AppTextStyles.headline2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const Icon(Iconsax.cpu, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  Text('محرك الذكاء الاصطناعي', style: AppTextStyles.whiteHeadline),
                  const SizedBox(height: 6),
                  Text(
                    'يحلل ضغط الدم وتكوين جسمكِ والأعراض\nللتنبؤ بمخاطر تسمم الحمل',
                    style: AppTextStyles.whitebody,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 20),

            // Options
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('إنشاء تقرير طبي', style: AppTextStyles.arabicBody(weight: FontWeight.w600)),
                        Text(
                          'تقرير بالعربية عبر Gemini AI',
                          style: AppTextStyles.arabicCaption(),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _withReport,
                    onChanged: (v) => setState(() => _withReport = v),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ).animate(delay: 100.ms).fadeIn(),

            const SizedBox(height: 16),

            GradientButton(
              label: 'تشغيل التحليل',
              onTap: _analyze,
              isLoading: health.isLoading,
              icon: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
            ).animate(delay: 150.ms).fadeIn(),

            const SizedBox(height: 24),

            if (prediction != null) ...[
              Text('نتائج التحليل', style: AppTextStyles.headline2)
                  .animate(delay: 200.ms).fadeIn(),
              const SizedBox(height: 16),

              // Main risk card
              _MainRiskCard(prediction: prediction).animate(delay: 250.ms).slideY(begin: 0.1).fadeIn(),

              const SizedBox(height: 16),

              // Secondary risks
              _SecondaryRisksCard(prediction: prediction).animate(delay: 300.ms).fadeIn(),

              const SizedBox(height: 16),

              // Alerts
              if ((prediction['alerts'] as List?)?.isNotEmpty == true)
                _AlertsCard(alerts: prediction['alerts'] as List).animate(delay: 350.ms).fadeIn(),

              const SizedBox(height: 16),

              // Recommendations
              _RecommendationsCard(
                recs: (prediction['recommendations'] as List?)?.cast<String>() ?? [],
              ).animate(delay: 400.ms).fadeIn(),

              // AI Report
              if (prediction['ai_report_ar'] != null) ...[
                const SizedBox(height: 16),
                _AiReportCard(report: prediction['ai_report_ar'] as String)
                    .animate(delay: 450.ms).fadeIn(),
              ],
            ] else if (!health.isLoading)
              _NoPredictionState(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _MainRiskCard extends StatelessWidget {
  final Map<String, dynamic> prediction;
  const _MainRiskCard({required this.prediction});

  @override
  Widget build(BuildContext context) {
    final level = prediction['preeclampsia_risk_level'] as String? ?? 'low';
    final score = (prediction['preeclampsia_risk_score'] as num?)?.toDouble() ?? 0;
    final color = AppColors.riskColor(level);
    final probs = prediction['risk_probabilities'] as Map<String, dynamic>? ?? {};

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('خطر تسمم الحمل', style: AppTextStyles.arabicCaption()),
                    const SizedBox(height: 8),
                    RiskBadge(riskLevel: level, score: score, large: true),
                    const SizedBox(height: 8),
                    Text(
                      'ثقة النموذج: ${((prediction['confidence'] as num?) ?? 0 * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.arabicCaption(),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: score,
                      strokeWidth: 10,
                      backgroundColor: color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(score * 100).toStringAsFixed(0)}%',
                          style: AppTextStyles.number(size: 20, color: color),
                        ),
                        Text('خطر', style: AppTextStyles.arabicCaption(size: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 16),
          // Probability bars
          Text('توزيع الاحتمالات', style: AppTextStyles.arabicCaption()),
          const SizedBox(height: 12),
          ...['low', 'moderate', 'high', 'critical'].map((lvl) {
            final prob = (probs[lvl] as num?)?.toDouble() ?? 0;
            final c = AppColors.riskColor(lvl);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(AppColors.riskLabelAr(lvl), style: AppTextStyles.arabicCaption()),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: prob,
                        backgroundColor: c.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(c),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(prob * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.label(size: 12),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SecondaryRisksCard extends StatelessWidget {
  final Map<String, dynamic> prediction;
  const _SecondaryRisksCard({required this.prediction});

  @override
  Widget build(BuildContext context) {
    final risks = [
      (
        label: 'زيادة الوزن غير الطبيعية',
        value: (prediction['abnormal_weight_gain_risk'] as num?)?.toDouble() ?? 0,
        icon: Iconsax.weight,
        color: AppColors.accent,
      ),
      (
        label: 'احتباس السوائل',
        value: (prediction['fluid_retention_risk'] as num?)?.toDouble() ?? 0,
        icon: Iconsax.drop,
        color: const Color(0xFF2196F3),
      ),
      (
        label: 'مخاطر سكري الحمل',
        value: (prediction['gestational_diabetes_risk'] as num?)?.toDouble() ?? 0,
        icon: Iconsax.health,
        color: const Color(0xFF9C27B0),
      ),
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
          Text('مخاطر أخرى', style: AppTextStyles.headline3),
          const SizedBox(height: 16),
          ...risks.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(r.icon, color: r.color, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(r.label, style: AppTextStyles.arabicBody(size: 14)),
                        ),
                        Text(
                          '${(r.value * 100).toStringAsFixed(0)}%',
                          style: AppTextStyles.number(size: 14, color: r.color),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: r.value,
                        backgroundColor: r.color.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(r.color),
                        minHeight: 6,
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

class _AlertsCard extends StatelessWidget {
  final List alerts;
  const _AlertsCard({required this.alerts});

  @override
  Widget build(BuildContext context) {
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
          Text('التنبيهات النشطة', style: AppTextStyles.headline3),
          const SizedBox(height: 12),
          ...alerts.map((a) {
            final severity = a['severity'] as String? ?? 'moderate';
            final color = severity == 'critical' ? AppColors.riskCritical
                : severity == 'high' ? AppColors.riskHigh
                : AppColors.riskModerate;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Text(a['icon'] ?? '⚠️', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a['title_ar'] ?? '',
                          style: AppTextStyles.arabicBody(color: color, weight: FontWeight.w700, size: 13),
                        ),
                        Text(a['message_ar'] ?? '', style: AppTextStyles.arabicCaption()),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  final List<String> recs;
  const _RecommendationsCard({required this.recs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3E5F5), Color(0xFFFCE4EC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('التوصيات', style: AppTextStyles.headline3),
            ],
          ),
          const SizedBox(height: 14),
          ...recs.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${e.key + 1}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
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

class _AiReportCard extends StatelessWidget {
  final String report;
  const _AiReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('التقرير الطبي الذكي', style: AppTextStyles.headline3),
              const Spacer(),
              Text('Gemini AI', style: AppTextStyles.label(size: 11, color: AppColors.textHint)),
            ],
          ),
          const Divider(height: 20, color: AppColors.divider),
          Text(
            report,
            style: AppTextStyles.arabicBody(size: 14),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

class _NoPredictionState extends StatelessWidget {
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
          Icon(Iconsax.cpu, size: 60, color: AppColors.primary.withOpacity(0.25)),
          const SizedBox(height: 16),
          Text('لا تحليلات بعد', style: AppTextStyles.headline3),
          const SizedBox(height: 8),
          Text(
            'أضيفي قراءة صحية ثم اضغطي على "تشغيل التحليل"',
            style: AppTextStyles.arabicBody(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
