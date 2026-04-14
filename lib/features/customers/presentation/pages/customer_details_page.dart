import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/ui/ui.dart';
import '../../../../shared/utils/snackbar_helper.dart';
import '../../../../shared/utils/utils.dart';
import '../providers/customers_provider.dart';

class CustomerDetailsPage extends ConsumerStatefulWidget {
  final String customerId;

  const CustomerDetailsPage({
    super.key,
    required this.customerId,
  });

  @override
  ConsumerState<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends ConsumerState<CustomerDetailsPage> {
  late Future<_CustomerDetailsData> _future;
  bool _editing = false;
  bool _saving = false;
  bool _deleting = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<_CustomerDetailsData> _load() async {
    final notifier = ref.read(customersProvider.notifier);
    final customer = await notifier.getCustomer(widget.customerId);
    final debts = await notifier.getCustomerDebts(widget.customerId);
    _nameController.text = customer.name;
    _phoneController.text = customer.phone;
    _emailController.text = customer.email ?? '';
    _addressController.text = customer.address ?? '';
    return _CustomerDetailsData(customer: customer, debts: debts);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _save(Customer customer) async {
    if (!_formKey.currentState!.validate()) return;
    if (!PhoneUtils.isValidJordan07(_phoneController.text.trim())) {
      SnackbarHelper.error(context, '07XXXXXXXX');
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(customersProvider.notifier).updateCustomer(widget.customerId, {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        'type': customer.type,
        'cr': customer.cr,
        'notes': customer.notes,
        'proofImageUrl': customer.proofImageUrl,
        'proofImagePublicId': customer.proofImagePublicId,
      });
      if (!mounted) return;
      SnackbarHelper.success(context, 'Customer updated');
      await _refresh();
      if (mounted) setState(() => _editing = false);
    } catch (e) {
      if (mounted) SnackbarHelper.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _cancelEditing() async {
    await _refresh();
    if (mounted) setState(() => _editing = false);
  }

  Future<void> _deleteCustomer() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AppDialog(
        title: 'Delete Customer',
        content: const Text('This customer and all related data will be deleted permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _deleting = true);
    try {
      await ref.read(customersProvider.notifier).deleteCustomer(widget.customerId);
      if (!mounted) return;
      SnackbarHelper.success(context, 'Customer deleted');
      context.go('/customers');
    } catch (e) {
      if (mounted) SnackbarHelper.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final numberFormat = NumberFormat.decimalPattern(l10n.locale.languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customersTitle),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<_CustomerDetailsData>(
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

          final customer = data.customer;
          final debts = data.debts;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              _MetaChip(icon: Icons.phone_outlined, text: customer.phone),
                              if (customer.email != null && customer.email!.isNotEmpty)
                                _MetaChip(icon: Icons.email_outlined, text: customer.email!),
                              if (customer.address != null && customer.address!.isNotEmpty)
                                _MetaChip(icon: Icons.location_on_outlined, text: customer.address!),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 12,
                      children: [
                        AppButton(
                          variant: AppButtonVariant.outline,
                          onPressed: _editing ? null : () => setState(() => _editing = true),
                          child: const Text('Edit'),
                        ),
                        AppButton(
                          variant: AppButtonVariant.destructive,
                          onPressed: _deleting ? null : _deleteCustomer,
                          child: Text(_deleting ? 'Deleting...' : 'Delete'),
                        ),
                          AppButton(
                            onPressed: () => context.push('/debts/new?step=2&customerId=${widget.customerId}'),
                            child: const Text('Add Debt'),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _SummaryCard(title: 'Total Debt', value: '${numberFormat.format(customer.totalDebt)} ${l10n.sar}', color: Colors.blue),
                    _SummaryCard(title: 'Paid Amount', value: '${numberFormat.format(debts.where((d) => d.status == 'paid').fold<num>(0, (p, d) => p + d.principalAmount))} ${l10n.sar}', color: Colors.green),
                    _SummaryCard(title: 'Remaining Amount', value: '${numberFormat.format(debts.where((d) => d.status != 'paid').fold<num>(0, (p, d) => p + d.principalAmount))} ${l10n.sar}', color: Colors.orange),
                  ],
                ),
                const SizedBox(height: 24),
                AppCard(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Transactions',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Divider(height: 1),
                      if (debts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: AppEmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: 'No debts yet',
                            description: 'This customer has no linked debts.',
                          ),
                        )
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('#')),
                              DataColumn(label: Text('Type')),
                              DataColumn(label: Text('Amount')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Due Date')),
                            ],
                            rows: debts
                                .map(
                                  (debt) => DataRow(
                                    cells: [
                                      DataCell(Text('#${debt.id.length > 6 ? debt.id.substring(debt.id.length - 6) : debt.id}')),
                                      DataCell(Text(debt.type)),
                                      DataCell(Text('${numberFormat.format(debt.principalAmount)} ${debt.currency}')),
                                      DataCell(Text(debt.status)),
                                      DataCell(Text(debt.dueDate ?? '-')),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_editing) ...[
                  const SizedBox(height: 24),
                  AppCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Edit Customer', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          AppInput(
                            controller: _nameController,
                            labelText: 'Full Name',
                            validator: Validators.required,
                          ),
                          const SizedBox(height: 12),
                          AppInput(
                            controller: _phoneController,
                            labelText: 'Phone',
                            keyboardType: TextInputType.phone,
                            validator: Validators.phone,
                            onChanged: (value) {
                              final sanitized = PhoneUtils.sanitizeJordan07Input(value);
                              if (sanitized != value) {
                                _phoneController.value = TextEditingValue(
                                  text: sanitized,
                                  selection: TextSelection.collapsed(offset: sanitized.length),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          AppInput(
                            controller: _emailController,
                            labelText: 'Email',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return null;
                              return Validators.email(value);
                            },
                          ),
                          const SizedBox(height: 12),
                          AppInput(controller: _addressController, labelText: 'Address'),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  onPressed: _saving ? null : () => _save(customer),
                                  child: Text(_saving ? 'Saving...' : 'Save'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppButton(
                                  variant: AppButtonVariant.outline,
                                  onPressed: _saving ? null : _cancelEditing,
                                  child: const Text('Cancel'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CustomerDetailsData {
  final Customer customer;
  final List<CustomerDebt> debts;

  const _CustomerDetailsData({required this.customer, required this.debts});
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color)),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
