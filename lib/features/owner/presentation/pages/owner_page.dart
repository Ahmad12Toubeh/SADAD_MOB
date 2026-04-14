import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../providers/owner_provider.dart';

class OwnerPage extends ConsumerWidget {
  const OwnerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ownerAsync = ref.watch(ownerProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final numberFormat = NumberFormat.decimalPattern(l10n.locale.languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ownerTitle),
        actions: [
          IconButton(
            tooltip: l10n.retry,
            onPressed: () => ref.read(ownerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ownerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('${l10n.error}: $err', textAlign: TextAlign.center),
          ),
        ),
        data: (data) {
          if (!data.allowed) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 56,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.ownerAccessDenied,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.ownerAccessDeniedSubtitle,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.go('/dashboard'),
                            child: Text(l10n.navDashboard),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ownerTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.ownerSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _SummaryCard(
                      title: l10n.ownerCustomersCount,
                      value: numberFormat.format(data.overview.customersCount),
                      icon: Icons.people_outline,
                      color: Colors.blue,
                    ),
                    _SummaryCard(
                      title: l10n.ownerTotalCollected,
                      value:
                          '${numberFormat.format(data.overview.totalCollected)} ${data.overview.currency}',
                      icon: Icons.payments_outlined,
                      color: Colors.green,
                    ),
                    _SummaryCard(
                      title: l10n.ownerActiveSubscriptions,
                      value: numberFormat.format(data.overview.activeSubscriptions),
                      icon: Icons.workspace_premium_outlined,
                      color: Colors.amber,
                    ),
                    _SummaryCard(
                      title: l10n.ownerExpiringSoon,
                      value: numberFormat.format(data.overview.expiringSoon),
                      icon: Icons.schedule_outlined,
                      color: Colors.orange,
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
                          l10n.ownerPlans,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (data.plans.isEmpty)
                          Text(l10n.noResults)
                        else
                          ...data.plans.map(
                            (plan) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                plan.isActive
                                    ? Icons.check_circle_outline
                                    : Icons.pause_circle_outline,
                              ),
                              title: Text(plan.name),
                              subtitle: Text(
                                '${plan.months} - ${numberFormat.format(plan.price)} ${plan.currency}',
                              ),
                              trailing: Text(plan.isActive ? l10n.active : 'Inactive'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.ownerManagedUsers,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (data.users.isEmpty)
                          Text(l10n.noResults)
                        else
                          ...data.users.map(
                            (user) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const CircleAvatar(
                                child: Icon(Icons.person_outline),
                              ),
                              title: Text(user.fullName.isEmpty ? user.email : user.fullName),
                              subtitle: Text(user.email),
                              trailing: Text(user.role),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
    return SizedBox(
      width: 260,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
