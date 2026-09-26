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
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.16),
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
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 17),
                  ),
                  const Gap(10),
                  Text('SolarCheck NG', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.textPrimary)),
                ]),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Gap(8),
                    Row(children: [
                      _StatCard(label: 'Appliances', value: state.appliances.length.toString(), color: AppColors.primary),
                      const Gap(12),
                      _StatCard(label: 'Equipment', value: state.equipment.length.toString(), color: AppColors.success),
                      const Gap(12),
                      _StatCard(label: 'Leads sent', value: state.leads.length.toString(), color: AppColors.warning),
                    ]),
                    const Gap(24),
                    Text('What you can do', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
                    const Gap(12),
                    const _FeatureCard(icon: Icons.calculate_rounded, label: 'Size your solar system', color: AppColors.primary),
                    const Gap(8),
                    const _FeatureCard(icon: Icons.storefront_rounded, label: 'Compare installer quotes', color: AppColors.success),
                    const Gap(8),
                    const _FeatureCard(icon: Icons.qr_code_2_rounded, label: 'Register panel & battery serials', color: AppColors.primary),
                    const Gap(8),
                    const _FeatureCard(icon: Icons.show_chart_rounded, label: 'Monitor system performance', color: AppColors.warning),
                    const Gap(24),
                    if (state.sizingResult.numberOfPanels > 0) ...[
                      SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your last sizing result', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
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
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
          child: Column(children: [
            Text(value, style: AppTextStyles.displaySmall.copyWith(color: color, fontWeight: FontWeight.w800)),
            const Gap(2),
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
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
          const Gap(14),
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary))),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18),
        ]),
      );
}
