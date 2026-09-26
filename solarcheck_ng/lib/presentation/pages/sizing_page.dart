import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../core/logic/solar_sizing_calculator.dart';
import '../../core/theme/app_theme.dart';
import '../blocs/app_bloc.dart';
import '../widgets/section_card.dart';

/// Lets a user build up an appliance load list and immediately see the
/// recommended panel/battery/inverter sizing computed by
/// [SolarSizingCalculator].
class SizingPage extends StatelessWidget {
  const SizingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Text('Solar Sizing', style: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimary)),
              const Gap(6),
              Text('Add your appliances to get a recommended system size',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const Gap(24),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Backup autonomy'),
                    const Gap(12),
                    Wrap(
                      spacing: 8,
                      children: [1, 2, 3].map((d) {
                        final selected = state.backupDays == d;
                        return ChoiceChip(
                          label: Text('$d day${d > 1 ? 's' : ''}'),
                          selected: selected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceElevated,
                          labelStyle: AppTextStyles.labelMedium.copyWith(
                            color: selected ? Colors.white : AppColors.textPrimary,
                          ),
                          onSelected: (_) => context.read<AppBloc>().add(BackupDaysChanged(d)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Gap(16),
              SectionHeader(
                title: 'Appliances (${state.appliances.length})',
                trailing: TextButton.icon(
                  onPressed: () => _showAddApplianceSheet(context),
                  icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                  label: Text('Add', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                ),
              ),
              const Gap(8),
              if (state.appliances.isEmpty)
                SectionCard(
                  child: Column(
                    children: [
                      const Icon(Icons.electrical_services_rounded, color: AppColors.textTertiary, size: 32),
                      const Gap(8),
                      Text('No appliances yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              else
                ...state.appliances.asMap().entries.map((entry) {
                  final i = entry.key;
                  final a = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SectionCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.name, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                                Text(
                                  '${a.watts.toStringAsFixed(0)}W × ${a.quantity} × ${a.hoursPerDay.toStringAsFixed(1)}h/day',
                                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary, size: 18),
                            onPressed: () => context.read<AppBloc>().add(ApplianceRemoved(i)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const Gap(20),
              if (state.appliances.isNotEmpty) _ResultsPanel(result: state.sizingResult),
            ],
          );
        },
      ),
    );
  }

  void _showAddApplianceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(value: context.read<AppBloc>(), child: const _AddApplianceSheet()),
    );
  }
}

class _ResultsPanel extends StatelessWidget {
  final SizingResult result;
  const _ResultsPanel({required this.result});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.decimalPattern();
    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 20),
            ),
            const Gap(10),
            Text('Recommended System', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary)),
          ]),
          const Gap(18),
          _ResultRow(label: 'Daily energy need', value: '${currency.format(result.totalDailyEnergyWh.round())} Wh'),
          _ResultRow(label: 'Connected load', value: '${currency.format(result.totalLoadWatts.round())} W'),
          _ResultRow(label: 'Inverter size', value: '${currency.format(result.recommendedInverterWatts.round())} W'),
          _ResultRow(label: 'Solar panels', value: '${result.numberOfPanels} × 400W panels'),
          _ResultRow(label: 'Battery bank', value: '${result.numberOfBatteries} × 200Ah batteries'),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _AddApplianceSheet extends StatefulWidget {
  const _AddApplianceSheet();
  @override
  State<_AddApplianceSheet> createState() => _AddApplianceSheetState();
}

class _AddApplianceSheetState extends State<_AddApplianceSheet> {
  final _nameCtrl = TextEditingController();
  final _wattsCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController(text: '4');
  final _qtyCtrl = TextEditingController(text: '1');
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _wattsCtrl.dispose();
    _hoursCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final watts = double.tryParse(_wattsCtrl.text.trim());
    final hours = double.tryParse(_hoursCtrl.text.trim());
    final qty = int.tryParse(_qtyCtrl.text.trim());

    if (name.isEmpty || watts == null || watts <= 0 || hours == null || hours <= 0 || hours > 24 || qty == null || qty <= 0) {
      setState(() => _error = 'Enter a valid name, wattage, hours (≤24) and quantity');
      return;
    }

    context.read<AppBloc>().add(ApplianceAdded(Appliance(
          name: name,
          watts: watts,
          hoursPerDay: hours,
          quantity: qty,
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
          Text('Add Appliance', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary)),
          const Gap(20),
          TextField(
            controller: _nameCtrl,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'e.g. Refrigerator'),
          ),
          const Gap(12),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _wattsCtrl,
                keyboardType: TextInputType.number,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(hintText: 'Watts'),
              ),
            ),
            const Gap(12),
            Expanded(
              child: TextField(
                controller: _hoursCtrl,
                keyboardType: TextInputType.number,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(hintText: 'Hours/day'),
              ),
            ),
          ]),
          const Gap(12),
          TextField(
            controller: _qtyCtrl,
            keyboardType: TextInputType.number,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Quantity'),
          ),
          if (_error != null) ...[
            const Gap(8),
            Text(_error!, style: AppTextStyles.labelMedium.copyWith(color: AppColors.danger)),
          ],
          const Gap(20),
          ElevatedButton(onPressed: _submit, child: const Text('Add to load list')),
        ],
      ),
    );
  }
}
