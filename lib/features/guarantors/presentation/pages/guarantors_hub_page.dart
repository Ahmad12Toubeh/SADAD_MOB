import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/ui/ui.dart';
import '../providers/guarantors_provider.dart';

class GuarantorsHubPage extends ConsumerStatefulWidget {
  const GuarantorsHubPage({super.key});

  @override
  ConsumerState<GuarantorsHubPage> createState() => _GuarantorsHubPageState();
}

class _GuarantorsHubPageState extends ConsumerState<GuarantorsHubPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guarantorsAsync = ref.watch(guarantorsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final numberFormat = NumberFormat.decimalPattern(l10n.locale.languageCode);
    final query = _searchController.text.trim().toLowerCase();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.guarantorsTitle,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AppCard(
              child: AppInput(
                controller: _searchController,
                labelText: l10n.searchGuarantor,
                prefixIcon: const Icon(Icons.search),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 20),
            guarantorsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => AppCard(child: Text('${l10n.error}: $err')),
              data: (guarantors) {
                final filtered = query.isEmpty
                    ? guarantors
                    : guarantors.where((g) {
                        return g.name.toLowerCase().contains(query) ||
                            (g.phone?.toLowerCase().contains(query) ?? false);
                      }).toList();

                if (filtered.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.person_search_outlined,
                    title: l10n.noGuarantors,
                    description: l10n.guarantorsTitle,
                  );
                }

                return Column(
                  children: filtered.map((guarantor) {
                    final riskColor = guarantor.debtStatus == 'paid'
                        ? Colors.green
                        : (guarantor.debtStatus == 'late' || guarantor.debtStatus == 'bad')
                            ? Colors.red
                            : Colors.blue;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              guarantor.name.isNotEmpty ? guarantor.name[0] : '?',
                              style: TextStyle(color: theme.colorScheme.primary),
                            ),
                          ),
                          title: Text(guarantor.name),
                          subtitle: Text(
                            '${guarantor.phone ?? '-'}\n${l10n.totalCapital}: ${numberFormat.format(guarantor.totalDebt)} ${l10n.sar}',
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: riskColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              guarantor.debtStatus == 'paid'
                                  ? l10n.safe
                                  : (guarantor.debtStatus == 'late' || guarantor.debtStatus == 'bad')
                                      ? l10n.warning
                                      : l10n.active,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: riskColor,
                              ),
                            ),
                          ),
                          onTap: () => context.push('/guarantors/${guarantor.id}'),
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
