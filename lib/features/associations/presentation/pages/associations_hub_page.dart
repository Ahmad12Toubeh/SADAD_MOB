import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/ui/ui.dart';
import '../../../../shared/utils/snackbar_helper.dart';
import '../providers/associations_provider.dart';

class AssociationsHubPage extends ConsumerStatefulWidget {
  const AssociationsHubPage({super.key});

  @override
  ConsumerState<AssociationsHubPage> createState() => _AssociationsHubPageState();
}

class _AssociationsHubPageState extends ConsumerState<AssociationsHubPage> {
  @override
  Widget build(BuildContext context) {
    final associationsAsync = ref.watch(associationsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final numberFormat = NumberFormat.decimalPattern(l10n.locale.languageCode);

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
                        l10n.associationsTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.noAssociations,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                AppButton(
                  onPressed: () => _showCreateAssociationDialog(context),
                  child: Text(l10n.createAssociation),
                ),
              ],
            ),
            const SizedBox(height: 20),
            associationsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => AppCard(child: Text('${l10n.error}: $err')),
              data: (associations) {
                if (associations.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.groups_outlined,
                    title: l10n.noAssociations,
                    description: l10n.associationsTitle,
                    actionLabel: l10n.createFirstAssociation,
                    onAction: () => _showCreateAssociationDialog(context),
                  );
                }

                return Column(
                  children: associations.map((association) {
                    final paidCount = association.membersList.where((m) => m.isPaid).length;
                    final progressPercent = association.members > 0
                        ? (paidCount / association.members * 100).round()
                        : 0;
                    final receiver = association.membersList.isEmpty
                        ? null
                        : association.membersList.firstWhere(
                            (m) => m.isReceiver,
                            orElse: () => association.membersList.first,
                          );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.push('/associations/${association.id}'),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.groups, color: theme.colorScheme.primary),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            association.name,
                                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '${association.members} ${l10n.members} • ${numberFormat.format(association.monthlyAmount)} ${l10n.sar}',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _KindBadge(kind: association.associationKind, l10n: l10n),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: progressPercent / 100,
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${l10n.progress}: $paidCount ${l10n.from} ${association.members}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    Text(
                                      '$progressPercent%',
                                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (receiver?.name?.isNotEmpty ?? false)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.green.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.emoji_events, color: Colors.green.shade600, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${l10n.currentReceiver}: ${receiver?.name}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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

  Future<void> _showCreateAssociationDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final amountController = TextEditingController(text: '500');
    String associationKind = 'rotating';
    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AppDialog(
          title: l10n.createAssociation,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppInput(
                controller: nameController,
                labelText: l10n.associationName,
              ),
              const SizedBox(height: 12),
              AppInput(
                controller: amountController,
                labelText: l10n.monthlyAmount,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: associationKind,
                decoration: InputDecoration(labelText: l10n.associationKind),
                items: [
                  DropdownMenuItem(value: 'rotating', child: Text(l10n.rotating)),
                  DropdownMenuItem(value: 'family', child: Text(l10n.family)),
                ],
                onChanged: (value) => setState(() => associationKind = value ?? 'rotating'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            AppButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty) {
                        SnackbarHelper.error(context, 'Association name is required');
                        return;
                      }
                      setState(() => saving = true);
                      try {
                        final created = await ref.read(associationsProvider.notifier).createAssociation({
                          'name': nameController.text.trim(),
                          'monthlyAmount': double.tryParse(amountController.text) ?? 0,
                          'associationKind': associationKind,
                        });
                        if (!context.mounted) return;
                        Navigator.pop(ctx);
                        await ref.read(associationsProvider.notifier).refresh();
                        if (created.id.isNotEmpty && context.mounted) {
                          context.push('/associations/${created.id}');
                        }
                      } catch (e) {
                        if (context.mounted) SnackbarHelper.error(context, e.toString());
                      } finally {
                        if (ctx.mounted) setState(() => saving = false);
                      }
                    },
              child: Text(saving ? 'Loading...' : l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}

class _KindBadge extends StatelessWidget {
  final String kind;
  final AppLocalizations l10n;

  const _KindBadge({
    required this.kind,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final isFamily = kind == 'family';
    final color = isFamily ? Colors.green : Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isFamily ? l10n.family : l10n.rotating,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
