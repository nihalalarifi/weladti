import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/health_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
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
    final auth = ref.watch(authStateProvider);
    final health = ref.watch(healthProvider);
    final dashboard = health.dashboard;
    final prediction = health.latestPrediction;
    final vitals = dashboard?['latest_vitals'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(healthProvider.notifier).loadDashboard();
          await ref.read(healthProvider.notifier).loadLatestPrediction();
        },
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            // ── App Bar ─────────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 160,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'مرحباً، ${auth.fullName.split(' ').first} 🌸',
                                    style: AppTextStyles.whiteHeadline,
                                  ),
                                  Text(
                                    'كيف حالكِ اليوم؟',
                                    style: AppTextStyles.whitebody,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Iconsax.notification, color: Colors.white),
                                    onPressed: () {},
                                  ),
                                  GestureDetector(
                                    onTap: () => context.push('/settings'),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.settings_rounded, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Risk Card ──────────────────────────────────────────────
                  if (prediction != null)
                    _RiskCard(prediction: prediction)
                        .animate()
                        .slideY(begin: -0.1)
                        .fadeIn(duration: 400.ms),

                  const SizedBox(height: 20),

                  // ── Quick Actions ──────────────────────────────────────────
                  Text('الإجراءات السريعة', style: AppTextStyles.headline3),
                  const SizedBox(height: 12),
                  _QuickActions(),

                  const SizedBox(height: 24),

                  // ── Vitals Grid ────────────────────────────────────────────
                  Text('آخر القراءات', style: AppTextStyles.headline3),
                  const SizedBox(height: 12),
                  _VitalsGrid(vitals: vitals),

                  const SizedBox(height: 24),

                  // ── BP Chart ───────────────────────────────────────────────
                  if (dashboard?['bp_trend'] != null && (dashboard!['bp_trend'] as List).isNotEmpty)
                    _BPChart(data: dashboard['bp_trend'] as List),

                  const SizedBox(height: 24),

                  // ── Alerts ─────────────────────────────────────────────────
                  if (prediction != null &&
                      (prediction['alerts'] as List?)?.isNotEmpty == true)
                    _AlertsSection(alerts: prediction['alerts'] as List),

                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }
}

class _RiskCard extends StatelessWidget {
  final Map<String, dynamic> prediction;
  const _RiskCard({required this.prediction});

  @override
  Widget build(BuildContext context) {
    final level = prediction['preeclampsia_risk_level'] as String? ?? 'low';
    final score = (prediction['preeclampsia_risk_score'] as num?)?.toDouble() ?? 0;
    final color = AppColors.riskColor(level);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Risk dial
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score,
                  strokeWidth: 8,
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
                Text(
                  '${(score * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.number(size: 16, color: color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('خطر تسمم الحمل', style: AppTextStyles.arabicCaption()),
                const SizedBox(height: 4),
                RiskBadge(riskLevel: level, score: score, large: true),
                const SizedBox(height: 8),
                Text(
                  _adviceText(level),
                  style: AppTextStyles.arabicCaption(size: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _adviceText(String level) {
    switch (level) {
      case 'low':
        return 'حملكِ بخير — واصلي المراقبة اليومية';
      case 'moderate':
        return 'راقبي الأعراض بعناية وراجعي طبيبك';
      case 'high':
        return 'اتصلي بطبيبك اليوم للمراجعة';
      case 'critical':
        return '🚨 اذهبي للطوارئ فوراً';
      default:
        return '';
    }
  }
}

class _QuickActions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = [
      (icon: Iconsax.heart, label: 'قياس جديد', route: '/health/input', color: AppColors.primary),
      (icon: Iconsax.weight, label: 'الميزان الذكي', route: '/scale', color: const Color(0xFF00BCD4)),
      (icon: Iconsax.cpu, label: 'تحليل ذكي', route: '/predictions', color: const Color(0xFF9C27B0)),
      (icon: Iconsax.message, label: 'مساعدة نور', route: '/chatbot', color: AppColors.accent),
    ];

    return Row(
      children: actions.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: () => context.push(a.route),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: a.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: a.color.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(a.icon, color: a.color, size: 24),
                  const SizedBox(height: 6),
                  Text(
                    a.label,
                    style: AppTextStyles.arabicCaption(color: a.color, size: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _VitalsGrid extends StatelessWidget {
  final Map<String, dynamic> vitals;
  const _VitalsGrid({required this.vitals});

  @override
  Widget build(BuildContext context) {
    String bpValue = '--/--';
    String bpStatus;
    final systolic = vitals['systolic_bp'] as num?;
    final diastolic = vitals['diastolic_bp'] as num?;
    if (systolic != null && diastolic != null) {
      bpValue = '${systolic.toInt()}/${diastolic.toInt()}';
    }
    if (systolic != null && systolic >= 160) {
      bpStatus = 'حرج';
    } else if (systolic != null && systolic >= 140) {
      bpStatus = 'مرتفع';
    } else {
      bpStatus = 'طبيعي';
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: [
        HealthMetricCard(
          titleAr: 'ضغط الدم',
          value: bpValue,
          unit: 'mmHg',
          icon: Iconsax.heart,
          color: systolic != null && systolic >= 140 ? AppColors.riskHigh : AppColors.riskLow,
          status: bpStatus,
        ),
        HealthMetricCard(
          titleAr: 'معدل ضربات القلب',
          value: vitals['heart_rate']?.toStringAsFixed(0) ?? '--',
          unit: 'نبضة/د',
          icon: Iconsax.activity,
          color: AppColors.primary,
        ),
        HealthMetricCard(
          titleAr: 'الوزن الحالي',
          value: vitals['weight_kg']?.toStringAsFixed(1) ?? '--',
          unit: 'كغ',
          icon: Iconsax.weight,
          color: const Color(0xFF00BCD4),
        ),
        HealthMetricCard(
          titleAr: 'نسبة الماء',
          value: vitals['body_water_pct']?.toStringAsFixed(1) ?? '--',
          unit: '%',
          icon: Iconsax.drop,
          color: const Color(0xFF2196F3),
          status: (vitals['body_water_pct'] as num? ?? 0) > 60 ? 'مرتفع' : 'طبيعي',
        ),
      ],
    );
  }
}

class _BPChart extends StatelessWidget {
  final List data;
  const _BPChart({required this.data});

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
          Text('منحنى ضغط الدم', style: AppTextStyles.headline3),
          const SizedBox(height: 4),
          Text('آخر 7 قراءات', style: AppTextStyles.caption),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.border.withOpacity(0.5),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: AppTextStyles.tiny,
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= data.length) return const SizedBox();
                        return Text(
                          data[idx]['date'] ?? '',
                          style: AppTextStyles.tiny,
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 60,
                maxY: 180,
                lineBarsData: [
                  // Systolic
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) {
                      final sys = (e.value['systolic'] as num?)?.toDouble() ?? 120;
                      return FlSpot(e.key.toDouble(), sys);
                    }).toList(),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.primary,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.08),
                    ),
                  ),
                  // Diastolic
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) {
                      final dia = (e.value['diastolic'] as num?)?.toDouble() ?? 80;
                      return FlSpot(e.key.toDouble(), dia);
                    }).toList(),
                    isCurved: true,
                    color: AppColors.secondary,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.secondary,
                        strokeWidth: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend('انقباضي', AppColors.primary),
              const SizedBox(width: 20),
              _legend('انبساطي', AppColors.secondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(String label, Color color) => Row(
        children: [
          Container(width: 12, height: 3, color: color),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.arabicCaption()),
        ],
      );
}

class _AlertsSection extends StatelessWidget {
  final List alerts;
  const _AlertsSection({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('التنبيهات', style: AppTextStyles.headline3),
        const SizedBox(height: 12),
        ...alerts.map((alert) {
          final severity = alert['severity'] as String? ?? 'moderate';
          final color = severity == 'critical'
              ? AppColors.riskCritical
              : severity == 'high'
                  ? AppColors.riskHigh
                  : AppColors.riskModerate;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Text(alert['icon'] ?? '⚠️', style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert['title_ar'] ?? '',
                        style: AppTextStyles.arabicBody(color: color, weight: FontWeight.w700),
                      ),
                      Text(
                        alert['message_ar'] ?? '',
                        style: AppTextStyles.arabicCaption(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _BottomNav extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = '/dashboard';

    final items = [
      (icon: Iconsax.home_2,    label: 'الرئيسية', route: '/dashboard'),
      (icon: Iconsax.heart_add, label: 'القياسات', route: '/health/history'),
      (icon: Iconsax.cpu,       label: 'تحليل ذكي', route: '/predictions'),
      (icon: Iconsax.message,   label: 'نور', route: '/chatbot'),
      (icon: Iconsax.setting_2, label: 'إعدادات', route: '/settings'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final selected = location == item.route;
              return GestureDetector(
                onTap: () => context.go(item.route),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: selected ? AppColors.primary : AppColors.textHint,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: AppTextStyles.arabicCaption(
                          color: selected ? AppColors.primary : AppColors.textHint,
                          size: 10,
                          weight: selected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
