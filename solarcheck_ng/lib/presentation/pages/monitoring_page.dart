import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../blocs/app_bloc.dart';
import '../widgets/section_card.dart';

const _uuid = Uuid();

/// Post-installation performance monitoring. Users log daily energy
/// production and battery state of charge; this screen charts the trend
/// so a silently degrading system (a common installer-accountability
/// complaint) becomes visible early.
class MonitoringPage extends StatelessWidget {
  const MonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          final logs = state.performanceLogs;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Performance Monitor', style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary)),
                      const Gap(4),
                      Text('Track your system so problems get caught early',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 28),
                  onPressed: () => _showLogSheet(context),
                ),
              ]),
              const Gap(16),
              if (logs.isEmpty)
                SectionCard(
                  child: Column(
                    children: [
                      const Icon(Icons.show_chart_rounded, color: AppColors.textTertiary, size: 32),
                      const Gap(8),
                      Text('No readings logged yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                      const Gap(4),
                      Text('Tap + to log today\'s energy output', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                )
              else ...[
                SectionCard(
                  padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
                  child: SizedBox(
                    height: 180,
                    child: LineChart(_buildChartData(logs)),
                  ),
                ),
                const Gap(16),
                Text('Log history', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
                const Gap(8),
                ...logs.map((log) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SectionCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(DateFormat.yMMMd().format(log.date),
                                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                                  Text('Battery ${log.batteryStateOfChargePercent.toStringAsFixed(0)}%',
                                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                                  if (log.note != null && log.note!.isNotEmpty)
                                    Text(log.note!, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
                                ],
                              ),
                            ),
                            Text('${log.energyProducedKwh.toStringAsFixed(1)} kWh',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }

  LineChartData _buildChartData(List<PerformanceLog> logs) {
    final ordered = [...logs]..sort((a, b) => a.date.compareTo(b.date));
    final spots = ordered
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.energyProducedKwh))
        .toList();
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.12)),
        ),
      ],
    );
  }

  void _showLogSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(value: context.read<AppBloc>(), child: const _AddLogSheet()),
    );
  }
}

class _AddLogSheet extends StatefulWidget {
  const _AddLogSheet();
  @override
  State<_AddLogSheet> createState() => _AddLogSheetState();
}

class _AddLogSheetState extends State<_AddLogSheet> {
  final _energyCtrl = TextEditingController();
  final _socCtrl = TextEditingController(text: '80');
  final _noteCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _energyCtrl.dispose();
    _socCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final energy = double.tryParse(_energyCtrl.text.trim());
    final soc = double.tryParse(_socCtrl.text.trim());
    if (energy == null || energy < 0 || soc == null || soc < 0 || soc > 100) {
      setState(() => _error = 'Enter a valid energy (kWh) and battery % (0-100)');
      return;
    }
    context.read<AppBloc>().add(PerformanceLogged(PerformanceLog(
          id: _uuid.v4(),
          date: DateTime.now(),
          energyProducedKwh: energy,
          batteryStateOfChargePercent: soc,
          note: _noteCtrl.text.trim(),
        )));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Log Today\'s Performance', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary)),
          const Gap(20),
          TextField(
            controller: _energyCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Energy produced (kWh)'),
          ),
          const Gap(12),
          TextField(
            controller: _socCtrl,
            keyboardType: TextInputType.number,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Battery state of charge (%)'),
          ),
          const Gap(12),
          TextField(
            controller: _noteCtrl,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Note (optional)'),
          ),
          if (_error != null) ...[
            const Gap(8),
            Text(_error!, style: AppTextStyles.labelMedium.copyWith(color: AppColors.danger)),
          ],
          const Gap(20),
          ElevatedButton(onPressed: _submit, child: const Text('Save log')),
        ],
      ),
    );
  }
}
