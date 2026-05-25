import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/health_card.dart';
import '../../providers/health_provider.dart';

class SmartScaleScreen extends ConsumerStatefulWidget {
  const SmartScaleScreen({super.key});

  @override
  ConsumerState<SmartScaleScreen> createState() => _SmartScaleScreenState();
}

class _SmartScaleScreenState extends ConsumerState<SmartScaleScreen> {
  bool _measuring = false;

  Future<void> _takeMeasurement() async {
    setState(() => _measuring = true);
    await Future.delayed(const Duration(seconds: 3)); // Simulate scale connection
    await ref.read(healthProvider.notifier).takeScaleMeasurement();
    setState(() => _measuring = false);
  }

  @override
  Widget build(BuildContext context) {
    final health = ref.watch(healthProvider);
    final scaleData = health.scaleData;
    final measurements = scaleData?['measurements'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('الميزان الذكي', style: AppTextStyles.headline2),
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
            // Device status card
            _DeviceCard(isConnected: true).animate().fadeIn(),

            const SizedBox(height: 20),

            if (_measuring)
              _MeasuringAnimation()
            else if (measurements != null)
              _ResultsView(measurements: measurements)
            else
              _ReadyState(),

            const SizedBox(height: 24),

            GradientButton(
              label: _measuring ? 'جارٍ القياس...' : 'ابدئي القياس',
              onTap: _measuring ? null : _takeMeasurement,
              isLoading: _measuring,
              gradient: const LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
              ),
              icon: const Icon(Iconsax.weight, color: Colors.white, size: 18),
            ),

            if (measurements != null) ...[
              const SizedBox(height: 12),
              GradientButton(
                label: 'حفظ القراءة في ملفي',
                onTap: _saveToRecord,
                icon: const Icon(Iconsax.save_2, color: Colors.white, size: 18),
              ),
            ],

            const SizedBox(height: 20),

            // Info card about the device
            _DeviceInfoCard(),
          ],
        ),
      ),
    );
  }

  Future<void> _saveToRecord() async {
    final measurements = ref.read(healthProvider).scaleData?['measurements'] as Map<String, dynamic>?;
    if (measurements == null) return;
    final segmental = measurements['segmental'] as Map<String, dynamic>? ?? {};
    await ref.read(healthProvider.notifier).submitHealthRecord({
      'weight_kg': measurements['weight_kg'],
      'body_fat_pct': measurements['body_fat_pct'],
      'muscle_mass_kg': measurements['muscle_mass_kg'],
      'body_water_pct': measurements['body_water_pct'],
      'visceral_fat_level': measurements['visceral_fat_level'],
      'bone_mass_kg': measurements['bone_mass_kg'],
      'vascular_age': measurements['vascular_age'],
      'heart_rate': measurements['heart_rate'],
      'trunk_fat_pct': segmental['trunk_fat_pct'],
      'left_arm_fat_pct': segmental['left_arm_fat_pct'],
      'right_arm_fat_pct': segmental['right_arm_fat_pct'],
      'left_leg_fat_pct': segmental['left_leg_fat_pct'],
      'right_leg_fat_pct': segmental['right_leg_fat_pct'],
      'data_source': 'smart_scale',
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ قراءة الميزان ✅', style: AppTextStyles.arabicBody(color: Colors.white)),
          backgroundColor: AppColors.riskLow,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}

class _DeviceCard extends StatelessWidget {
  final bool isConnected;
  const _DeviceCard({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isConnected ? AppColors.safeGradient : AppColors.warningGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.weight, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Withings Body Scan',
                  style: AppTextStyles.arabicBody(color: Colors.white, weight: FontWeight.w700),
                ),
                Text(
                  isConnected ? 'متصل ومستعد للقياس' : 'غير متصل',
                  style: AppTextStyles.arabicCaption(color: Colors.white.withOpacity(0.85)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isConnected ? '● متصل' : '○ منقطع',
              style: AppTextStyles.arabicCaption(color: Colors.white, size: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasuringAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.primary,
          ).animate(onPlay: (c) => c.repeat()).rotate(duration: 1.seconds),
          const SizedBox(height: 20),
          Text('جارٍ قراءة بياناتك...', style: AppTextStyles.headline3),
          const SizedBox(height: 8),
          Text(
            'قفي بثبات على الميزان',
            style: AppTextStyles.arabicBody(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ReadyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.weight, size: 64, color: AppColors.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('جاهزة للقياس', style: AppTextStyles.headline3),
          const SizedBox(height: 8),
          Text(
            'اضغطي على "ابدئي القياس" للبدء',
            style: AppTextStyles.arabicBody(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ResultsView extends StatelessWidget {
  final Map<String, dynamic> measurements;
  const _ResultsView({required this.measurements});

  @override
  Widget build(BuildContext context) {
    final bodyWater = (measurements['body_water_pct'] as num?)?.toDouble() ?? 55;
    final bodyFat = (measurements['body_fat_pct'] as num?)?.toDouble() ?? 28;

    return Column(
      children: [
        // Main metrics row
        Row(
          children: [
            Expanded(
              child: _CircleStat(
                value: '${(measurements['weight_kg'] as num?)?.toStringAsFixed(1) ?? '--'}',
                unit: 'كغ',
                label: 'الوزن',
                color: AppColors.primary,
                percent: 0.7,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CircleStat(
                value: '${bodyWater.toStringAsFixed(1)}%',
                unit: '',
                label: 'نسبة الماء',
                color: const Color(0xFF2196F3),
                percent: bodyWater / 100,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CircleStat(
                value: '${bodyFat.toStringAsFixed(1)}%',
                unit: '',
                label: 'الدهون',
                color: AppColors.accent,
                percent: bodyFat / 100,
              ),
            ),
          ],
        ).animate().fadeIn(),

        const SizedBox(height: 16),

        // Detail grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            WeladtiCard(
              padding: const EdgeInsets.all(14),
              child: _statTile(
                Iconsax.activity, 'معدل القلب',
                '${(measurements['heart_rate'] as num?)?.toStringAsFixed(0) ?? '--'} نبضة',
                AppColors.riskHigh,
              ),
            ),
            WeladtiCard(
              padding: const EdgeInsets.all(14),
              child: _statTile(
                Iconsax.hospital, 'الدهون الحشوية',
                '${(measurements['visceral_fat_level'] as num?)?.toStringAsFixed(1) ?? '--'}',
                AppColors.riskModerate,
              ),
            ),
            WeladtiCard(
              padding: const EdgeInsets.all(14),
              child: _statTile(
                Iconsax.strongbox, 'كتلة العضلات',
                '${(measurements['muscle_mass_kg'] as num?)?.toStringAsFixed(1) ?? '--'} كغ',
                const Color(0xFF4CAF50),
              ),
            ),
            WeladtiCard(
              padding: const EdgeInsets.all(14),
              child: _statTile(
                Icons.elderly_rounded, 'العمر الوعائي',
                '${measurements['vascular_age'] ?? '--'} سنة',
                AppColors.secondary,
              ),
            ),
          ],
        ).animate(delay: 200.ms).fadeIn(),

        const SizedBox(height: 16),

        // Body water warning if elevated
        if (bodyWater > 62)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.riskModerate.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.riskModerate.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text('💧', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نسبة الماء مرتفعة',
                        style: AppTextStyles.arabicBody(
                          color: AppColors.riskModerate,
                          weight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'قد يشير إلى احتباس سوائل — راقبي التورم وأخبري طبيبك',
                        style: AppTextStyles.arabicCaption(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate(delay: 300.ms).fadeIn(),
      ],
    );
  }

  Widget _statTile(IconData icon, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const Spacer(),
        Text(value, style: AppTextStyles.number(size: 16, color: AppColors.textPrimary)),
        Text(label, style: AppTextStyles.arabicCaption()),
      ],
    );
  }
}

class _CircleStat extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  final Color color;
  final double percent;

  const _CircleStat({
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 36,
            lineWidth: 6,
            percent: percent.clamp(0.0, 1.0),
            center: Text(
              value,
              style: AppTextStyles.number(size: 13, color: color),
              textAlign: TextAlign.center,
            ),
            progressColor: color,
            backgroundColor: color.withOpacity(0.1),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.arabicCaption()),
        ],
      ),
    );
  }
}

class _DeviceInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 8),
              Text('عن الميزان الذكي', style: AppTextStyles.arabicBody(weight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Withings Body Scan هو ميزان طبي متكامل يقيس تكوين الجسم بدقة عالية. '
            'يُساعد في الكشف المبكر عن احتباس السوائل وزيادة الوزن غير الطبيعية خلال الحمل.',
            style: AppTextStyles.arabicCaption(size: 12),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}
