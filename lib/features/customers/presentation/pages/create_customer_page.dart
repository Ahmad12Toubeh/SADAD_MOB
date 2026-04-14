import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/ui/ui.dart';
import '../../../../shared/utils/snackbar_helper.dart';
import '../../../../shared/utils/utils.dart';
import '../providers/customers_provider.dart';

class CreateCustomerPage extends ConsumerStatefulWidget {
  const CreateCustomerPage({super.key});

  @override
  ConsumerState<CreateCustomerPage> createState() => _CreateCustomerPageState();
}

class _CreateCustomerPageState extends ConsumerState<CreateCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _crController = TextEditingController();
  final _notesController = TextEditingController();

  String _type = 'individual';
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _crController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (!PhoneUtils.isValidJordan07(_phoneController.text.trim())) {
      SnackbarHelper.error(context, '07XXXXXXXX');
      return;
    }

    setState(() => _saving = true);
    try {
      final created = await ref.read(customersProvider.notifier).createCustomer({
        'type': _type,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        'cr': _crController.text.trim().isEmpty ? null : _crController.text.trim(),
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      });
      if (!mounted) return;
      SnackbarHelper.success(context, 'Customer created');
      final returnTo = GoRouterState.of(context).uri.queryParameters['returnTo'];
      if (returnTo == 'debt' && created.id.isNotEmpty) {
        context.go('/debts/new?step=2&customerId=${created.id}');
      } else {
        context.go('/customers');
      }
    } catch (e) {
      if (mounted) SnackbarHelper.error(context, e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addCustomer)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: AppCard(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Customer',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This mirrors the web customer creation flow.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ChoiceChip(
                          label: const Text('Individual'),
                          selected: _type == 'individual',
                          onSelected: (_) => setState(() => _type = 'individual'),
                        ),
                        ChoiceChip(
                          label: const Text('Company'),
                          selected: _type == 'company',
                          onSelected: (_) => setState(() => _type = 'company'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppInput(
                      controller: _nameController,
                      labelText: _type == 'company' ? 'Company Name' : 'Full Name',
                      hintText: _type == 'company' ? 'Company Name' : 'Full Name',
                      validator: Validators.required,
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      controller: _phoneController,
                      labelText: l10n.phoneLabel,
                      hintText: '07XXXXXXXX',
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
                    const SizedBox(height: 16),
                    AppInput(
                      controller: _emailController,
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        return Validators.email(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      controller: _addressController,
                      labelText: 'Address',
                    ),
                    if (_type == 'company') ...[
                      const SizedBox(height: 16),
                      AppInput(
                        controller: _crController,
                        labelText: 'CR',
                      ),
                    ],
                    const SizedBox(height: 16),
                    AppInput(
                      controller: _notesController,
                      labelText: l10n.notesLabel,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            onPressed: _saving ? null : _submit,
                            child: Text(_saving ? 'Saving...' : l10n.saveChanges),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            variant: AppButtonVariant.outline,
                            onPressed: _saving ? null : () => context.go('/customers'),
                            child: Text(l10n.cancel),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
