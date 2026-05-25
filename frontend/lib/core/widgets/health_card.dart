import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class HealthMetricCard extends StatelessWidget {
  final String titleAr;
  final String value;
  final String unit;
  final IconData icon;
  final Color? color;
  final String? status;
  final VoidCallback? onTap;

  const HealthMetricCard({
    super.key,
    required this.titleAr,
    required this.value,
    required this.unit,
    required this.icon,
    this.color,
    this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: c.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: c, size: 16),
                ),
                if (status != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: c.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status!,
                      style: AppTextStyles.arabicCaption(color: c, size: 10),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: AppTextStyles.number(size: 20, color: AppColors.textPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(unit, style: AppTextStyles.arabicCaption(size: 10)),
                    ),
                  ],
                ),
                Text(titleAr, style: AppTextStyles.arabicCaption()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RiskBadge extends StatelessWidget {
  final String riskLevel;
  final double? score;
  final bool large;

  const RiskBadge({
    super.key,
    required this.riskLevel,
    this.score,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.riskColor(riskLevel);
    final label = AppColors.riskLabelAr(riskLevel);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: large ? 10 : 7,
            height: large ? 10 : 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            score != null ? '$label (${(score! * 100).toStringAsFixed(0)}%)' : label,
            style: AppTextStyles.arabicBody(
              color: color,
              size: large ? 14 : 11,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class WeladtiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const WeladtiCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? AppColors.surface : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
        ),
        child: child,
      ),
    );
  }
}
