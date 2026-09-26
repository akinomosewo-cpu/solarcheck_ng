import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_theme.dart';
import '../../core/transitions/page_transitions.dart';
import '../blocs/auth_cubit.dart';
import 'home_page.dart';
import 'signup_page.dart';

/// Local-only login screen: validates the entered email/password against
/// credentials previously stored in Hive by [SignUpPage].
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await context.read<AuthCubit>().login(email: _emailCtrl.text, password: _passwordCtrl.text);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (context.read<AuthCubit>().state.status == AuthStatus.authenticated) {
      context.pushReplacementFadeSlide(const HomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) => current.error != null && current.error != previous.error,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 26),
                  ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8), duration: 300.ms),
                  const Gap(24),
                  Text('Welcome back', style: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimary))
                      .animate()
                      .fadeIn(delay: 80.ms, duration: 300.ms)
                      .slideY(begin: 0.15, end: 0, delay: 80.ms, duration: 300.ms),
                  const Gap(6),
                  Text('Log in to your SolarCheck account', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary))
                      .animate()
                      .fadeIn(delay: 140.ms, duration: 300.ms),
                  const Gap(32),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    decoration: const InputDecoration(hintText: 'Email address'),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                  ).animate().fadeIn(delay: 180.ms, duration: 300.ms),
                  const Gap(14),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textTertiary),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 4) ? 'Password must be at least 4 characters' : null,
                  ).animate().fadeIn(delay: 220.ms, duration: 300.ms),
                  const Gap(28),
                  ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                          )
                        : const Text('Log in'),
                  ).animate().fadeIn(delay: 260.ms, duration: 300.ms),
                  const Gap(18),
                  Center(
                    child: TextButton(
                      onPressed: () => context.pushFadeSlide(const SignUpPage()),
                      child: Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          children: [
                            TextSpan(text: 'Sign up', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
