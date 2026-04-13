import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/network/auth_notifier.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.storeSettings,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: l10n.storeName,
                        prefixIcon: const Icon(Icons.store_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        labelText: l10n.currency,
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text(l10n.saveChanges),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appSettings,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(l10n.darkMode),
                      subtitle: Text(l10n.darkModeSubtitle),
                      value: _isDarkMode,
                      onChanged: (v) => setState(() => _isDarkMode = v),
                    ),
                    ListTile(
                      title: Text(l10n.language),
                      subtitle: Text(locale.languageCode == 'ar' ? 'العربية' : 'English'),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: () {
                        ref.read(localeProvider.notifier).toggle();
                      },
                    ),
                    SwitchListTile(
                      title: Text(l10n.notifications),
                      subtitle: Text(l10n.notificationsSubtitle),
                      value: true,
                      onChanged: (v) {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.account,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(l10n.profile),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: Text(l10n.changePassword),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: () {},
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.red.shade400),
                      title: Text(
                        l10n.logout,
                        style: TextStyle(color: Colors.red.shade400),
                      ),
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(l10n.logout),
                            content: Text(l10n.logoutConfirm),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(l10n.cancel),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text(l10n.logout),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && mounted) {
                          await ref.read(authNotifierProvider.notifier).logout();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
