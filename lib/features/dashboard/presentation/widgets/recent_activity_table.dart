import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../providers/dashboard_provider.dart';

class RecentActivityTable extends StatelessWidget {
  final List<RecentDebt> recentDebts;
  const RecentActivityTable({super.key, required this.recentDebts});

  Color _statusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'late':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'paid':
        return l10n.statusPaid;
      case 'late':
        return l10n.statusLate;
      default:
        return l10n.statusActive;
    }
  }

  String _typeLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case 'invoice':
        return l10n.typeInvoice;
      case 'loan':
        return l10n.typeLoan;
      default:
        return l10n.typeOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.recentActivity,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(l10n.viewAll),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentDebts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        l10n.noResults,
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    Colors.grey.shade100,
                  ),
                  columns: [
                    DataColumn(label: Text(l10n.customersTitle.substring(0, l10n.customersTitle.length - 1))),
                    DataColumn(label: Text(l10n.amount)),
                    DataColumn(label: Text(l10n.type)),
                    DataColumn(label: Text(l10n.dueDate)),
                    DataColumn(label: Text(l10n.status)),
                  ],
                  rows: recentDebts.map((debt) {
                    final statusColor = _statusColor(debt.status);
                    return DataRow(cells: [
                      DataCell(Text(debt.customerName)),
                      DataCell(Text('${debt.principalAmount.toLocaleString()} ${l10n.sar}')),
                      DataCell(Text(_typeLabel(debt.type, l10n))),
                      DataCell(Text(
                        DateFormat('yyyy/MM/dd').format(debt.dueDate),
                      )),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _statusLabel(debt.status, l10n),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
