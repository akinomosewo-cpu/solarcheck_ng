import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_theme.dart';
import '../blocs/app_bloc.dart';
import '../widgets/section_card.dart';
import 'equipment_page.dart';
import 'installers_page.dart';
import 'monitoring_page.dart';
import 'sizing_page.dart';

/// App shell holding the bottom navigation between the four core
/// features: dashboard overview, sizing calculator, installer directory
/// and equipment registry / performance monitor.
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  static const _pages = [
    _DashboardPage(),
    SizingPage(),
    InstallersPage(),
    EquipmentPage(),
    MonitoringPage(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<AppBloc>().add(const AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calculate_outlined), selectedIcon: Icon(Icons.calculate_rounded), label: 'Size'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront_rounded), label: 'Installers'),
          NavigationDestination(icon: Icon(Icons.qr_code_2_outlined), selectedIcon: Icon(Icons.qr_code_2_rounded), label: 'Equipment'),
          NavigationDestination(icon: Icon(Icons.show_chart_outlined), selectedIcon: Icon(Icons.show_chart_rounded), label: 'Monitor'),
        ],
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: AppColors.background,
                title: Row(children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 18),
                  ),
                  const Gap(10),
                  Text('SolarCheck NG', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary)),
                ]),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Gap(12),
                    Text('Welcome back', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    const Gap(2),
                    Text('Your solar dashboard', style: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimary)),
                    const Gap(20),
                    Row(children: [
                      _StatCard(label: 'Appliances', value: state.appliances.length.toString(), color: AppColors.primary),
                      const Gap(12),
                      _StatCard(label: 'Equipment', value: state.equipment.length.toString(), color: AppColors.success),
                      const Gap(12),
                      _StatCard(label: 'Leads sent', value: state.leads.length.toString(), color: AppColors.info),
                    ]),
                    const Gap(28),
                    Text('What you can do', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary)),
                    const Gap(14),
                    const _FeatureCard(icon: Icons.calculate_rounded, label: 'Size your solar system', color: AppColors.primary),
                    const Gap(10),
                    const _FeatureCard(icon: Icons.storefront_rounded, label: 'Compare installer quotes', color: AppColors.success),
                    const Gap(10),
                    const _FeatureCard(icon: Icons.qr_code_2_rounded, label: 'Register panel & battery serials', color: AppColors.info),
                    const Gap(10),
                    const _FeatureCard(icon: Icons.show_chart_rounded, label: 'Monitor system performance', color: AppColors.warning),
                    const Gap(28),
                    if (state.sizingResult.numberOfPanels > 0) ...[
                      SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(children: [
                              AppChip(label: 'Latest', color: AppColors.primary, icon: Icons.bolt_rounded),
                            ]),
                            const Gap(10),
                            Text('Your last sizing result', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary)),
                            const Gap(8),
                            Text(
                              '${state.sizingResult.numberOfPanels} panels · ${state.sizingResult.numberOfBatteries} batteries · '
                              '${state.sizingResult.recommendedInverterWatts.round()}W inverter',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Gap(24),
                    ],
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(22), boxShadow: AppColors.cardShadow),
          child: Column(children: [
            Text(value, style: AppTextStyles.displayMedium.copyWith(color: color)),
            const Gap(4),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
          ]),
        ),
      );
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _FeatureCard({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), boxShadow: AppColors.cardShadow),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 18),
          ),
          const Gap(14),
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18),
        ]),
      );
}
