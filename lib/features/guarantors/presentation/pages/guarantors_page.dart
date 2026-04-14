import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../providers/guarantors_provider.dart';

class GuarantorsPage extends ConsumerStatefulWidget {
  const GuarantorsPage({super.key});

  @override
  ConsumerState<GuarantorsPage> createState() => _GuarantorsPageState();
}

class _GuarantorsPageState extends ConsumerState<GuarantorsPage> {
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

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.guarantorsTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchGuarantor,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: guarantorsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('${l10n.error}: $err')),
              data: (guarantors) {
                final query = _searchController.text.toLowerCase();
                final filtered = query.isEmpty
                    ? guarantors
                    : guarantors
                        .where((g) =>
                            g.name.toLowerCase().contains(query) ||
                            (g.phone?.contains(query) ?? false),)
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search_outlined,
                            size: 64, color: Colors.grey.shade400,),
                        const SizedBox(height: 16),
                        Text(l10n.noGuarantors,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final guarantor = filtered[index];
                    final riskColor = guarantor.debtStatus == 'paid'
                        ? Colors.green
                        : (guarantor.debtStatus == 'late' || guarantor.debtStatus == 'bad')
                            ? Colors.red
                            : Colors.blue;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            guarantor.name.isNotEmpty ? guarantor.name[0] : '?',
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                        ),
                        title: Text(guarantor.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  guarantor.phone ?? '-',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${l10n.totalCapital}: ${numberFormat.format(guarantor.totalDebt)} ${l10n.sar}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: riskColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            guarantor.debtStatus == 'paid'
                                ? l10n.safe
                                : (guarantor.debtStatus == 'late' || guarantor.debtStatus == 'bad')
                                    ? l10n.warning
                                    : l10n.active,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: riskColor,
                            ),
                          ),
                        ),
                        onTap: () {
                          // TODO: Navigate to guarantor detail
                        },
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
}
