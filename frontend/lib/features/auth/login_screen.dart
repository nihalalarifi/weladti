import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_button.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authStateProvider.notifier).login(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
    if (!mounted) return;
    if (ok) {
      final profileComplete = ref.read(authStateProvider).profileComplete;
      context.go(profileComplete ? '/dashboard' : '/profile-setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Header
                ShaderMask(
                  shaderCallback: (b) => AppColors.primaryGradient.createShader(b),
                  child: Text(
                    'ولادتي',
                    style: AppTextStyles.arabicDisplay(
                      size: 48,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(duration: 500.ms).scale(curve: Curves.elasticOut),

                const SizedBox(height: 8),

                Text(
                  'مرحباً بعودتكِ 🌸',
                  style: AppTextStyles.headline2,
                  textAlign: TextAlign.center,
                ).animate(delay: 100.ms).fadeIn(),

                Text(
                  'سجّلي دخولك لمتابعة صحة حملكِ',
                  style: AppTextStyles.arabicBody(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ).animate(delay: 150.ms).fadeIn(),

                const SizedBox(height: 40),

                // Email field
                _buildField(
                  controller: _emailCtrl,
                  label: 'البريد الإلكتروني',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v?.contains('@') ?? false) ? null : 'بريد إلكتروني غير صحيح',
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
                  validator: (v) => (v?.length ?? 0) >= 6 ? null : 'كلمة المرور قصيرة',
                ).animate(delay: 250.ms).slideX(begin: -0.1).fadeIn(),

                const SizedBox(height: 12),

                if (state.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.riskHigh.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.riskHigh.withOpacity(0.3)),
                    ),
                    child: Text(
                      state.error!,
                      style: AppTextStyles.arabicBody(color: AppColors.riskHigh),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().shake(),

                const SizedBox(height: 24),

                GradientButton(
                  label: 'تسجيل الدخول',
                  onTap: _login,
                  isLoading: state.isLoading,
                ).animate(delay: 300.ms).slideY(begin: 0.2).fadeIn(),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => context.go('/auth/register'),
                  child: RichText(
                    text: TextSpan(
                      text: 'ليس لديكِ حساب؟  ',
                      style: AppTextStyles.arabicBody(color: AppColors.textSecondary),
                      children: [
                        TextSpan(
                          text: 'أنشئي حساباً',
                          style: AppTextStyles.arabicBody(
                            color: AppColors.primary,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.riskHigh),
        ),
      ),
    );
  }
}
