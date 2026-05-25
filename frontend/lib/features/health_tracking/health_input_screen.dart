import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_button.dart';
import '../../providers/health_provider.dart';

class HealthInputScreen extends ConsumerStatefulWidget {
  const HealthInputScreen({super.key});

  @override
  ConsumerState<HealthInputScreen> createState() => _HealthInputScreenState();
}

class _HealthInputScreenState extends ConsumerState<HealthInputScreen> {
  final _systolicCtrl = TextEditingController();
  final _diastolicCtrl = TextEditingController();
  final _heartRateCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _gestWeekCtrl = TextEditingController();
  final _fetalMovCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _hasHeadache = false;
  bool _hasVisual = false;
  bool _hasAbdPain = false;
  bool _hasEdema = false;
  bool _hasProteinuria = false;
  int _edemaLevel = 0;

  @override
  void dispose() {
    for (final c in [
      _systolicCtrl, _diastolicCtrl, _heartRateCtrl, _weightCtrl,
      _gestWeekCtrl, _fetalMovCtrl, _notesCtrl
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _submit() async {
    final data = {
      'systolic_bp': double.tryParse(_systolicCtrl.text),
      'diastolic_bp': double.tryParse(_diastolicCtrl.text),
      'heart_rate': double.tryParse(_heartRateCtrl.text),
      'weight_kg': double.tryParse(_weightCtrl.text),
      'gestational_week': int.tryParse(_gestWeekCtrl.text),
      'fetal_movement_count': int.tryParse(_fetalMovCtrl.text),
      'has_headache': _hasHeadache,
      'has_visual_disturbances': _hasVisual,
      'has_upper_abdominal_pain': _hasAbdPain,
      'has_edema': _hasEdema,
      'edema_level': _edemaLevel,
      'has_proteinuria': _hasProteinuria,
      'notes': _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
      'data_source': 'manual',
    };
    data.removeWhere((_, v) => v == null);

    final ok = await ref.read(healthProvider.notifier).submitHealthRecord(data);
    if (mounted && ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ القراءة بنجاح ✅', style: AppTextStyles.arabicBody(color: Colors.white)),
          backgroundColor: AppColors.riskLow,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      context.go('/predictions');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('قراءة صحية جديدة', style: AppTextStyles.headline2),
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
            // ── Blood Pressure ──────────────────────────────────────────────
            _SectionCard(
              icon: Iconsax.heart,
              title: 'ضغط الدم',
              color: AppColors.primary,
              child: Row(
                children: [
                  Expanded(
                    child: _numField(_systolicCtrl, 'الانقباضي', 'mmHg', hint: '120'),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('/', style: TextStyle(fontSize: 28, color: AppColors.textSecondary)),
                  ),
                  Expanded(
                    child: _numField(_diastolicCtrl, 'الانبساطي', 'mmHg', hint: '80'),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 16),

            // ── Heart Rate & Weight ─────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _SectionCard(
                    icon: Iconsax.activity,
                    title: 'ضربات القلب',
                    color: AppColors.secondary,
                    child: _numField(_heartRateCtrl, 'نبضة/دقيقة', 'bpm', hint: '80'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SectionCard(
                    icon: Iconsax.weight,
                    title: 'الوزن',
                    color: const Color(0xFF00BCD4),
                    child: _numField(_weightCtrl, 'كيلوغرام', 'كغ', hint: '70'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 16),

            // ── Pregnancy Week ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _SectionCard(
                    icon: Iconsax.calendar,
                    title: 'الأسبوع الحملي',
                    color: AppColors.accent,
                    child: _numField(_gestWeekCtrl, 'الأسبوع', '', hint: '28'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SectionCard(
                    icon: Icons.child_care_rounded,
                    title: 'حركات الجنين',
                    color: const Color(0xFF4CAF50),
                    child: _numField(_fetalMovCtrl, 'حركة / ساعة', '', hint: '10'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            // ── Symptoms ────────────────────────────────────────────────────
            _SectionCard(
              icon: Iconsax.note,
              title: 'الأعراض',
              color: AppColors.riskHigh,
              child: Column(
                children: [
                  _symptomSwitch('صداع', Iconsax.headphone, _hasHeadache,
                      (v) => setState(() => _hasHeadache = v)),
                  _symptomSwitch('اضطرابات بصرية', Iconsax.eye, _hasVisual,
                      (v) => setState(() => _hasVisual = v)),
                  _symptomSwitch('ألم في البطن العلوي', Iconsax.hospital, _hasAbdPain,
                      (v) => setState(() => _hasAbdPain = v)),
                  _symptomSwitch('تورم / وذمة', Iconsax.drop, _hasEdema,
                      (v) => setState(() => _hasEdema = v)),
                  _symptomSwitch('بروتين في البول', Icons.opacity_rounded, _hasProteinuria,
                      (v) => setState(() => _hasProteinuria = v)),
                  if (_hasEdema) ...[
                    const SizedBox(height: 12),
                    Text('درجة التورم', style: AppTextStyles.arabicBody()),
                    Slider(
                      value: _edemaLevel.toDouble(),
                      min: 0,
                      max: 3,
                      divisions: 3,
                      label: ['لا يوجد', 'خفيف', 'متوسط', 'شديد'][_edemaLevel],
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _edemaLevel = v.toInt()),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 250.ms),

            const SizedBox(height: 16),

            // ── Notes ───────────────────────────────────────────────────────
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              textDirection: TextDirection.rtl,
              style: AppTextStyles.arabicBody(),
              decoration: InputDecoration(
                hintText: 'ملاحظات إضافية (اختياري)...',
                hintStyle: AppTextStyles.arabicBody(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 24),

            GradientButton(
              label: 'حفظ وتحليل',
              onTap: _submit,
              isLoading: state.isLoading,
              icon: const Icon(Iconsax.cpu, color: Colors.white, size: 18),
            ).animate().slideY(begin: 0.2).fadeIn(delay: 350.ms),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _numField(TextEditingController ctrl, String label, String unit, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.arabicCaption()),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: AppTextStyles.number(size: 22),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.number(size: 22, color: AppColors.textHint),
            suffix: unit.isNotEmpty
                ? Text(unit, style: AppTextStyles.arabicCaption(size: 11))
                : null,
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          ),
        ),
      ],
    );
  }

  Widget _symptomSwitch(String label, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: value ? AppColors.riskHigh : AppColors.textHint),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: AppTextStyles.arabicBody())),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.arabicBody(color: color, weight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
