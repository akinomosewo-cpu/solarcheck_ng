import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../../core/transitions/page_transitions.dart';
import '../blocs/auth_cubit.dart';
import 'home_page.dart';
import 'login_page.dart';

/// Animated brand reveal shown for ~1.4s on cold start while the auth
/// session is checked, then routes to the dashboard (already logged in)
/// or the login screen.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    context.read<AuthCubit>().checkSession();
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    final authenticated = context.read<AuthCubit>().state.status == AuthStatus.authenticated;
    context.pushReplacementFadeSlide(authenticated ? const HomePage() : const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 40),
            )
                .animate()
                .scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 350.ms),
            const SizedBox(height: 20),
            Text(
              'SolarCheck NG',
              style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 8),
            Text(
              'Size, verify, monitor.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
