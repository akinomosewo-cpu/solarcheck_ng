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

/// Equipment registration screen: records panel/battery/inverter serial
/// numbers against an installer, protecting the user if a warranty claim
/// or theft dispute comes up later. Barcode/QR scanning is stubbed behind
/// a single entry point so a camera-based scanner can be dropped in later
/// without changing the rest of the flow.
class EquipmentPage extends StatelessWidget {
  const EquipmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Equipment Registry', style: AppTextStyles.displayLarge.copyWith(color: AppColors.textPrimary)),
                      const Gap(6),
                      Text('Keep a record of every serial number installed',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ]),
              const Gap(20),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showScanStub(context),
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                    label: const Text('Scan barcode'),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddSheet(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add manually'),
                  ),
                ),
              ]),
              const Gap(20),
              if (state.equipment.isEmpty)
                SectionCard(
                  child: Column(
                    children: [
                      const Icon(Icons.qr_code_2_rounded, color: AppColors.textTertiary, size: 32),
                      const Gap(8),
                      Text('No equipment registered yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              else
                ...state.equipment.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SectionCard(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(16)),
                              child: Icon(_iconFor(item.type), color: AppColors.primary, size: 20),
                            ),
                            const Gap(14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${item.brand} ${item.model}',
                                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                                  const Gap(6),
                                  AppChip(label: item.typeLabel, color: _colorFor(item.type)),
                                  const Gap(6),
                                  Text('S/N ${item.serialNumber} · ${DateFormat.yMMMd().format(item.registeredAt)}',
                                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary, size: 18),
                              onPressed: () => context.read<AppBloc>().add(EquipmentRemoved(item.id)),
                            ),
                          ],
                        ),
                      ),
                    )),
            ],
          );
        },
      ),
    );
  }

  IconData _iconFor(EquipmentType type) {
    switch (type) {
      case EquipmentType.panel:
        return Icons.solar_power_rounded;
      case EquipmentType.battery:
        return Icons.battery_charging_full_rounded;
      case EquipmentType.inverter:
        return Icons.electrical_services_rounded;
      case EquipmentType.chargeController:
        return Icons.memory_rounded;
    }
  }

  Color _colorFor(EquipmentType type) {
    switch (type) {
      case EquipmentType.panel:
        return AppColors.primary;
      case EquipmentType.battery:
        return AppColors.success;
      case EquipmentType.inverter:
        return AppColors.info;
      case EquipmentType.chargeController:
        return AppColors.warning;
    }
  }

  void _showScanStub(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Camera scanning', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
        content: Text(
          'Barcode/QR scanning will be available in a future update. For now, please add the serial number manually.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddSheet(context);
            },
            child: const Text('Add manually'),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => BlocProvider.value(value: context.read<AppBloc>(), child: const _AddEquipmentSheet()),
    );
  }
}

class _AddEquipmentSheet extends StatefulWidget {
  const _AddEquipmentSheet();
  @override
  State<_AddEquipmentSheet> createState() => _AddEquipmentSheetState();
}

class _AddEquipmentSheetState extends State<_AddEquipmentSheet> {
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();
  EquipmentType _type = EquipmentType.panel;
  String? _error;

  @override
  void dispose() {
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _serialCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_brandCtrl.text.trim().isEmpty || _serialCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Brand and serial number are required');
      return;
    }
    context.read<AppBloc>().add(EquipmentRegistered(EquipmentItem(
          id: _uuid.v4(),
          type: _type,
          brand: _brandCtrl.text.trim(),
          model: _modelCtrl.text.trim(),
          serialNumber: _serialCtrl.text.trim(),
          registeredAt: DateTime.now(),
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
          Text('Register Equipment', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary)),
          const Gap(20),
          Wrap(
            spacing: 8,
            children: EquipmentType.values.map((t) {
              final selected = _type == t;
              return ChoiceChip(
                label: Text(_label(t)),
                selected: selected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceElevated,
                labelStyle: AppTextStyles.labelMedium.copyWith(color: selected ? Colors.white : AppColors.textPrimary),
                onSelected: (_) => setState(() => _type = t),
              );
            }).toList(),
          ),
          const Gap(12),
          TextField(
            controller: _brandCtrl,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Brand (e.g. Jinko, Luminous)'),
          ),
          const Gap(12),
          TextField(
            controller: _modelCtrl,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Model (optional)'),
          ),
          const Gap(12),
          TextField(
            controller: _serialCtrl,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(hintText: 'Serial number'),
          ),
          if (_error != null) ...[
            const Gap(8),
            Text(_error!, style: AppTextStyles.labelMedium.copyWith(color: AppColors.danger)),
          ],
          const Gap(20),
          ElevatedButton(onPressed: _submit, child: const Text('Save equipment')),
        ],
      ),
    );
  }

  String _label(EquipmentType t) {
    switch (t) {
      case EquipmentType.panel:
        return 'Panel';
      case EquipmentType.battery:
        return 'Battery';
      case EquipmentType.inverter:
        return 'Inverter';
      case EquipmentType.chargeController:
        return 'Charge Controller';
    }
  }
}
