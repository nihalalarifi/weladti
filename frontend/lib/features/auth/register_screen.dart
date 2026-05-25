import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_button.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authStateProvider.notifier).register({
      'full_name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': _passCtrl.text,
      'role': 'patient',
    });
    if (mounted && ok) {
      context.go('/profile-setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary),
          onPressed: () => context.go('/auth/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Text(
                  'إنشاء حساب جديد',
                  style: AppTextStyles.display,
                  textAlign: TextAlign.center,
                ).animate().fadeIn().slideY(begin: -0.1),

                const SizedBox(height: 8),

                Text(
                  'ابدئي رحلة حملكِ الآمنة مع ولادتي 🌸',
                  style: AppTextStyles.arabicBody(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ).animate(delay: 100.ms).fadeIn(),

                const SizedBox(height: 32),

                _buildField(
                  controller: _nameCtrl,
                  label: 'الاسم الكامل',
                  icon: Icons.person_rounded,
                  validator: (v) => (v?.isNotEmpty ?? false) ? null : 'الاسم مطلوب',
                ).animate(delay: 150.ms).slideX(begin: -0.1).fadeIn(),

                const SizedBox(height: 16),

                _buildField(
                  controller: _emailCtrl,
                  label: 'البريد الإلكتروني',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v?.contains('@') ?? false) ? null : 'بريد غير صحيح',
                ).animate(delay: 200.ms).slideX(begin: -0.1).fadeIn(),

                const SizedBox(height: 16),

                _buildField(
                  controller: _passCtrl,
                  label: 'كلمة المرور',
                  icon: Icons.lock_rounded,
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) => (v?.length ?? 0) >= 8 ? null : 'يجب أن تكون 8 أحرف على الأقل',
                ).animate(delay: 250.ms).slideX(begin: -0.1).fadeIn(),

                const SizedBox(height: 12),

                if (state.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.riskHigh.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      state.error!,
                      style: AppTextStyles.arabicBody(color: AppColors.riskHigh),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 24),

                GradientButton(
                  label: 'إنشاء الحساب',
                  onTap: _register,
                  isLoading: state.isLoading,
                ).animate(delay: 300.ms).slideY(begin: 0.2).fadeIn(),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => context.go('/auth/login'),
                  child: Text(
                    'لديكِ حساب بالفعل؟ سجّلي الدخول',
                    style: AppTextStyles.arabicBody(color: AppColors.primary),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      textDirection: TextDirection.rtl,
      style: AppTextStyles.arabicBody(),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.arabicBody(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        suffixIcon: suffix,
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
      ),
    );
  }
}
