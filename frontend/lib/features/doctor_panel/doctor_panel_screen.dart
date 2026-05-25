import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/health_card.dart';
import '../../providers/health_provider.dart';

class DoctorPanelScreen extends ConsumerStatefulWidget {
  const DoctorPanelScreen({super.key});

  @override
  ConsumerState<DoctorPanelScreen> createState() => _DoctorPanelScreenState();
}

class _DoctorPanelScreenState extends ConsumerState<DoctorPanelScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthProvider.notifier).loadDashboard();
      ref.read(healthProvider.notifier).loadLatestPrediction();
    });
  }

  @override
  Widget build(BuildContext context) {
    final health = ref.watch(healthProvider);
    final prediction = health.latestPrediction;
    final dashboard = health.dashboard;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('لوحة المتابعة الطبية', style: AppTextStyles.headline2),
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
            // Doctor header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0097A7), Color(0xFF00BCD4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.hospital, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('لوحة الطبيب', style: AppTextStyles.whiteHeadline),
                        Text(
                          'مراقبة حالة المريضة في الوقت الحقيقي',
                          style: AppTextStyles.whitebody,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 20),

            // Risk summary
            if (prediction != null)
              _RiskSummaryCard(prediction: prediction).animate(delay: 100.ms).fadeIn(),

            const SizedBox(height: 16),

            // Vitals overview
            if (dashboard != null) ...[
              _VitalsOverviewCard(vitals: dashboard['latest_vitals'] as Map<String, dynamic>? ?? {})
                  .animate(delay: 200.ms).fadeIn(),
              const SizedBox(height: 16),
            ],

            // Clinical alerts section
            if (prediction != null && (prediction['alerts'] as List?)?.isNotEmpty == true)
              _ClinicalAlertsCard(alerts: prediction['alerts'] as List).animate(delay: 300.ms).fadeIn(),

            const SizedBox(height: 16),

            // Action cards
            _QuickActionsCard().animate(delay: 400.ms).fadeIn(),

            const SizedBox(height: 16),

            // Preeclampsia criteria checker
            _PECriteriaCard(prediction: prediction).animate(delay: 500.ms).fadeIn(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _RiskSummaryCard extends StatelessWidget {
  final Map<String, dynamic> prediction;
  const _RiskSummaryCard({required this.prediction});

  @override
  Widget build(BuildContext context) {
    final level = prediction['preeclampsia_risk_level'] as String? ?? 'low';
    final score = (prediction['preeclampsia_risk_score'] as num?)?.toDouble() ?? 0;

    return WeladtiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('تقييم مخاطر تسمم الحمل', style: AppTextStyles.headline3),
              RiskBadge(riskLevel: level, score: score, large: true),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _riskMetric('تسمم الحمل', score, AppColors.riskColor(level))),
              Expanded(child: _riskMetric(
                'احتباس السوائل',
                (prediction['fluid_retention_risk'] as num?)?.toDouble() ?? 0,
                const Color(0xFF2196F3),
              )),
              Expanded(child: _riskMetric(
                'سكري الحمل',
                (prediction['gestational_diabetes_risk'] as num?)?.toDouble() ?? 0,
                AppColors.secondary,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _riskMetric(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          '${(value * 100).toStringAsFixed(0)}%',
          style: AppTextStyles.number(size: 22, color: color),
        ),
        Text(label, style: AppTextStyles.arabicCaption(), textAlign: TextAlign.center),
      ],
    );
  }
}

class _VitalsOverviewCard extends StatelessWidget {
  final Map<String, dynamic> vitals;
  const _VitalsOverviewCard({required this.vitals});

  @override
  Widget build(BuildContext context) {
    final systolic = vitals['systolic_bp'] as num?;
    final diastolic = vitals['diastolic_bp'] as num?;
    final bpStr = systolic != null && diastolic != null
        ? '${systolic.toInt()}/${diastolic.toInt()}'
        : 'غير متاح';

    Color bpColor = AppColors.riskLow;
    String bpStatus = 'طبيعي ✓';
    if (systolic != null) {
      if (systolic >= 160) { bpColor = AppColors.riskCritical; bpStatus = 'أزمة ضغط ⚠️'; }
      else if (systolic >= 140) { bpColor = AppColors.riskHigh; bpStatus = 'مرتفع ⚠️'; }
    }

    return WeladtiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('العلامات الحيوية الأخيرة', style: AppTextStyles.headline3),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _vitalTile('ضغط الدم', bpStr, 'mmHg', bpColor, bpStatus),
              _vitalTile(
                'معدل القلب',
                vitals['heart_rate']?.toStringAsFixed(0) ?? '--',
                'bpm',
                AppColors.secondary,
                'طبيعي',
              ),
              _vitalTile(
                'الوزن',
                vitals['weight_kg']?.toStringAsFixed(1) ?? '--',
                'كغ',
                const Color(0xFF00BCD4),
                '',
              ),
              _vitalTile(
                'الماء في الجسم',
                vitals['body_water_pct']?.toStringAsFixed(1) ?? '--',
                '%',
                const Color(0xFF2196F3),
                (vitals['body_water_pct'] as num? ?? 0) > 60 ? 'مرتفع ⚠️' : 'طبيعي',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vitalTile(String label, String value, String unit, Color color, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$value $unit',
                  style: AppTextStyles.number(size: 15, color: color),
                ),
              ),
              if (status.isNotEmpty)
                Text(status, style: AppTextStyles.arabicCaption(size: 10, color: color)),
            ],
          ),
          Text(label, style: AppTextStyles.arabicCaption()),
        ],
      ),
    );
  }
}

class _ClinicalAlertsCard extends StatelessWidget {
  final List alerts;
  const _ClinicalAlertsCard({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.riskHigh.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.riskHigh.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.riskHigh),
              const SizedBox(width: 8),
              Text(
                'تنبيهات سريرية (${alerts.length})',
                style: AppTextStyles.headline3,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...alerts.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(a['icon'] ?? '⚠️', style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a['title_ar'] ?? '',
                        style: AppTextStyles.arabicBody(
                          weight: FontWeight.w600,
                          color: AppColors.riskColor(a['severity'] ?? 'moderate'),
                        ),
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

class _QuickActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WeladtiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إجراءات سريعة', style: AppTextStyles.headline3),
          const SizedBox(height: 14),
          Row(
            children: [
              _actionBtn('عرض التاريخ الكامل', Iconsax.document_text, AppColors.primary,
                  () => context.push('/health/history')),
              const SizedBox(width: 12),
              _actionBtn('التحليل الذكي', Iconsax.cpu, AppColors.secondary,
                  () => context.push('/predictions')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(label, style: AppTextStyles.arabicCaption(color: color), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _PECriteriaCard extends StatelessWidget {
  final Map<String, dynamic>? prediction;
  const _PECriteriaCard({this.prediction});

  @override
  Widget build(BuildContext context) {
    final criteria = [
      (label: 'ضغط الدم ≥ 140/90 mmHg', met: _checkBP()),
      (label: 'بروتين في البول (Proteinuria)', met: false),
      (label: 'احتباس سوائل شديد (Edema grade ≥ 2)', met: false),
      (label: 'صداع أو اضطرابات بصرية', met: false),
      (label: 'ألم شرسوفي علوي', met: false),
    ];

    return WeladtiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('معايير تسمم الحمل (ACOG)', style: AppTextStyles.headline3),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'التشخيص يستلزم ضغط مرتفع + أحد المعايير الأخرى',
            style: AppTextStyles.arabicCaption(),
          ),
          const SizedBox(height: 14),
          ...criteria.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(
                      c.met ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: c.met ? AppColors.riskHigh : AppColors.textHint,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        c.label,
                        style: AppTextStyles.arabicBody(
                          size: 13,
                          color: c.met ? AppColors.riskHigh : AppColors.textPrimary,
                          weight: c.met ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  bool _checkBP() {
    if (prediction == null) return false;
    final score = (prediction!['preeclampsia_risk_score'] as num?)?.toDouble() ?? 0;
    return score > 0.3;
  }
}
