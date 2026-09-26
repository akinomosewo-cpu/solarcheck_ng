import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../../core/logic/solar_sizing_calculator.dart';
import '../../data/mock_data.dart';
import '../../domain/models.dart';

const _uuid = Uuid();

abstract class AppEvent extends Equatable {
  const AppEvent();
  @override
  List<Object?> get props => [];
}

class AppStarted extends AppEvent {
  const AppStarted();
}

// --- Sizing ---
class ApplianceAdded extends AppEvent {
  final Appliance appliance;
  const ApplianceAdded(this.appliance);
  @override
  List<Object?> get props => [appliance];
}

class ApplianceRemoved extends AppEvent {
  final int index;
  const ApplianceRemoved(this.index);
  @override
  List<Object?> get props => [index];
}

class BackupDaysChanged extends AppEvent {
  final int days;
  const BackupDaysChanged(this.days);
  @override
  List<Object?> get props => [days];
}

// --- Equipment ---
class EquipmentRegistered extends AppEvent {
  final EquipmentItem item;
  const EquipmentRegistered(this.item);
  @override
  List<Object?> get props => [item];
}

class EquipmentRemoved extends AppEvent {
  final String id;
  const EquipmentRemoved(this.id);
  @override
  List<Object?> get props => [id];
}

// --- Monitoring ---
class PerformanceLogged extends AppEvent {
  final PerformanceLog log;
  const PerformanceLogged(this.log);
  @override
  List<Object?> get props => [log];
}

// --- Referral / lead flow ---
class QuoteRequested extends AppEvent {
  final String installerId;
  const QuoteRequested(this.installerId);
  @override
  List<Object?> get props => [installerId];
}

class AppState extends Equatable {
  final List<Appliance> appliances;
  final int backupDays;
  final SizingResult sizingResult;
  final List<Installer> installers;
  final List<EquipmentItem> equipment;
  final List<PerformanceLog> performanceLogs;
  final List<ReferralLead> leads;

  const AppState({
    this.appliances = const [],
    this.backupDays = 1,
    this.sizingResult = SizingResult.empty,
    this.installers = const [],
    this.equipment = const [],
    this.performanceLogs = const [],
    this.leads = const [],
  });

  AppState copyWith({
    List<Appliance>? appliances,
    int? backupDays,
    SizingResult? sizingResult,
    List<Installer>? installers,
    List<EquipmentItem>? equipment,
    List<PerformanceLog>? performanceLogs,
    List<ReferralLead>? leads,
  }) {
    return AppState(
      appliances: appliances ?? this.appliances,
      backupDays: backupDays ?? this.backupDays,
      sizingResult: sizingResult ?? this.sizingResult,
      installers: installers ?? this.installers,
      equipment: equipment ?? this.equipment,
      performanceLogs: performanceLogs ?? this.performanceLogs,
      leads: leads ?? this.leads,
    );
  }

  @override
  List<Object?> get props => [
        appliances,
        backupDays,
        sizingResult,
        installers,
        equipment,
        performanceLogs,
        leads,
      ];
}

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppState()) {
    on<AppStarted>((e, emit) {
      emit(state.copyWith(installers: MockData.installers));
    });

    on<ApplianceAdded>((e, emit) {
      final appliances = [...state.appliances, e.appliance];
      emit(state.copyWith(
        appliances: appliances,
        sizingResult: _recalculate(appliances, state.backupDays),
      ));
    });

    on<ApplianceRemoved>((e, emit) {
      final appliances = [...state.appliances]..removeAt(e.index);
      emit(state.copyWith(
        appliances: appliances,
        sizingResult: _recalculate(appliances, state.backupDays),
      ));
    });

    on<BackupDaysChanged>((e, emit) {
      emit(state.copyWith(
        backupDays: e.days,
        sizingResult: _recalculate(state.appliances, e.days),
      ));
    });

    on<EquipmentRegistered>((e, emit) {
      emit(state.copyWith(equipment: [...state.equipment, e.item]));
    });

    on<EquipmentRemoved>((e, emit) {
      emit(state.copyWith(
        equipment: state.equipment.where((i) => i.id != e.id).toList(),
      ));
    });

    on<PerformanceLogged>((e, emit) {
      final logs = [...state.performanceLogs, e.log]
        ..sort((a, b) => b.date.compareTo(a.date));
      emit(state.copyWith(performanceLogs: logs));
    });

    on<QuoteRequested>((e, emit) {
      final lead = ReferralLead(
        id: _uuid.v4(),
        installerId: e.installerId,
        createdAt: DateTime.now(),
      );
      emit(state.copyWith(leads: [...state.leads, lead]));
    });
  }

  static SizingResult _recalculate(List<Appliance> appliances, int backupDays) {
    if (appliances.isEmpty) return SizingResult.empty;
    return SolarSizingCalculator.calculate(
      appliances: appliances,
      backupDays: backupDays,
    );
  }
}
