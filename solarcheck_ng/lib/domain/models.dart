/// Domain models shared across the sizing, installer directory, equipment
/// registration and monitoring features.
library;

class Installer {
  final String id;
  final String companyName;
  final String location;
  final double rating;
  final int completedInstalls;
  final bool verified;
  final String phone;

  const Installer({
    required this.id,
    required this.companyName,
    required this.location,
    required this.rating,
    required this.completedInstalls,
    required this.verified,
    required this.phone,
  });
}

class Quote {
  final String id;
  final String installerId;
  final double amountNaira;
  final int panelCount;
  final int batteryCount;
  final double inverterWatts;
  final int warrantyYears;
  final String notes;
  final DateTime submittedAt;

  const Quote({
    required this.id,
    required this.installerId,
    required this.amountNaira,
    required this.panelCount,
    required this.batteryCount,
    required this.inverterWatts,
    required this.warrantyYears,
    this.notes = '',
    required this.submittedAt,
  });

  /// A simple naira-per-watt-installed metric used to rank quotes so users
  /// can compare value, not just headline price.
  double get valueScore {
    final totalWatts = (panelCount * 400) + 1; // avoid divide-by-zero
    return amountNaira / totalWatts;
  }
}

enum EquipmentType { panel, battery, inverter, chargeController }

class EquipmentItem {
  final String id;
  final EquipmentType type;
  final String brand;
  final String model;
  final String serialNumber;
  final DateTime registeredAt;
  final String? installerId;

  const EquipmentItem({
    required this.id,
    required this.type,
    required this.brand,
    required this.model,
    required this.serialNumber,
    required this.registeredAt,
    this.installerId,
  });

  String get typeLabel {
    switch (type) {
      case EquipmentType.panel:
        return 'Solar Panel';
      case EquipmentType.battery:
        return 'Battery';
      case EquipmentType.inverter:
        return 'Inverter';
      case EquipmentType.chargeController:
        return 'Charge Controller';
    }
  }
}

/// A single reading logged by the user (manually today, from a monitoring
/// device/API in a future integration) used to track post-install
/// performance over time.
class PerformanceLog {
  final String id;
  final DateTime date;
  final double energyProducedKwh;
  final double batteryStateOfChargePercent;
  final String? note;

  const PerformanceLog({
    required this.id,
    required this.date,
    required this.energyProducedKwh,
    required this.batteryStateOfChargePercent,
    this.note,
  });
}

/// A lead generated when a user requests quotes from installers. This is
/// the hook for the referral-fee revenue model: each lead sent to a
/// verified installer is billable.
class ReferralLead {
  final String id;
  final String installerId;
  final DateTime createdAt;
  final String status; // 'sent' | 'contacted' | 'closed'

  const ReferralLead({
    required this.id,
    required this.installerId,
    required this.createdAt,
    this.status = 'sent',
  });
}
