import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_theme.dart';
import '../../core/transitions/page_transitions.dart';
import '../blocs/auth_cubit.dart';
import 'home_page.dart';

/// Local-only sign up screen: stores name/email/password in Hive via
/// [AuthCubit]/[AuthRepository]. No backend call is made.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    await context.read<AuthCubit>().signUp(name: _nameCtrl.text, email: _emailCtrl.text, password: _passwordCtrl.text);
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
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) => current.error != null && current.error != previous.error,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create your account', style: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimary))
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.15, end: 0, duration: 300.ms),
                  const Gap(6),
                  Text('Track your own solar equipment and installer quotes', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary))
                      .animate()
                      .fadeIn(delay: 60.ms, duration: 300.ms),
                  const Gap(28),
                  TextFormField(
                    controller: _nameCtrl,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    decoration: const InputDecoration(hintText: 'Full name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                  ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                  const Gap(14),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    decoration: const InputDecoration(hintText: 'Email address'),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                  ).animate().fadeIn(delay: 140.ms, duration: 300.ms),
                  const Gap(14),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Password (min 4 characters)',
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.textTertiary),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 4) ? 'Password must be at least 4 characters' : null,
                  ).animate().fadeIn(delay: 180.ms, duration: 300.ms),
                  const Gap(28),
                  ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                          )
                        : const Text('Create account'),
                  ).animate().fadeIn(delay: 220.ms, duration: 300.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
