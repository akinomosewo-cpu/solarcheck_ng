import '../domain/models.dart';

/// Seed data for the installer directory. In production this would come
/// from a backend/API with real verification records; kept local for now
/// so the directory and quote-comparison UI are fully usable offline.
class MockData {
  MockData._();

  static final List<Installer> installers = [
    const Installer(
      id: 'inst-1',
      companyName: 'SunGrid Energy Ltd',
      location: 'Lekki, Lagos',
      rating: 4.8,
      completedInstalls: 214,
      verified: true,
      phone: '+2348012345678',
    ),
    const Installer(
      id: 'inst-2',
      companyName: 'Havenhill Synergy',
      location: 'Abuja',
      rating: 4.6,
      completedInstalls: 180,
      verified: true,
      phone: '+2348023456789',
    ),
    const Installer(
      id: 'inst-3',
      companyName: 'Arnergy Solar',
      location: 'Ikeja, Lagos',
      rating: 4.7,
      completedInstalls: 305,
      verified: true,
      phone: '+2348034567890',
    ),
    const Installer(
      id: 'inst-4',
      companyName: 'GreenVille Power',
      location: 'Port Harcourt',
      rating: 3.9,
      completedInstalls: 42,
      verified: false,
      phone: '+2348045678901',
    ),
  ];

  static List<Quote> quotesFor(String installerId) {
    final all = <Quote>[
      Quote(
        id: 'q-1',
        installerId: 'inst-1',
        amountNaira: 2850000,
        panelCount: 6,
        batteryCount: 4,
        inverterWatts: 3500,
        warrantyYears: 10,
        notes: 'Includes installation and 1-year free maintenance.',
        submittedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Quote(
        id: 'q-2',
        installerId: 'inst-2',
        amountNaira: 3100000,
        panelCount: 6,
        batteryCount: 4,
        inverterWatts: 4000,
        warrantyYears: 7,
        notes: 'Lithium batteries, mobile monitoring app included.',
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Quote(
        id: 'q-3',
        installerId: 'inst-3',
        amountNaira: 2600000,
        panelCount: 6,
        batteryCount: 4,
        inverterWatts: 3500,
        warrantyYears: 5,
        notes: 'Budget-friendly, tubular batteries.',
        submittedAt: DateTime.now(),
      ),
    ];
    return all.where((q) => q.installerId == installerId).toList();
  }
}
