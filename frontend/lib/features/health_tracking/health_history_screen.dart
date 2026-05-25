import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_button.dart';
import '../../providers/health_provider.dart';

class HealthHistoryScreen extends ConsumerStatefulWidget {
  const HealthHistoryScreen({super.key});

  @override
  ConsumerState<HealthHistoryScreen> createState() => _HealthHistoryScreenState();
}

class _HealthHistoryScreenState extends ConsumerState<HealthHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthProvider.notifier).loadRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final health = ref.watch(healthProvider);
    final records = health.records;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('سجل القراءات', style: AppTextStyles.headline2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add_circle, color: AppColors.primary),
            onPressed: () => context.push('/health/input'),
          ),
        ],
      ),
      body: records.isEmpty
          ? _EmptyState()
          : RefreshIndicator(
              onRefresh: () => ref.read(healthProvider.notifier).loadRecords(),
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: records.length,
                itemBuilder: (_, i) => _RecordCard(record: records[i] as Map<String, dynamic>)
                    .animate(delay: (i * 50).ms)
                    .slideX(begin: -0.1)
                    .fadeIn(),
              ),
            ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final Map<String, dynamic> record;
  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final systolic = record['systolic_bp'] as num?;
    final diastolic = record['diastolic_bp'] as num?;
    final weight = record['weight_kg'] as num?;
    final hr = record['heart_rate'] as num?;
    final date = DateTime.tryParse(record['recorded_at'] ?? '');
    final formattedDate = date != null
        ? DateFormat('dd/MM/yyyy  HH:mm').format(date.toLocal())
        : '--';

    Color bpColor = AppColors.riskLow;
    String bpStatus = 'طبيعي';
    if (systolic != null) {
      if (systolic >= 160) {
        bpColor = AppColors.riskCritical;
        bpStatus = 'حرج';
      } else if (systolic >= 140) {
        bpColor = AppColors.riskHigh;
        bpStatus = 'مرتفع';
      }
    }

    final hasSymptoms = (record['has_headache'] == true) ||
        (record['has_visual_disturbances'] == true) ||
        (record['has_edema'] == true) ||
        (record['has_proteinuria'] == true);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
        border: hasSymptoms ? Border.all(color: AppColors.riskModerate.withOpacity(0.4)) : null,
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: bpColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Iconsax.heart, color: bpColor, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(formattedDate, style: AppTextStyles.arabicCaption(size: 12)),
                ],
              ),
              if (hasSymptoms)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.riskModerate.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'أعراض مسجّلة',
                    style: AppTextStyles.arabicCaption(color: AppColors.riskModerate, size: 11),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Metrics row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metric(
                systolic != null && diastolic != null
                    ? '${systolic.toInt()}/${diastolic.toInt()}'
                    : '--',
                'ضغط الدم',
                'mmHg',
                bpColor,
              ),
              _divider(),
              _metric(
                hr?.toStringAsFixed(0) ?? '--',
                'القلب',
                'نبضة',
                AppColors.secondary,
              ),
              _divider(),
              _metric(
                weight?.toStringAsFixed(1) ?? '--',
                'الوزن',
                'كغ',
                const Color(0xFF00BCD4),
              ),
            ],
          ),
          if (record['notes'] != null && (record['notes'] as String).isNotEmpty) ...[
            const Divider(height: 24, color: AppColors.divider),
            Text(
              record['notes'] as String,
              style: AppTextStyles.arabicCaption(),
              textDirection: TextDirection.rtl,
            ),
          ],
        ],
      ),
    );
  }

  Widget _metric(String value, String label, String unit, Color color) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.number(size: 18, color: color)),
        Text(unit, style: AppTextStyles.arabicCaption(size: 10)),
        Text(label, style: AppTextStyles.arabicCaption()),
      ],
    );
  }

  Widget _divider() => Container(
        height: 40,
        width: 1,
        color: AppColors.divider,
      );
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.heart_add, size: 72, color: AppColors.primary.withOpacity(0.3)),
            const SizedBox(height: 20),
            Text('لا توجد قراءات بعد', style: AppTextStyles.headline3),
            const SizedBox(height: 8),
            Text(
              'ابدئي بتسجيل أول قراءة صحية لكِ',
              style: AppTextStyles.arabicBody(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'أضيفي قراءة الآن',
              onTap: () => context.push('/health/input'),
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}
