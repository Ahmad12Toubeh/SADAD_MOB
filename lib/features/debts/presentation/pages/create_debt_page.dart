import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/ui/ui.dart';
import '../../../../shared/utils/snackbar_helper.dart';
import '../../../../shared/utils/utils.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../providers/debts_provider.dart';

class CreateDebtPage extends ConsumerStatefulWidget {
  const CreateDebtPage({super.key});

  @override
  ConsumerState<CreateDebtPage> createState() => _CreateDebtPageState();
}

class _CreateDebtPageState extends ConsumerState<CreateDebtPage> {
  final _amountController = TextEditingController();
  final _initialPaymentController = TextEditingController();
  final _installmentCountController = TextEditingController();
  final _guarantorNameController = TextEditingController();
  final _guarantorPhoneController = TextEditingController();
  final _guarantorNotesController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();
  final _dueDateController = TextEditingController();

  String _step = 'customer';
  String _planType = 'one_time';
  String _installmentPeriod = 'monthly';
  String _category = 't1';
  String? _customerId;
  String? _customerName;
  DateTime? _dueDate;
  bool _hasGuarantor = false;
  bool _submitting = false;
  List<Customer> _customerResults = const [];
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final state = GoRouterState.of(context);
    final qp = state.uri.queryParameters;
    final customerId = qp['customerId'];
    final stepParam = qp['step'];
    if (stepParam != null) {
      final parsed = int.tryParse(stepParam);
      if (parsed != null && parsed >= 1 && parsed <= 5) {
        _step = switch (parsed) {
          1 => 'customer',
          2 => 'details',
          3 => 'plan',
          4 => 'guarantor',
          _ => 'review',
        };
      }
    }
    if (customerId != null && customerId.isNotEmpty) {
      _customerId = customerId;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final customer = await ref.read(customersProvider.notifier).getCustomer(customerId);
        if (!mounted) return;
        setState(() {
          _customerName = customer.name;
          if (_step == 'customer') _step = 'details';
        });
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(customersProvider.notifier).refresh();
      if (!mounted) return;
      setState(() {
        _customerResults = ref.read(customersProvider).valueOrNull ?? const [];
      });
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _initialPaymentController.dispose();
    _installmentCountController.dispose();
    _guarantorNameController.dispose();
    _guarantorPhoneController.dispose();
    _guarantorNotesController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _searchCustomers(String q) async {
    await ref.read(customersProvider.notifier).loadCustomers(search: q);
    if (!mounted) return;
    setState(() {
      _customerResults = ref.read(customersProvider).valueOrNull ?? const [];
    });
  }

  int _stepIndex() {
    return switch (_step) {
      'customer' => 1,
      'details' => 2,
      'plan' => 3,
      'guarantor' => 4,
      _ => 5,
    };
  }

  void _next() {
    if (_step == 'customer' && _customerId == null) {
      SnackbarHelper.error(context, 'Choose a customer first');
      return;
    }
    if (_step == 'details' && (double.tryParse(_amountController.text) ?? 0) <= 0) {
      SnackbarHelper.error(context, 'Invalid amount');
      return;
    }
    if (_step == 'plan' && _planType == 'installments' && (int.tryParse(_installmentCountController.text) ?? 0) < 1) {
      SnackbarHelper.error(context, 'Invalid installment count');
      return;
    }
    if (_step == 'guarantor' && _hasGuarantor && !PhoneUtils.isValidJordan07(_guarantorPhoneController.text.trim())) {
      SnackbarHelper.error(context, '07XXXXXXXX');
      return;
    }
    setState(() {
      _step = switch (_step) {
        'customer' => 'details',
        'details' => 'plan',
        'plan' => 'guarantor',
        'guarantor' => 'review',
        _ => 'review',
      };
    });
  }

  void _prev() {
    setState(() {
      _step = switch (_step) {
        'details' => 'customer',
        'plan' => 'details',
        'guarantor' => 'plan',
        'review' => 'guarantor',
        _ => 'customer',
      };
    });
  }

  Future<void> _submit() async {
    if (_customerId == null) {
      SnackbarHelper.error(context, 'Choose a customer first');
      return;
    }
    setState(() => _submitting = true);
    try {
      final initialPayment = double.tryParse(_initialPaymentController.text);
      final initialPaymentAmount = initialPayment == null ? null : initialPayment.clamp(0, double.infinity).toDouble();
      final debt = await ref.read(debtsProvider.notifier).createDebt({
        'customerId': _customerId,
        'principalAmount': double.tryParse(_amountController.text) ?? 0,
        'initialPaymentAmount': initialPaymentAmount,
        'currency': 'JOD',
        'planType': _planType,
        'dueDate': _dueDate?.toIso8601String(),
        'category': _category,
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        'installmentsPlan': _planType == 'installments'
            ? {
                'count': int.tryParse(_installmentCountController.text) ?? 0,
                'period': _installmentPeriod,
              }
            : null,
        'hasGuarantor': _hasGuarantor,
        'guarantor': _hasGuarantor
            ? {
                'name': _guarantorNameController.text.trim(),
                'phone': _guarantorPhoneController.text.trim(),
                'notes': _guarantorNotesController.text.trim().isEmpty ? null : _guarantorNotesController.text.trim(),
              }
            : null,
      });
      if (!mounted) return;
      context.go('/debts/${debt.id}');
    } catch (e) {
      if (mounted) SnackbarHelper.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final numberFormat = NumberFormat.decimalPattern(l10n.locale.languageCode);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addDebt)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.addDebt,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['customer', 'details', 'plan', 'guarantor', 'review'].map((s) {
                  final isActive = _step == s;
                  final isDone = _stepIndex() > ['customer', 'details', 'plan', 'guarantor', 'review'].indexOf(s) + 1;
                  return CircleAvatar(
                    backgroundColor: isActive || isDone ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: isActive || isDone ? Colors.white : theme.colorScheme.onSurfaceVariant,
                    child: Text('${['customer', 'details', 'plan', 'guarantor', 'review'].indexOf(s) + 1}'),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            AppCard(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: switch (_step) {
                  'customer' => _buildCustomerStep(theme),
                  'details' => _buildDetailsStep(l10n),
                  'plan' => _buildPlanStep(l10n),
                  'guarantor' => _buildGuarantorStep(l10n),
                  _ => _buildReviewStep(l10n, numberFormat),
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                AppButton(
                  variant: AppButtonVariant.outline,
                  onPressed: _step == 'customer' ? null : _prev,
                  child: const Text('Back'),
                ),
                const Spacer(),
                if (_step != 'review')
                  AppButton(
                    onPressed: _next,
                    child: const Text('Next'),
                  )
                else
                  AppButton(
                    onPressed: _submitting ? null : _submit,
                    child: Text(_submitting ? 'Saving...' : 'Confirm'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select customer', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        AppInput(
          controller: _searchController,
          labelText: 'Search customers',
          prefixIcon: const Icon(Icons.search),
          onChanged: (value) {
            _searchCustomers(value);
          },
        ),
        const SizedBox(height: 16),
        ...(_customerResults.take(6).map((customer) {
          final selected = _customerId == customer.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              child: ListTile(
                selected: selected,
                title: Text(customer.name),
                subtitle: Text(customer.phone),
                trailing: selected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                onTap: () {
                  setState(() {
                    _customerId = customer.id;
                    _customerName = customer.name;
                  });
                },
              ),
            ),
          );
        })),
        const SizedBox(height: 12),
        AppButton(
          variant: AppButtonVariant.outline,
          onPressed: () => context.push('/customers/new?returnTo=debt'),
          child: const Text('Add New Customer'),
        ),
      ],
    );
  }

  Widget _buildDetailsStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Debt details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('Customer: ${_customerName ?? _customerId ?? "-"}'),
        const SizedBox(height: 16),
        AppInput(
          controller: _amountController,
          labelText: l10n.amount,
          keyboardType: TextInputType.number,
          validator: Validators.amount,
        ),
        const SizedBox(height: 12),
        AppInput(
          controller: _initialPaymentController,
          labelText: 'Initial payment',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            return Validators.amount(value);
          },
        ),
        const SizedBox(height: 12),
        AppInput(
          controller: _dueDateController,
          labelText: 'Due date',
          readOnly: true,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 3650)),
              initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 30)),
            );
            if (picked == null) return;
            setState(() {
              _dueDate = picked;
              _dueDateController.text = picked.toIso8601String().split('T').first;
            });
          },
        ),
        const SizedBox(height: 12),
        AppInput(
          controller: _notesController,
          labelText: 'Notes',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPlanStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Plan type', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ChoiceChip(
          label: const Text('One Time'),
          selected: _planType == 'one_time',
          onSelected: (_) => setState(() => _planType = 'one_time'),
        ),
        const SizedBox(height: 8),
        ChoiceChip(
          label: const Text('Installments'),
          selected: _planType == 'installments',
          onSelected: (_) => setState(() => _planType = 'installments'),
        ),
        const SizedBox(height: 16),
        if (_planType == 'installments') ...[
          AppInput(
            controller: _installmentCountController,
            labelText: 'Installment count',
            keyboardType: TextInputType.number,
            validator: Validators.required,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _installmentPeriod,
            items: const [
              DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
            ],
            onChanged: (value) => setState(() => _installmentPeriod = value ?? 'monthly'),
            decoration: const InputDecoration(labelText: 'Period'),
          ),
        ],
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _category,
          items: const [
            DropdownMenuItem(value: 't1', child: Text('Invoice')),
            DropdownMenuItem(value: 't2', child: Text('Loan')),
            DropdownMenuItem(value: 't3', child: Text('Other')),
          ],
          onChanged: (value) => setState(() => _category = value ?? 't1'),
          decoration: const InputDecoration(labelText: 'Type'),
        ),
      ],
    );
  }

  Widget _buildGuarantorStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Guarantor', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Has guarantor'),
          value: _hasGuarantor,
          onChanged: (v) => setState(() => _hasGuarantor = v),
        ),
        if (_hasGuarantor) ...[
          AppInput(controller: _guarantorNameController, labelText: 'Guarantor name'),
          const SizedBox(height: 12),
          AppInput(
            controller: _guarantorPhoneController,
            labelText: 'Guarantor phone',
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              final sanitized = PhoneUtils.sanitizeJordan07Input(value);
              if (sanitized != value) {
                _guarantorPhoneController.value = TextEditingValue(
                  text: sanitized,
                  selection: TextSelection.collapsed(offset: sanitized.length),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          AppInput(controller: _guarantorNotesController, labelText: 'Guarantor notes', maxLines: 3),
        ],
      ],
    );
  }

  Widget _buildReviewStep(AppLocalizations l10n, NumberFormat numberFormat) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final initial = double.tryParse(_initialPaymentController.text) ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _ReviewRow(label: 'Customer', value: _customerName ?? _customerId ?? '-'),
        _ReviewRow(label: 'Amount', value: '${numberFormat.format(amount)} ${l10n.sar}'),
        _ReviewRow(label: 'Initial payment', value: '${numberFormat.format(initial)} ${l10n.sar}'),
        _ReviewRow(label: 'Plan', value: _planType),
        _ReviewRow(label: 'Type', value: _category),
        _ReviewRow(label: 'Guarantor', value: _hasGuarantor ? _guarantorNameController.text : 'None'),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
