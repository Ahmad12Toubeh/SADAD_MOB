import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../providers/associations_provider.dart';

class AssociationsPage extends ConsumerStatefulWidget {
  const AssociationsPage({super.key});

  @override
  ConsumerState<AssociationsPage> createState() => _AssociationsPageState();
}

class _AssociationsPageState extends ConsumerState<AssociationsPage> {
  @override
  Widget build(BuildContext context) {
    final associationsAsync = ref.watch(associationsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final numberFormat = NumberFormat.decimalPattern(l10n.locale.languageCode);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.associationsTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCreateAssociationDialog(context),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.createAssociation),
                ),
              ],
            ),
          ),
          Expanded(
            child: associationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('${l10n.error}: $err')),
              data: (associations) {
                if (associations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.groups_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(l10n.noAssociations,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _showCreateAssociationDialog(context),
                          child: Text(l10n.createFirstAssociation),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: associations.length,
                  itemBuilder: (context, index) {
                    final association = associations[index];
                    final paidCount = association.membersList.where((m) => m.isPaid).length;
                    final progressPercent = association.members > 0 
                        ? (paidCount / association.members * 100).round() 
                        : 0;
                    final receiver = association.membersList.firstWhere(
                      (m) => m.isReceiver,
                      orElse: () => association.membersList.first,
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
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
                                  child: Icon(
                                    Icons.groups,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        association.name,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${association.members} ${l10n.members} • ${numberFormat.format(association.monthlyAmount)} ${l10n.sar}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: association.associationKind == 'family'
                                        ? Colors.green.shade100
                                        : theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    association.associationKind == 'family'
                                        ? l10n.family
                                        : l10n.active,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: association.associationKind == 'family'
                                          ? Colors.green.shade700
                                          : theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: progressPercent / 100,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${l10n.progress}: $paidCount ${l10n.from} ${association.members}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  '$progressPercent%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (receiver.name != null && receiver.name!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.emoji_events, color: Colors.green.shade600, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${l10n.currentReceiver}: ${receiver.name}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateAssociationDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    final amountController = TextEditingController(text: '500');
    String associationKind = 'rotating';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.createAssociation),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.associationName),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.monthlyAmount),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: associationKind,
                decoration: InputDecoration(labelText: l10n.associationKind),
                items: [
                  DropdownMenuItem(value: 'rotating', child: Text(l10n.rotating)),
                  DropdownMenuItem(value: 'family', child: Text(l10n.family)),
                ],
                onChanged: (value) {
                  setState(() => associationKind = value!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Call API to create association
                Navigator.pop(ctx);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
