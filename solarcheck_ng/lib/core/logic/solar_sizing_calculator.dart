import 'dart:math';

/// A single household/business appliance entered by the user for load
/// calculation purposes.
class Appliance {
  final String name;
  final double watts;
  final double hoursPerDay;
  final int quantity;

  const Appliance({
    required this.name,
    required this.watts,
    required this.hoursPerDay,
    this.quantity = 1,
  });

  double get dailyEnergyWh => watts * hoursPerDay * quantity;
  double get totalWatts => watts * quantity;

  Appliance copyWith({
    String? name,
    double? watts,
    double? hoursPerDay,
    int? quantity,
  }) {
    return Appliance(
      name: name ?? this.name,
      watts: watts ?? this.watts,
      hoursPerDay: hoursPerDay ?? this.hoursPerDay,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'watts': watts,
        'hoursPerDay': hoursPerDay,
        'quantity': quantity,
      };

  factory Appliance.fromJson(Map<String, dynamic> json) => Appliance(
        name: json['name'] as String,
        watts: (json['watts'] as num).toDouble(),
        hoursPerDay: (json['hoursPerDay'] as num).toDouble(),
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      );
}

/// Result of a solar system sizing calculation.
class SizingResult {
  final double totalDailyEnergyWh;
  final double totalLoadWatts;
  final double recommendedInverterWatts;
  final double requiredArrayWatts;
  final int numberOfPanels;
  final double requiredBatteryCapacityAh;
  final int numberOfBatteries;
  final double batteryBankUsableWh;

  const SizingResult({
    required this.totalDailyEnergyWh,
    required this.totalLoadWatts,
    required this.recommendedInverterWatts,
    required this.requiredArrayWatts,
    required this.numberOfPanels,
    required this.requiredBatteryCapacityAh,
    required this.numberOfBatteries,
    required this.batteryBankUsableWh,
  });

  static const empty = SizingResult(
    totalDailyEnergyWh: 0,
    totalLoadWatts: 0,
    recommendedInverterWatts: 0,
    requiredArrayWatts: 0,
    numberOfPanels: 0,
    requiredBatteryCapacityAh: 0,
    numberOfBatteries: 0,
    batteryBankUsableWh: 0,
  );
}

/// Pure, dependency-free solar system sizing calculator.
///
/// Given a household/office load profile, computes the panel array,
/// battery bank and inverter size needed. Kept free of Flutter imports so
/// it can be unit tested in isolation and reused outside the UI layer.
class SolarSizingCalculator {
  /// Average number of usable peak-sun-hours per day. Nigeria averages
  /// roughly 4.5 - 6.5 depending on region; 5.0 is a safe national default.
  static const double defaultSunHoursPerDay = 5.0;

  /// Round-trip system losses (wiring, inverter conversion, dust, temperature
  /// derating). 0.75 means the array must be oversized by ~33%.
  static const double defaultSystemEfficiency = 0.75;

  /// Fraction of a battery's rated capacity that may be safely discharged.
  /// 0.5 is conservative and appropriate for lead-acid; lithium can go
  /// higher (~0.8-0.9) but 0.5 keeps the recommendation safe by default.
  static const double defaultDepthOfDischarge = 0.5;

  /// Safety margin added on top of the raw connected load when sizing the
  /// inverter, to allow for motor starting surges etc.
  static const double defaultInverterSafetyFactor = 1.25;

  static SizingResult calculate({
    required List<Appliance> appliances,
    int backupDays = 1,
    double systemVoltage = 24,
    double panelWattRating = 400,
    double batteryAhRating = 200,
    double sunHoursPerDay = defaultSunHoursPerDay,
    double systemEfficiency = defaultSystemEfficiency,
    double depthOfDischarge = defaultDepthOfDischarge,
    double inverterSafetyFactor = defaultInverterSafetyFactor,
  }) {
    if (backupDays < 1) {
      throw ArgumentError.value(backupDays, 'backupDays', 'must be at least 1');
    }
    if (systemVoltage <= 0) {
      throw ArgumentError.value(systemVoltage, 'systemVoltage', 'must be > 0');
    }
    if (panelWattRating <= 0) {
      throw ArgumentError.value(panelWattRating, 'panelWattRating', 'must be > 0');
    }
    if (batteryAhRating <= 0) {
      throw ArgumentError.value(batteryAhRating, 'batteryAhRating', 'must be > 0');
    }
    if (sunHoursPerDay <= 0) {
      throw ArgumentError.value(sunHoursPerDay, 'sunHoursPerDay', 'must be > 0');
    }
    if (systemEfficiency <= 0 || systemEfficiency > 1) {
      throw ArgumentError.value(systemEfficiency, 'systemEfficiency', 'must be in (0, 1]');
    }
    if (depthOfDischarge <= 0 || depthOfDischarge > 1) {
      throw ArgumentError.value(depthOfDischarge, 'depthOfDischarge', 'must be in (0, 1]');
    }

    if (appliances.isEmpty) return SizingResult.empty;

    final totalDailyEnergyWh =
        appliances.fold<double>(0, (sum, a) => sum + a.dailyEnergyWh);
    final totalLoadWatts =
        appliances.fold<double>(0, (sum, a) => sum + a.totalWatts);

    final recommendedInverterWatts = _roundUpToStep(
      totalLoadWatts * inverterSafetyFactor,
      500,
    );

    final requiredArrayWatts =
        totalDailyEnergyWh / sunHoursPerDay / systemEfficiency;
    final numberOfPanels =
        max(1, (requiredArrayWatts / panelWattRating).ceil());

    final batteryBankUsableWh = totalDailyEnergyWh * backupDays;
    final batteryBankRatedWh = batteryBankUsableWh / depthOfDischarge;
    final requiredBatteryCapacityAh = batteryBankRatedWh / systemVoltage;
    final numberOfBatteries =
        max(1, (requiredBatteryCapacityAh / batteryAhRating).ceil());

    return SizingResult(
      totalDailyEnergyWh: totalDailyEnergyWh,
      totalLoadWatts: totalLoadWatts,
      recommendedInverterWatts: recommendedInverterWatts,
      requiredArrayWatts: requiredArrayWatts,
      numberOfPanels: numberOfPanels,
      requiredBatteryCapacityAh: requiredBatteryCapacityAh,
      numberOfBatteries: numberOfBatteries,
      batteryBankUsableWh: batteryBankUsableWh,
    );
  }

  static double _roundUpToStep(double value, double step) {
    if (value <= 0) return step;
    return (value / step).ceil() * step;
  }
}
