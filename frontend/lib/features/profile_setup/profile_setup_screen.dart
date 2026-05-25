import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_button.dart';
import '../../providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;

  // Step 1 – Basic info
  final _dobCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _preWeightCtrl = TextEditingController();
  String? _bloodType;

  // Step 2 – Pregnancy info
  final _lmpCtrl = TextEditingController(); // Last menstrual period
  bool _multiple = false;
  bool _prevPE = false;
  bool _hypertension = false;
  bool _diabetes = false;
  int _gravida = 1;
  int _para = 0;

  // Step 3 – Doctor info
  final _doctorNameCtrl = TextEditingController();

  @override
  void dispose() {
    _dobCtrl.dispose();
    _heightCtrl.dispose();
    _preWeightCtrl.dispose();
    _lmpCtrl.dispose();
    _doctorNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 60)),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (d != null) {
      ctrl.text = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _finish() async {
    // Calculate due date from LMP
    String? dueDate;
    if (_lmpCtrl.text.isNotEmpty) {
      try {
        final lmp = DateTime.parse(_lmpCtrl.text);
        final due = lmp.add(const Duration(days: 280));
        dueDate = '${due.year}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    final ok = await ref.read(authStateProvider.notifier).updateProfile({
      'date_of_birth': _dobCtrl.text.isEmpty ? null : _dobCtrl.text,
      'height_cm': double.tryParse(_heightCtrl.text),
      'pre_pregnancy_weight': double.tryParse(_preWeightCtrl.text),
      'blood_type': _bloodType,
      'pregnancy_start_date': _lmpCtrl.text.isEmpty ? null : _lmpCtrl.text,
      'due_date': dueDate,
      'is_multiple_pregnancy': _multiple,
      'had_preeclampsia_before': _prevPE,
      'has_hypertension_history': _hypertension,
      'has_diabetes_history': _diabetes,
      'gravida': _gravida,
      'para': _para,
      'doctor_name': _doctorNameCtrl.text.isEmpty ? null : _doctorNameCtrl.text,
    });
    if (mounted && ok) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  Text(
                    'إعداد ملف الحمل',
                    style: AppTextStyles.whiteHeadline,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'الخطوة ${_step + 1} من 3',
                    style: AppTextStyles.whitebody,
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_step + 1) / 3,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _step == 0
                        ? _buildStep1()
                        : _step == 1
                            ? _buildStep2()
                            : _buildStep3(),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlineButton(
                        label: 'السابق',
                        onTap: () => setState(() => _step--),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GradientButton(
                      label: _step == 2 ? 'ابدئي ✨' : 'التالي',
                      onTap: () {
                        if (_step < 2) {
                          setState(() => _step++);
                        } else {
                          _finish();
                        }
                      },
                      isLoading: ref.watch(authStateProvider).isLoading,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('معلوماتك الأساسية', style: AppTextStyles.headline2),
        const SizedBox(height: 24),
        _dateField(_dobCtrl, 'تاريخ الميلاد', Icons.cake_rounded),
        const SizedBox(height: 16),
        _numField(_heightCtrl, 'الطول (سم)', Icons.height_rounded),
        const SizedBox(height: 16),
        _numField(_preWeightCtrl, 'الوزن قبل الحمل (كغ)', Icons.monitor_weight_rounded),
        const SizedBox(height: 16),
        _bloodTypeSelector(),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('معلومات الحمل', style: AppTextStyles.headline2),
        const SizedBox(height: 24),
        _dateField(_lmpCtrl, 'أول يوم من آخر دورة شهرية', Icons.calendar_today_rounded),
        const SizedBox(height: 20),
        _counterRow('عدد الحمل (Gravida)', _gravida, (v) => setState(() => _gravida = v)),
        const SizedBox(height: 12),
        _counterRow('عدد الولادات (Para)', _para, (v) => setState(() => _para = v)),
        const SizedBox(height: 20),
        _switchRow('حمل متعدد (توأم أو أكثر)', _multiple, (v) => setState(() => _multiple = v)),
        _switchRow('سبق الإصابة بتسمم الحمل', _prevPE, (v) => setState(() => _prevPE = v)),
        _switchRow('تاريخ ارتفاع ضغط الدم', _hypertension, (v) => setState(() => _hypertension = v)),
        _switchRow('تاريخ السكري', _diabetes, (v) => setState(() => _diabetes = v)),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      key: const ValueKey('step3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('معلومات الطبيب', style: AppTextStyles.headline2),
        const SizedBox(height: 8),
        Text(
          'اختياري — يمكنك تخطيه',
          style: AppTextStyles.arabicBody(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        _textField(_doctorNameCtrl, 'اسم الطبيب / الطبيبة', Icons.medical_services_rounded),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 48),
              const SizedBox(height: 12),
              Text('أنتِ جاهزة!', style: AppTextStyles.headline2),
              const SizedBox(height: 8),
              Text(
                'سيبدأ ولادتي في مراقبة صحتك وحماية حملكِ',
                style: AppTextStyles.arabicBody(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dateField(TextEditingController ctrl, String label, IconData icon) {
    return GestureDetector(
      onTap: () => _pickDate(ctrl),
      child: AbsorbPointer(
        child: TextFormField(
          controller: ctrl,
          textDirection: TextDirection.rtl,
          style: AppTextStyles.arabicBody(),
          decoration: _inputDeco(label, icon),
        ),
      ),
    );
  }

  Widget _numField(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      textDirection: TextDirection.ltr,
      style: AppTextStyles.arabicBody(),
      decoration: _inputDeco(label, icon),
    );
  }

  Widget _textField(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      textDirection: TextDirection.rtl,
      style: AppTextStyles.arabicBody(),
      decoration: _inputDeco(label, icon),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.arabicBody(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );

  Widget _bloodTypeSelector() {
    const types = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('فصيلة الدم', style: AppTextStyles.arabicBody(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: types.map((t) {
            final selected = _bloodType == t;
            return ChoiceChip(
              label: Text(t, style: AppTextStyles.label(color: selected ? Colors.white : AppColors.textPrimary)),
              selected: selected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              onSelected: (_) => setState(() => _bloodType = t),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: AppTextStyles.arabicBody())),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _counterRow(String label, int value, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.arabicBody()),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
            ),
            Text('$value', style: AppTextStyles.number(size: 20)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }
}
