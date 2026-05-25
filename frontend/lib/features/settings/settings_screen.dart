import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user ?? {};
    final name = user['full_name'] ?? '--';
    final email = user['email'] ?? '--';
    final phone = user['phone'] ?? '--';
    final bloodType = user['blood_type'] ?? '--';
    final height = user['height_cm'];
    final preWeight = user['pre_pregnancy_weight'];
    final dueDate = user['due_date'] ?? '--';
    final doctorName = user['doctor_name'] ?? '--';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('الإعدادات', style: AppTextStyles.headline2),
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

            // ── Profile Header ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppTextStyles.whiteHeadline),
                        const SizedBox(height: 4),
                        Text(email, style: AppTextStyles.whitebody),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 24),

            // ── Personal Info ─────────────────────────────────────────────
            _SectionTitle(title: 'المعلومات الشخصية'),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _InfoRow(icon: Iconsax.user, label: 'الاسم الكامل', value: name),
                _InfoRow(icon: Iconsax.sms, label: 'البريد الإلكتروني', value: email),
                _InfoRow(icon: Iconsax.call, label: 'رقم الجوال', value: phone),
                _InfoRow(icon: Iconsax.drop, label: 'فصيلة الدم', value: bloodType, isLast: true),
              ],
            ).animate(delay: 100.ms).fadeIn(),

            const SizedBox(height: 20),

            // ── Pregnancy Info ────────────────────────────────────────────
            _SectionTitle(title: 'معلومات الحمل'),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _InfoRow(
                  icon: Iconsax.weight,
                  label: 'الطول',
                  value: height != null ? '${height.toStringAsFixed(0)} سم' : '--',
                ),
                _InfoRow(
                  icon: Iconsax.weight,
                  label: 'الوزن قبل الحمل',
                  value: preWeight != null ? '${preWeight.toStringAsFixed(1)} كغ' : '--',
                ),
                _InfoRow(
                  icon: Iconsax.calendar,
                  label: 'تاريخ الولادة المتوقع',
                  value: dueDate != '--' ? _formatDate(dueDate) : '--',
                ),
                _InfoRow(
                  icon: Iconsax.hospital,
                  label: 'الطبيب / الطبيبة',
                  value: doctorName,
                  isLast: true,
                ),
              ],
            ).animate(delay: 150.ms).fadeIn(),

            const SizedBox(height: 20),

            // ── Risk Factors ──────────────────────────────────────────────
            _SectionTitle(title: 'عوامل الخطر'),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _BoolRow(
                  icon: Iconsax.heart,
                  label: 'تاريخ ارتفاع الضغط',
                  value: user['has_hypertension_history'] == true,
                ),
                _BoolRow(
                  icon: Iconsax.warning_2,
                  label: 'تسمم حمل سابق',
                  value: user['had_preeclampsia_before'] == true,
                ),
                _BoolRow(
                  icon: Iconsax.people,
                  label: 'حمل متعدد',
                  value: user['is_multiple_pregnancy'] == true,
                ),
                _BoolRow(
                  icon: Iconsax.health,
                  label: 'تاريخ السكري',
                  value: user['has_diabetes_history'] == true,
                  isLast: true,
                ),
              ],
            ).animate(delay: 200.ms).fadeIn(),

            const SizedBox(height: 20),

            // ── App Settings ──────────────────────────────────────────────
            _SectionTitle(title: 'إعدادات التطبيق'),
            const SizedBox(height: 12),
            _InfoCard(
              children: [
                _ActionRow(
                  icon: Iconsax.edit,
                  label: 'تعديل الملف الشخصي',
                  color: AppColors.primary,
                  onTap: () => context.push('/profile-setup'),
                ),
                _ActionRow(
                  icon: Iconsax.shield_tick,
                  label: 'الخصوصية والأمان',
                  color: AppColors.secondary,
                  onTap: () {},
                ),
                _ActionRow(
                  icon: Iconsax.notification,
                  label: 'إشعارات التطبيق',
                  color: AppColors.accent,
                  onTap: () {},
                  isLast: true,
                ),
              ],
            ).animate(delay: 250.ms).fadeIn(),

            const SizedBox(height: 20),

            // ── Logout ────────────────────────────────────────────────────
            GestureDetector(
              onTap: () => _confirmLogout(context, ref),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.riskHigh.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.riskHigh.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.logout, color: AppColors.riskHigh, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'تسجيل الخروج',
                      style: AppTextStyles.arabicBody(
                        color: AppColors.riskHigh,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: 300.ms).fadeIn(),

            const SizedBox(height: 12),

            // App version
            Center(
              child: Text(
                'ولادتي v1.0.0 — AI Pregnancy Health Platform',
                style: AppTextStyles.arabicCaption(color: AppColors.textHint, size: 11),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      const months = [
        '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      return '${d.day} ${months[d.month]} ${d.year}';
    } catch (_) {
      return date;
    }
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('تسجيل الخروج', style: AppTextStyles.headline3),
        content: Text(
          'هل أنتِ متأكدة من تسجيل الخروج؟',
          style: AppTextStyles.arabicBody(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: AppTextStyles.arabicBody(color: AppColors.textSecondary)),
          ),
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go('/auth/login');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.riskHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'تسجيل الخروج',
                style: AppTextStyles.arabicBody(color: Colors.white, weight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(title, style: AppTextStyles.headline3);
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 12),
              Text(label, style: AppTextStyles.arabicBody(color: AppColors.textSecondary, size: 14)),
              const Spacer(),
              Flexible(
                child: Text(
                  value,
                  style: AppTextStyles.arabicBody(weight: FontWeight.w600, size: 14),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 48, color: AppColors.divider),
      ],
    );
  }
}

class _BoolRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final bool isLast;

  const _BoolRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: AppTextStyles.arabicBody(size: 14)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: value
                      ? AppColors.riskHigh.withOpacity(0.1)
                      : AppColors.riskLow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  value ? 'نعم' : 'لا',
                  style: AppTextStyles.arabicCaption(
                    color: value ? AppColors.riskHigh : AppColors.riskLow,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 48, color: AppColors.divider),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLast;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label, style: AppTextStyles.arabicBody(size: 14)),
                ),
                Icon(Icons.arrow_back_ios_rounded, color: AppColors.textHint, size: 14),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 48, color: AppColors.divider),
      ],
    );
  }
}
