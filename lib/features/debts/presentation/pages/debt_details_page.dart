import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/ui/ui.dart';
import '../../../../shared/utils/snackbar_helper.dart';
import '../providers/debts_provider.dart';

class DebtDetailsPage extends ConsumerStatefulWidget {
  final String debtId;

  const DebtDetailsPage({
    super.key,
    required this.debtId,
  });

  @override
  ConsumerState<DebtDetailsPage> createState() => _DebtDetailsPageState();
}

class _DebtDetailsPageState extends ConsumerState<DebtDetailsPage> {
  late Future<DebtDetails> _future;
  bool _deleting = false;
  String? _confirmPayInstallmentId;
  bool _activateLoading = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<DebtDetails> _load() async {
    return ref.read(debtsProvider.notifier).getDebt(widget.debtId);
  }

  void _refresh() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _deleteDebt() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AppDialog(
        title: 'Delete Debt',
        content: const Text('This debt and its related data will be deleted permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _deleting = true);
    try {
      await ref.read(debtsProvider.notifier).deleteDebt(widget.debtId);
      if (!mounted) return;
      SnackbarHelper.success(context, 'Debt deleted');
      context.go('/debts');
    } catch (e) {
      if (mounted) SnackbarHelper.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _payInstallment(String installmentId) async {
    try {
      await ref.read(debtsProvider.notifier).payInstallment(installmentId, {'method': 'cash'});
      _refresh();
    } catch (e) {
      if (mounted) SnackbarHelper.error(context, e.toString());
    }
  }

  Future<void> _activateGuarantor() async {
    setState(() => _activateLoading = true);
    try {
      await ref.read(debtsProvider.notifier).activateGuarantor(widget.debtId);
      _refresh();
    } catch (e) {
      if (mounted) SnackbarHelper.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _activateLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final numberFormat = NumberFormat.decimalPattern(l10n.locale.languageCode);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debt Details'),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<DebtDetails>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${l10n.error}: ${snapshot.error}'));
          }
          final data = snapshot.data;
          if (data == null) {
            return Center(child: Text(l10n.noResults));
          }

          final debt = data.debt;
          final installments = data.installments;
          final paid = installments.where((item) => item.status == 'paid').fold<num>(0, (p, i) => p + i.amount);
          final remaining = debt.principalAmount - paid;

          return SingleChildScrollView(
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
                            debt.customerName.isEmpty ? debt.id : debt.customerName,
                            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text('${debt.type} • ${debt.category ?? '-'}'),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 12,
                      children: [
                        AppButton(
                          variant: AppButtonVariant.destructive,
                          onPressed: _deleting ? null : _deleteDebt,
                          child: Text(_deleting ? 'Deleting...' : 'Delete'),
                        ),
                        AppButton(
                          variant: AppButtonVariant.outline,
                          onPressed: () => context.go('/customers/${debt.customerId}'),
                          child: const Text('Open Customer'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _Summary(title: 'Total', value: '${numberFormat.format(debt.principalAmount)} ${debt.currency}'),
                    _Summary(title: 'Paid', value: '${numberFormat.format(paid)} ${debt.currency}'),
                    _Summary(title: 'Remaining', value: '${numberFormat.format(remaining)} ${debt.currency}'),
                    _Summary(title: 'Status', value: debt.status),
                  ],
                ),
                const SizedBox(height: 20),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Guarantor', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(data.guarantor?.name ?? 'No guarantor'),
                      Text(data.guarantor?.phone ?? '-'),
                      if (data.guarantor?.proofImageUrl != null)
                        TextButton(
                          onPressed: () {},
                          child: const Text('Proof image'),
                        ),
                      const SizedBox(height: 8),
                      if ((debt.guarantorActive ?? false) == false && (data.guarantor?.name?.isNotEmpty ?? false))
                        AppButton(
                          onPressed: _activateLoading ? null : _activateGuarantor,
                          child: Text(_activateLoading ? 'Activating...' : 'Activate Guarantor'),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AppCard(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Installments', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const Divider(height: 1),
                      if (installments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: Text('No installments')),
                        )
                      else
                        ...installments.asMap().entries.map((entry) {
                          final inst = entry.value;
                          return ListTile(
                            title: Text('${numberFormat.format(inst.amount)} ${debt.currency}'),
                            subtitle: Text(inst.dueDate),
                            trailing: inst.status == 'paid'
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : AppButton(
                                    size: AppButtonSize.sm,
                                    onPressed: _confirmPayInstallmentId == inst.id
                                        ? null
                                        : () => setState(() => _confirmPayInstallmentId = inst.id),
                                    child: const Text('Pay'),
                                  ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomSheet: _confirmPayInstallmentId == null
          ? null
          : Padding(
              padding: const EdgeInsets.all(16),
              child: AppCard(
                child: Row(
                  children: [
                    const Expanded(child: Text('Confirm payment?')),
                    AppButton(
                      onPressed: () {
                        final id = _confirmPayInstallmentId!;
                        setState(() => _confirmPayInstallmentId = null);
                        _payInstallment(id);
                      },
                      child: const Text('Confirm'),
                    ),
                    const SizedBox(width: 12),
                    AppButton(
                      variant: AppButtonVariant.outline,
                      onPressed: () => setState(() => _confirmPayInstallmentId = null),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _Summary extends StatelessWidget {
  final String title;
  final String value;

  const _Summary({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
