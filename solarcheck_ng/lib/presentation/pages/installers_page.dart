import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../../domain/models.dart';
import '../blocs/app_bloc.dart';
import '../widgets/section_card.dart';

/// Installer directory with a quote comparison view and a "Request Quote"
/// lead-generation action (the referral-fee revenue hook).
class InstallersPage extends StatelessWidget {
  const InstallersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          final installers = [...state.installers]
            ..sort((a, b) => b.rating.compareTo(a.rating));
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Text('Installer Directory', style: AppTextStyles.displaySmall.copyWith(color: AppColors.textPrimary)),
              const Gap(4),
              Text('Verified installers near you, ranked by rating',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const Gap(20),
              ...installers.map((i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _InstallerCard(installer: i),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _InstallerCard extends StatelessWidget {
  final Installer installer;
  const _InstallerCard({required this.installer});

  @override
  Widget build(BuildContext context) {
    final quotes = MockData.quotesFor(installer.id);
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Row(children: [
                Text(installer.companyName, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textPrimary)),
                if (installer.verified) ...[
                  const Gap(6),
                  const Icon(Icons.verified_rounded, color: AppColors.primary, size: 16),
                ],
              ]),
            ),
            Row(children: [
              const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
              const Gap(2),
              Text(installer.rating.toStringAsFixed(1), style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
            ]),
          ]),
          const Gap(4),
          Text('${installer.location} · ${installer.completedInstalls} installs',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
          if (quotes.isNotEmpty) ...[
            const Gap(12),
            const Divider(height: 1),
            const Gap(12),
            ...quotes.map((q) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₦${NumberFormat.decimalPattern().format(q.amountNaira.round())}',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                      Text('${q.warrantyYears}yr warranty', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                )),
          ],
          const Gap(12),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _showDetails(context, installer, quotes),
                child: const Text('View details'),
              ),
            ),
            const Gap(8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _requestQuote(context, installer),
                child: const Text('Request Quote'),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  void _requestQuote(BuildContext context, Installer installer) {
    context.read<AppBloc>().add(QuoteRequested(installer.id));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppColors.surfaceElevated,
      content: Text('Quote request sent to ${installer.companyName}'),
    ));
  }

  void _showDetails(BuildContext context, Installer installer, List<Quote> quotes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(installer.companyName, style: AppTextStyles.headlineLarge.copyWith(color: AppColors.textPrimary)),
            const Gap(4),
            Text(installer.phone, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            const Gap(16),
            Text('Quotes for a typical 6-panel system', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
            const Gap(8),
            ...quotes.map((q) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₦${NumberFormat.decimalPattern().format(q.amountNaira.round())}',
                            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary)),
                        const Gap(4),
                        Text('${q.panelCount} panels · ${q.batteryCount} batteries · ${q.inverterWatts.round()}W inverter',
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                        if (q.notes.isNotEmpty) ...[
                          const Gap(6),
                          Text(q.notes, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                        ],
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
