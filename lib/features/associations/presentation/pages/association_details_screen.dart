import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/ui/ui.dart';
import '../../../../shared/utils/snackbar_helper.dart';
import '../providers/associations_provider.dart';

class AssociationDetailsScreen extends ConsumerStatefulWidget {
  final String associationId;

  const AssociationDetailsScreen({
    super.key,
    required this.associationId,
  });

  @override
  ConsumerState<AssociationDetailsScreen> createState() => _AssociationDetailsScreenState();
}

class _AssociationDetailsScreenState extends ConsumerState<AssociationDetailsScreen> {
  final _nameController = TextEditingController();
  final _monthlyAmountController = TextEditingController();
  final _memberNameController = TextEditingController();
  final _memberPhoneController = TextEditingController();
  final _memberOrderController = TextEditingController();
  final _transactionAmountController = TextEditingController();
  final _transactionNoteController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  bool _addingMember = false;
  bool _addingTransaction = false;
  String _kind = 'rotating';
  String? _fundGuarantorMemberId;
  String? _approvalMemberId;
  bool _memberIsReceiver = false;
  bool _memberIsPaid = false;
  String _transactionType = 'in';
  AssociationDetails? _details;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _monthlyAmountController.dispose();
    _memberNameController.dispose();
    _memberPhoneController.dispose();
    _memberOrderController.dispose();
    _transactionAmountController.dispose();
    _transactionNoteController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final details = await ref.read(associationsProvider.notifier).getAssociation(widget.associationId);
      if (!mounted) return;
      _details = details;
      _nameController.text = details.association.name;
      _monthlyAmountController.text = details.association.monthlyAmount.toString();
      _kind = details.association.associationKind;
      _fundGuarantorMemberId = details.fundGuarantorMemberId;
      _approvalMemberId = details.association.membersList.isEmpty ? null : details.association.membersList.first.id;
      _loading = false;
      setState(() {});
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        SnackbarHelper.error(context, e.toString());
      }
    }
  }

  AssociationDetails get _data => _details!;

  List<AssociationMember> get _members => _data.association.membersList;

  AssociationMember? get _currentReceiver {
    if (_members.isEmpty) return null;
    return _members.firstWhere(
      (m) => m.isReceiver,
      orElse: () => _members.first,
    );
  }

  Future<void> _saveAssociation() async {
    if (_details == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(associationsProvider.notifier).updateAssociation(widget.associationId, {
        'name': _nameController.text.trim(),
        'monthlyAmount': double.tryParse(_monthlyAmountController.text) ?? _data.association.monthlyAmount,
        'associationKind': _kind,
        'fundGuarantorMemberId': _fundGuarantorMemberId?.isEmpty ?? true ? null : _fundGuarantorMemberId,
        'membersList': _members.map((m) => m.toJson()).toList(),
      });
      if (!mounted) return;
      SnackbarHelper.success(context, 'Association updated');
      await _refresh();
    } catch (e) {
      if (mounted) SnackbarHelper.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _closeMonth() async {
    setState(() => _saving = true);
    try {
      await ref.read(associationsProvider.notifier).closeAssociationMonth(widget.associationId);
      if (!mounted) return;
      SnackbarHelper.success(context, 'Month closed');
      await _refresh();
    } catch (e) {
      if (mounted) SnackbarHelper.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _reopenCycle() async {
    setState(() => _saving = true);
    try {
      await ref.read(associationsProvider.notifier).reopenAssociationCycle(widget.associationId);
      if (!mounted) return;
      SnackbarHelper.success(context, 'Cycle reopened');
      await _refresh();
    } catch (e) {
      if (mounted) SnackbarHelper.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteAssociation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AppDialog(
        title: 'Delete Association',
        content: const Text('This association will be deleted permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ref.read(associationsProvider.notifier).deleteAssociation(widget.associationId);
      if (!mounted) return;
      SnackbarHelper.success(context, 'Association deleted');
      context.go('/associations');
    } catch (e) {
      if (mounted) SnackbarHelper.error(context, e.toString());
    }
  }

  Future<void> _downloadReport() async {
    final data = _data;
    final buffer = StringBuffer()
      ..writeln('Association: ${data.association.name}')
      ..writeln('Kind: ${data.association.associationKind}')
      ..writeln('Members: ${data.association.members}')
      ..writeln('Monthly amount: ${data.association.monthlyAmount}')
      ..writeln('Fund balance: ${data.fundBalance}')
      ..writeln('Current receiver: ${_currentReceiver?.name ?? '-'}');
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) SnackbarHelper.success(context, 'Report copied to clipboard');
  }

  Future<void> _addMember() async {
    if (_memberNameController.text.trim().isEmpty) return;
    if (_kind != 'family' && _memberIsReceiver && _members.isNotEmpty) {
      // Rotating cycles can only have one active receiver.
    }
    setState(() => _addingMember = true);
    try {
      final nextMembers = _members.map((m) {
        if (_kind != 'family' && _memberIsReceiver) {
          return {
            ...m.toJson(),
            'isReceiver': false,
          };
        }
        return m.toJson();
      }).toList();
      nextMembers.add({
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'name': _memberNameController.text.trim(),
        'phone': _memberPhoneController.text.trim().isEmpty ? null : _memberPhoneController.text.trim(),
        'isPaid': _memberIsPaid,
        'isReceiver': _kind == 'family' ? false : _memberIsReceiver,
        'turnOrder': int.tryParse(_memberOrderController.text) ?? (_members.length + 1),
      });
      await ref.read(associationsProvider.notifier).updateAssociation(widget.associationId, {
        'name': _nameController.text.trim(),
        'monthlyAmount': double.tryParse(_monthlyAmountController.text) ?? _data.association.monthlyAmount,
        'associationKind': _kind,
        'fundGuarantorMemberId': _fundGuarantorMemberId?.isEmpty ?? true ? null : _fundGuarantorMemberId,
        'membersList': nextMembers,
      });
      _memberNameController.clear();
      _memberPhoneController.clear();
      _memberOrderController.clear();
      _memberIsReceiver = false;
      _memberIsPaid = false;
      if (!mounted) return;
      SnackbarHelper.success(context, 'Member added');
      await _refresh();
    } catch (e) {
      if (mounted) SnackbarHelper.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _addingMember = false);
    }
  }

  Future<void> _addFundTransaction() async {
    if (_kind != 'family') return;
    setState(() => _addingTransaction = true);
    try {
      await ref.read(associationsProvider.notifier).addAssociationFundTransaction(
            widget.associationId,
            {
              'type': _transactionType,
              'amount': double.tryParse(_transactionAmountController.text) ?? 0,
              'note': _transactionNoteController.text.trim().isEmpty ? null : _transactionNoteController.text.trim(),
              'memberId': _approvalMemberId,
            },
          );
      _transactionAmountController.clear();
      _transactionNoteController.clear();
      if (!mounted) return;
      SnackbarHelper.success(context, 'Transaction added');
      await _refresh();
    } catch (e) {
      if (mounted) SnackbarHelper.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _addingTransaction = false);
    }
  }

  Future<void> _approveTransaction(String transactionId) async {
    if (_approvalMemberId == null || _approvalMemberId!.isEmpty) {
      SnackbarHelper.error(context, 'Select an approver first');
      return;
    }
    try {
      await ref.read(associationsProvider.notifier).approveAssociationFundTransaction(
            widget.associationId,
            transactionId: transactionId,
            memberId: _approvalMemberId!,
          );
      if (!mounted) return;
      SnackbarHelper.success(context, 'Transaction approved');
      await _refresh();
    } catch (e) {
      if (mounted) SnackbarHelper.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final numberFormat = NumberFormat.decimalPattern(l10n.locale.languageCode);

    if (_loading || _details == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final data = _data;
    final paidCount = _members.where((member) => member.isPaid).length;
    final progress = data.association.members > 0 ? (paidCount / data.association.members * 100).round() : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(data.association.name),
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _downloadReport, icon: const Icon(Icons.download)),
        ],
      ),
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
                        data.association.name,
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data.association.members} ${l10n.members} • ${numberFormat.format(data.association.monthlyAmount)} ${l10n.sar}',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                _KindBadge(kind: data.association.associationKind, l10n: l10n),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _SummaryCard(title: l10n.members, value: '${data.association.members}'),
                _SummaryCard(title: l10n.progress, value: '$paidCount'),
                _SummaryCard(title: 'Fund Balance', value: '${numberFormat.format(data.fundBalance)} ${l10n.sar}'),
                _SummaryCard(title: 'Total Value', value: '${numberFormat.format(data.association.totalValue)} ${l10n.sar}'),
              ],
            ),
            const SizedBox(height: 20),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit Association', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  AppInput(controller: _nameController, labelText: 'Name'),
                  const SizedBox(height: 12),
                  AppInput(
                    controller: _monthlyAmountController,
                    labelText: 'Monthly amount',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _kind,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: const [
                      DropdownMenuItem(value: 'rotating', child: Text('Rotating')),
                      DropdownMenuItem(value: 'family', child: Text('Family')),
                    ],
                    onChanged: (value) => setState(() => _kind = value ?? 'rotating'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _fundGuarantorMemberId?.isEmpty ?? true ? '' : _fundGuarantorMemberId,
                    decoration: const InputDecoration(labelText: 'Fund guarantor member'),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('None')),
                      ..._members.map(
                        (m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(m.name?.isNotEmpty == true ? m.name! : m.id),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _fundGuarantorMemberId = value == null || value.isEmpty ? null : value),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      AppButton(
                        onPressed: _saving ? null : _saveAssociation,
                      child: Text(_saving ? 'Loading...' : l10n.saveChanges),
                      ),
                      AppButton(
                        variant: AppButtonVariant.outline,
                        onPressed: _saving ? null : _closeMonth,
                        child: Text(_saving ? 'Loading...' : 'Close Month'),
                      ),
                      AppButton(
                        variant: AppButtonVariant.outline,
                        onPressed: _saving ? null : _reopenCycle,
                        child: const Text('Reopen Cycle'),
                      ),
                      AppButton(
                        variant: AppButtonVariant.destructive,
                        onPressed: _deleteAssociation,
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Member', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  AppInput(controller: _memberNameController, labelText: 'Member name'),
                  const SizedBox(height: 12),
                  AppInput(controller: _memberPhoneController, labelText: 'Member phone', keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  AppInput(controller: _memberOrderController, labelText: 'Turn order', keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Paid'),
                    value: _memberIsPaid,
                    onChanged: (value) => setState(() => _memberIsPaid = value),
                  ),
                  if (_kind != 'family')
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Current receiver'),
                      value: _memberIsReceiver,
                      onChanged: (value) => setState(() => _memberIsReceiver = value),
                    ),
                  const SizedBox(height: 12),
                  AppButton(
                    onPressed: _addingMember ? null : _addMember,
                        child: Text(_addingMember ? 'Loading...' : 'Add Member'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Members', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_members.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No members yet'),
                    )
                  else
                    ..._members.map(
                      (member) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(member.name?.isNotEmpty == true ? member.name! : member.id),
                        subtitle: Text('${member.phone ?? '-'} • Order ${member.turnOrder}'),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            if (member.isReceiver)
                              const Chip(label: Text('Receiver')),
                            if (member.isPaid)
                              const Chip(label: Text('Paid')),
                          ],
                        ),
                      ),
                    ),
                  if (_kind == 'family') ...[
                    const Divider(),
                    Text('Fund transactions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    AppInput(
                      controller: _transactionAmountController,
                      labelText: 'Amount',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    AppInput(
                      controller: _transactionNoteController,
                      labelText: 'Note',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _transactionType,
                      decoration: const InputDecoration(labelText: 'Transaction type'),
                      items: const [
                        DropdownMenuItem(value: 'in', child: Text('In')),
                        DropdownMenuItem(value: 'out', child: Text('Out')),
                      ],
                      onChanged: (value) => setState(() => _transactionType = value ?? 'in'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _approvalMemberId,
                      decoration: const InputDecoration(labelText: 'Approver'),
                      items: _members
                          .map(
                            (m) => DropdownMenuItem(
                              value: m.id,
                              child: Text(m.name?.isNotEmpty == true ? m.name! : m.id),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _approvalMemberId = value),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      onPressed: _addingTransaction ? null : _addFundTransaction,
                      child: Text(_addingTransaction ? 'Loading...' : 'Add Transaction'),
                    ),
                    const SizedBox(height: 16),
                    if (data.fundTransactions.isEmpty)
                      const Text('No fund transactions')
                    else
                      ...data.fundTransactions.map(
                        (transaction) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('${transaction.type.toUpperCase()} - ${numberFormat.format(transaction.amount)}'),
                          subtitle: Text(transaction.note ?? transaction.createdAt ?? '-'),
                          trailing: transaction.status == 'approved'
                              ? const Chip(label: Text('Approved'))
                              : AppButton(
                                  size: AppButtonSize.sm,
                                  onPressed: () => _approveTransaction(transaction.id),
                                  child: const Text('Approve'),
                                ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('History', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (data.history.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No history yet'),
                    )
                  else
                    ...data.history.map(
                      (entry) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Month ${entry.month}'),
                        subtitle: Text(
                          'Receiver: ${entry.receiverName ?? '-'} | Paid: ${entry.paidCount} | Collected: ${numberFormat.format(entry.totalCollected)} ${l10n.sar}',
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

  const _SummaryCard({required this.title, required this.value});

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
