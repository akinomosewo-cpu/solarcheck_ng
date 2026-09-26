import 'package:flutter_test/flutter_test.dart';
import 'package:solarcheck_ng/core/logic/solar_sizing_calculator.dart';

void main() {
  group('SolarSizingCalculator', () {
    test('returns empty result for no appliances', () {
      final result = SolarSizingCalculator.calculate(appliances: const []);
      expect(result.totalDailyEnergyWh, 0);
      expect(result.numberOfPanels, 0);
      expect(result.numberOfBatteries, 0);
    });

    test('computes daily energy and load correctly for a single appliance', () {
      final result = SolarSizingCalculator.calculate(
        appliances: const [Appliance(name: 'Fridge', watts: 150, hoursPerDay: 8, quantity: 1)],
      );
      expect(result.totalDailyEnergyWh, 1200); // 150 * 8
      expect(result.totalLoadWatts, 150);
    });

    test('accounts for appliance quantity', () {
      final result = SolarSizingCalculator.calculate(
        appliances: const [Appliance(name: 'Bulb', watts: 10, hoursPerDay: 6, quantity: 5)],
      );
      expect(result.totalDailyEnergyWh, 300); // 10*6*5
      expect(result.totalLoadWatts, 50); // 10*5
    });

    test('sums multiple appliances', () {
      final result = SolarSizingCalculator.calculate(
        appliances: const [
          Appliance(name: 'Fridge', watts: 150, hoursPerDay: 8),
          Appliance(name: 'TV', watts: 100, hoursPerDay: 5),
          Appliance(name: 'Fan', watts: 60, hoursPerDay: 10, quantity: 2),
        ],
      );
      // 150*8 + 100*5 + 60*10*2 = 1200 + 500 + 1200 = 2900
      expect(result.totalDailyEnergyWh, 2900);
      expect(result.totalLoadWatts, 150 + 100 + 120);
    });

    test('inverter size includes safety margin and rounds up to 500W steps', () {
      final result = SolarSizingCalculator.calculate(
        appliances: const [Appliance(name: 'Load', watts: 1000, hoursPerDay: 1)],
      );
      // 1000 * 1.25 = 1250 -> rounds up to 1500
      expect(result.recommendedInverterWatts, 1500);
    });

    test('panel count scales with energy need and respects panel wattage rating', () {
      final result = SolarSizingCalculator.calculate(
        appliances: const [Appliance(name: 'Load', watts: 1000, hoursPerDay: 5)],
        sunHoursPerDay: 5,
        systemEfficiency: 1, // isolate the panel-count math from losses
        panelWattRating: 500,
      );
      // dailyEnergyWh = 5000, arrayWatts = 5000 / 5 / 1 = 1000W -> 2 panels of 500W
      expect(result.requiredArrayWatts, 1000);
      expect(result.numberOfPanels, 2);
    });

    test('battery capacity scales with backup days and respects depth of discharge', () {
      final oneDay = SolarSizingCalculator.calculate(
        appliances: const [Appliance(name: 'Load', watts: 500, hoursPerDay: 4)],
        backupDays: 1,
        systemVoltage: 24,
        depthOfDischarge: 0.5,
        batteryAhRating: 200,
      );
      final twoDays = SolarSizingCalculator.calculate(
        appliances: const [Appliance(name: 'Load', watts: 500, hoursPerDay: 4)],
        backupDays: 2,
        systemVoltage: 24,
        depthOfDischarge: 0.5,
        batteryAhRating: 200,
      );
      // dailyEnergyWh = 2000; 1 day: 2000/0.5/24 = 166.67Ah -> 1 battery of 200Ah
      expect(oneDay.requiredBatteryCapacityAh, closeTo(166.67, 0.1));
      expect(oneDay.numberOfBatteries, 1);
      // Doubling backup days doubles the required battery capacity.
      expect(twoDays.requiredBatteryCapacityAh, closeTo(oneDay.requiredBatteryCapacityAh * 2, 0.01));
      expect(twoDays.numberOfBatteries, 2);
    });

    test('at least one panel and one battery are recommended once there is any load', () {
      final result = SolarSizingCalculator.calculate(
        appliances: const [Appliance(name: 'Tiny load', watts: 1, hoursPerDay: 1)],
      );
      expect(result.numberOfPanels, greaterThanOrEqualTo(1));
      expect(result.numberOfBatteries, greaterThanOrEqualTo(1));
    });

    test('throws for invalid backupDays', () {
      expect(
        () => SolarSizingCalculator.calculate(
          appliances: const [Appliance(name: 'Load', watts: 100, hoursPerDay: 1)],
          backupDays: 0,
        ),
        throwsArgumentError,
      );
    });

    test('throws for out-of-range hoursPerDay would be caught by callers, but calculator trusts input sums', () {
      // The calculator itself does not clamp hoursPerDay > 24 (UI layer validates that);
      // it should still sum without throwing so callers can decide how to handle it.
      final result = SolarSizingCalculator.calculate(
        appliances: const [Appliance(name: 'Load', watts: 100, hoursPerDay: 30)],
      );
      expect(result.totalDailyEnergyWh, 3000);
    });

    test('throws for non-positive systemVoltage/panelWattRating/batteryAhRating', () {
      expect(
        () => SolarSizingCalculator.calculate(
          appliances: const [Appliance(name: 'Load', watts: 100, hoursPerDay: 1)],
          systemVoltage: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => SolarSizingCalculator.calculate(
          appliances: const [Appliance(name: 'Load', watts: 100, hoursPerDay: 1)],
          panelWattRating: -1,
        ),
        throwsArgumentError,
      );
      expect(
        () => SolarSizingCalculator.calculate(
          appliances: const [Appliance(name: 'Load', watts: 100, hoursPerDay: 1)],
          batteryAhRating: 0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('Appliance', () {
    test('dailyEnergyWh and totalWatts multiply by quantity', () {
      const a = Appliance(name: 'Pump', watts: 200, hoursPerDay: 2, quantity: 3);
      expect(a.totalWatts, 600);
      expect(a.dailyEnergyWh, 1200);
    });

    test('round-trips through JSON', () {
      const a = Appliance(name: 'Pump', watts: 200, hoursPerDay: 2, quantity: 3);
      final restored = Appliance.fromJson(a.toJson());
      expect(restored.name, a.name);
      expect(restored.watts, a.watts);
      expect(restored.hoursPerDay, a.hoursPerDay);
      expect(restored.quantity, a.quantity);
    });
  });
}
