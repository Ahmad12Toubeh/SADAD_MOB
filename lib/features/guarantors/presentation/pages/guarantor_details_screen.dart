import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/ui/ui.dart';
import '../../../../shared/utils/snackbar_helper.dart';
import '../providers/guarantors_provider.dart';

class GuarantorDetailsScreen extends ConsumerStatefulWidget {
  final String guarantorId;

  const GuarantorDetailsScreen({
    super.key,
    required this.guarantorId,
  });

  @override
  ConsumerState<GuarantorDetailsScreen> createState() => _GuarantorDetailsScreenState();
}

class _GuarantorDetailsScreenState extends ConsumerState<GuarantorDetailsScreen> {
  late Future<Guarantor> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Guarantor> _load() {
    return ref.read(guarantorsProvider.notifier).getGuarantor(widget.guarantorId);
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final numberFormat = NumberFormat.decimalPattern(l10n.locale.languageCode);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guarantor Details'),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<Guarantor>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${l10n.error}: ${snapshot.error}'));
          }
          final guarantor = snapshot.data;
          if (guarantor == null) {
            return Center(child: Text(l10n.noResults));
          }

          final riskColor = guarantor.debtStatus == 'paid'
              ? Colors.green
              : (guarantor.debtStatus == 'late' || guarantor.debtStatus == 'bad')
                  ? Colors.red
                  : Colors.blue;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        guarantor.name.isNotEmpty ? guarantor.name[0] : '?',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guarantor.name,
                            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(guarantor.phone ?? '-'),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        guarantor.debtStatus,
                        style: TextStyle(color: riskColor, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _SummaryCard(title: l10n.totalCapital, value: '${numberFormat.format(guarantor.totalDebt)} ${l10n.sar}'),
                    _SummaryCard(title: 'Debt Status', value: guarantor.debtStatus),
                    _SummaryCard(title: 'Debt ID', value: guarantor.debtId ?? '-'),
                  ],
                ),
                const SizedBox(height: 20),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Actions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          if (guarantor.debtId != null && guarantor.debtId!.isNotEmpty)
                            AppButton(
                              onPressed: () => context.push('/debts/${guarantor.debtId}'),
                              child: const Text('Open Debt'),
                            ),
                          AppButton(
                            variant: AppButtonVariant.outline,
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(
                                  text: [
                                    guarantor.name,
                                    guarantor.phone ?? '',
                                    guarantor.debtId ?? '',
                                  ].where((item) => item.isNotEmpty).join('\n'),
                                ),
                              );
                              if (context.mounted) {
                                SnackbarHelper.success(context, 'Contact copied');
                              }
                            },
                            child: const Text('Copy Contact'),
                          ),
                        ],
                      ),
                    ],
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

  const _SummaryCard({
    required this.title,
    required this.value,
  });

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
