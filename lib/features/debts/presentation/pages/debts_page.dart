import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/ui/ui.dart';
import '../providers/debts_provider.dart';

class DebtsPage extends ConsumerStatefulWidget {
  const DebtsPage({super.key});

  @override
  ConsumerState<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends ConsumerState<DebtsPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final debtsAsync = ref.watch(debtsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final numberFormat = NumberFormat.decimalPattern(l10n.locale.languageCode);
    final search = _searchController.text.trim().toLowerCase();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.debtsTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.noDebts,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AppButton(
                  onPressed: () => context.push('/debts/new'),
                  child: Text(l10n.addDebt),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AppCard(
              child: Column(
                children: [
                  AppInput(
                    controller: _searchController,
                    labelText: l10n.searchCustomer,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: l10n.filterAll,
                          selected: _filterStatus == 'all',
                          onSelected: () => setState(() => _filterStatus = 'all'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: l10n.filterActive,
                          selected: _filterStatus == 'active',
                          onSelected: () => setState(() => _filterStatus = 'active'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: l10n.filterPaid,
                          selected: _filterStatus == 'paid',
                          onSelected: () => setState(() => _filterStatus = 'paid'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: l10n.filterLate,
                          selected: _filterStatus == 'late',
                          onSelected: () => setState(() => _filterStatus = 'late'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            debtsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => AppCard(child: Text('${l10n.error}: $err')),
              data: (debts) {
                final filtered = debts.where((debt) {
                  final matchesStatus = _filterStatus == 'all' || debt.status == _filterStatus;
                  final matchesSearch = search.isEmpty ||
                      debt.customerName.toLowerCase().contains(search) ||
                      debt.id.toLowerCase().contains(search) ||
                      (debt.category ?? '').toLowerCase().contains(search) ||
                      debt.type.toLowerCase().contains(search);
                  return matchesStatus && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: l10n.noDebts,
                    description: l10n.debtsTitle,
                    actionLabel: l10n.addDebt,
                    onAction: () => context.push('/debts/new'),
                  );
                }

                return Column(
                  children: filtered.map((debt) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.push('/debts/${debt.id}'),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        debt.customerName.isEmpty ? debt.id : debt.customerName,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _StatusBadge(status: debt.status),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 8,
                                  children: [
                                    _InfoItem(label: l10n.amount, value: '${numberFormat.format(debt.principalAmount)} ${debt.currency}'),
                                    _InfoItem(label: l10n.type, value: debt.type),
                                    _InfoItem(label: l10n.dueDate, value: debt.dueDate ?? '-'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'paid' => Colors.green,
      'late' => Colors.red,
      'bad' => Colors.grey,
      _ => Colors.blue,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
