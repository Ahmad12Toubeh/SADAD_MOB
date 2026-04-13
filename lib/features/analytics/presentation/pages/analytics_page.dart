import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../providers/analytics_provider.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.analyticsTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.analyticsSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            analyticsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('${l10n.error}: $err')),
              data: (data) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: l10n.totalDebt,
                          value: '${data.totalDebt.toLocaleString()} ${l10n.sar}',
                          icon: Icons.trending_up,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _SummaryCard(
                          title: l10n.totalCollected,
                          value: '${data.totalCollected.toLocaleString()} ${l10n.sar}',
                          icon: Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: l10n.remaining,
                          value: '${data.remaining.toLocaleString()} ${l10n.sar}',
                          icon: Icons.pending_outlined,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _SummaryCard(
                          title: l10n.collectionRate,
                          value: '${data.collectionRate.toStringAsFixed(1)}%',
                          icon: Icons.pie_chart_outline,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.monthlyAnalysis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: data.monthly.isEmpty
                                ? Center(child: Text(l10n.noMonthlyData))
                                : _MonthlyBarChart(monthly: data.monthly, l10n: l10n),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyBarChart extends StatelessWidget {
  final List<MonthlyData> monthly;
  final AppLocalizations l10n;
  const _MonthlyBarChart({required this.monthly, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final maxDebt = monthly.fold<num>(0, (max, m) => m.debts > max ? m.debts : max).toDouble();
    if (maxDebt == 0) return Center(child: Text(l10n.noMonthlyData));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: monthly.map((m) {
        final debtHeight = (m.debts.toDouble() / maxDebt) * 160;
        final collectedHeight = (m.collected.toDouble() / maxDebt) * 160;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 12,
                      height: debtHeight.clamp(2, 160),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      width: 12,
                      height: collectedHeight.clamp(2, 160),
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.monthName(m.month),
                  style: const TextStyle(fontSize: 9),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
