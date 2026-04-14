import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../shared/ui/ui.dart';
import '../../../../shared/utils/snackbar_helper.dart';
import '../models/reminders_models.dart';
import '../providers/reminders_provider.dart';

class RemindersHubPage extends ConsumerWidget {
  const RemindersHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final numberFormat = NumberFormat.decimalPattern(l10n.locale.languageCode);

    return Scaffold(
      body: remindersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('${l10n.error}: $err')),
        data: (reminders) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.remindersTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.remindersSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                _ReminderSection(
                  title: '${l10n.overdue} (${reminders.overdue.length})',
                  icon: Icons.warning_amber_rounded,
                  iconColor: Colors.red,
                  items: reminders.overdue,
                  l10n: l10n,
                  numberFormat: numberFormat,
                  isOverdue: true,
                ),
                const SizedBox(height: 24),
                _ReminderSection(
                  title: '${l10n.upcoming} (${reminders.upcoming.length})',
                  icon: Icons.access_time_rounded,
                  iconColor: Colors.orange,
                  items: reminders.upcoming,
                  l10n: l10n,
                  numberFormat: numberFormat,
                  isOverdue: false,
                ),
                const SizedBox(height: 24),
                _SentSection(
                  title: l10n.sent,
                  icon: Icons.check_circle_rounded,
                  iconColor: Colors.green,
                  items: reminders.sent,
                  l10n: l10n,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReminderSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<ReminderItem> items;
  final AppLocalizations l10n;
  final NumberFormat numberFormat;
  final bool isOverdue;

  const _ReminderSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.items,
    required this.l10n,
    required this.numberFormat,
    required this.isOverdue,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AppCard(
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8),
            Text(l10n.noResults),
          ],
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: iconColor),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            '${isOverdue ? _getOverdueDays(item.dueDate) : _getUpcomingDays(item.dueDate)}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                              '${isOverdue ? "${_getOverdueDays(item.dueDate)} ${l10n.daysOverdue}" : "${_getUpcomingDays(item.dueDate)} ${l10n.daysRemaining}"} • ${l10n.amount}: ${numberFormat.format(item.amount)} ${l10n.sar}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ReminderActions(
                    installmentId: item.installmentId ?? item.id,
                    debtId: item.id,
                    customerName: item.customerName,
                    customerEmail: item.customerEmail,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SentSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<SentReminder> items;
  final AppLocalizations l10n;

  const _SentSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.items,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AppCard(
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8),
            Text(l10n.noResults),
          ],
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
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: iconColor)),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.notifications_none, color: Colors.grey.shade400),
                title: Text(item.customer ?? '-'),
                subtitle: Text('${item.channel ?? '-'} - ${item.sentAt ?? '-'}'),
                trailing: const Chip(label: Text('Sent')),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReminderActions extends ConsumerWidget {
  final String? installmentId;
  final String? debtId;
  final String? customerName;
  final String? customerEmail;

  const _ReminderActions({
    required this.installmentId,
    required this.debtId,
    required this.customerName,
    required this.customerEmail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(remindersProvider.notifier);
    bool sendingWhatsapp = false;
    bool sendingEmail = false;

    Future<void> send(String channel) async {
      try {
        final result = await notifier.sendReminder(
          channel: channel,
          installmentId: installmentId,
          debtId: debtId,
        );
        final targetLabel = customerName?.isNotEmpty == true ? ' for $customerName' : '';
        if (channel == 'whatsapp') {
          final link = result.whatsappLink;
          if (link != null && link.isNotEmpty) {
            await launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
          } else {
            SnackbarHelper.success(context, 'WhatsApp reminder sent$targetLabel');
          }
        } else {
          SnackbarHelper.success(context, 'Email reminder sent$targetLabel');
        }
        await notifier.refresh();
      } catch (e) {
        SnackbarHelper.error(context, e.toString());
      }
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            AppButton(
              size: AppButtonSize.sm,
              onPressed: (installmentId == null && debtId == null) || sendingWhatsapp
                  ? null
                  : () async {
                      setState(() => sendingWhatsapp = true);
                      try {
                        await send('whatsapp');
                      } finally {
                        if (context.mounted) setState(() => sendingWhatsapp = false);
                      }
                    },
              child: Text(sendingWhatsapp ? 'Loading...' : 'WhatsApp'),
            ),
            AppButton(
              size: AppButtonSize.sm,
              variant: AppButtonVariant.outline,
              onPressed: (installmentId == null && debtId == null) || sendingEmail || customerEmail == null
                  ? null
                  : () async {
                      setState(() => sendingEmail = true);
                      try {
                        await send('email');
                      } finally {
                        if (context.mounted) setState(() => sendingEmail = false);
                      }
                    },
              child: Text(sendingEmail ? 'Loading...' : 'Email'),
            ),
          ],
        );
      },
    );
  }
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
