import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../providers/reminders_provider.dart';

class RemindersPage extends ConsumerStatefulWidget {
  const RemindersPage({super.key});

  @override
  ConsumerState<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends ConsumerState<RemindersPage> {
  @override
  Widget build(BuildContext context) {
    final remindersAsync = ref.watch(remindersProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final numberFormat = NumberFormat.decimalPattern(l10n.locale.languageCode);

    return Scaffold(
      body: remindersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('${l10n.error}: $err')),
        data: (reminders) {
          final overdue = reminders.overdue;
          final upcoming = reminders.upcoming;
          final sent = reminders.sent;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.remindersTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.remindersSubtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Overdue Section
                _buildSection(
                  context,
                  title: '${l10n.overdue} (${overdue.length})',
                  icon: Icons.warning_amber_rounded,
                  iconColor: Colors.red,
                  items: overdue,
                  l10n: l10n,
                  numberFormat: numberFormat,
                  theme: theme,
                  isOverdue: true,
                ),

                const SizedBox(height: 24),

                // Upcoming Section
                _buildSection(
                  context,
                  title: '${l10n.upcoming} (${upcoming.length})',
                  icon: Icons.access_time_rounded,
                  iconColor: Colors.orange,
                  items: upcoming,
                  l10n: l10n,
                  numberFormat: numberFormat,
                  theme: theme,
                  isOverdue: false,
                ),

                const SizedBox(height: 24),

                // Sent Section
                _buildSentSection(
                  context,
                  title: l10n.sent,
                  icon: Icons.check_circle_rounded,
                  iconColor: Colors.green,
                  items: sent,
                  l10n: l10n,
                  theme: theme,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<ReminderItem> items,
    required AppLocalizations l10n,
    required NumberFormat numberFormat,
    required ThemeData theme,
    required bool isOverdue,
  }) {
    if (items.isEmpty) {
      return Card(
        color: isOverdue ? Colors.red.shade50 : Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.noResults,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) {
          final days = isOverdue
              ? _getOverdueDays(item.dueDate)
              : _getUpcomingDays(item.dueDate);
          final daysText = isOverdue
              ? '$days ${l10n.daysOverdue}'
              : '$days ${l10n.daysRemaining}';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isOverdue ? Colors.red.shade50 : Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$days',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.customerName ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$daysText - ${l10n.amount}: ${numberFormat.format(item.amount)} ${l10n.sar}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      // TODO: Send reminder
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSentSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<SentReminder> items,
    required AppLocalizations l10n,
    required ThemeData theme,
  }) {
    if (items.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.noResults,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.notifications_none, color: Colors.grey.shade400),
              title: Text(item.customer ?? '-'),
              subtitle: Text('${item.channel} - ${item.sentAt ?? '-'}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.sent,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  int _getOverdueDays(String? dueDate) {
    if (dueDate == null) return 1;
    final today = DateTime.now();
    final due = DateTime.parse(dueDate);
    return today.difference(due).inDays.abs();
  }

  int _getUpcomingDays(String? dueDate) {
    if (dueDate == null) return 0;
    final today = DateTime.now();
    final due = DateTime.parse(dueDate);
    return due.difference(today).inDays.abs();
  }
}

class ReminderItem {
  final String? id;
  final String? installmentId;
  final String? customerName;
  final String? customerEmail;
  final double amount;
  final String? dueDate;

  ReminderItem({
    this.id,
    this.installmentId,
    this.customerName,
    this.customerEmail,
    required this.amount,
    this.dueDate,
  });

  factory ReminderItem.fromJson(Map<String, dynamic> json) {
    return ReminderItem(
      id: json['id'] as String?,
      installmentId: json['installmentId'] as String?,
      customerName: json['customerName'] as String?,
      customerEmail: json['customerEmail'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['dueDate'] as String?,
    );
  }
}

class SentReminder {
  final String id;
  final String? customer;
  final String? channel;
  final String? sentAt;

  SentReminder({
    required this.id,
    this.customer,
    this.channel,
    this.sentAt,
  });

  factory SentReminder.fromJson(Map<String, dynamic> json) {
    return SentReminder(
      id: json['id'] as String? ?? '',
      customer: json['customer'] as String?,
      channel: json['channel'] as String?,
      sentAt: json['sentAt'] as String?,
    );
  }
}

class RemindersData {
  final List<ReminderItem> overdue;
  final List<ReminderItem> upcoming;
  final List<SentReminder> sent;

  RemindersData({
    required this.overdue,
    required this.upcoming,
    required this.sent,
  });
}
