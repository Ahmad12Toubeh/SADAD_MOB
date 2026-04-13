import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/recent_activity_table.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dashboardTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.dashboardSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            dashboardAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(child: Text('${l10n.error}: $err')),
                    ],
                  ),
                ),
              ),
              data: (data) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: l10n.totalActiveDebt,
                          value: '${data.totalActiveDebt.toLocaleString()} ${l10n.sar}',
                          icon: Icons.account_balance_wallet_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatsCard(
                          title: l10n.collectedThisMonth,
                          value: '${data.collectedThisMonth.toLocaleString()} ${l10n.sar}',
                          icon: Icons.trending_up,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          title: l10n.overdueDebt,
                          value: '${data.overdueAmount.toLocaleString()} ${l10n.sar}',
                          icon: Icons.warning_amber,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatsCard(
                          title: l10n.activeCustomers,
                          value: '${data.activeCustomers}',
                          icon: Icons.people_outline,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  RecentActivityTable(recentDebts: data.recentActivity),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
