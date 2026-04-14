import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../models/reminders_models.dart';

class ReminderSendResult {
  final String? whatsappLink;
  final String? message;

  const ReminderSendResult({
    this.whatsappLink,
    this.message,
  });

  factory ReminderSendResult.fromJson(Map<String, dynamic> json) {
    return ReminderSendResult(
      whatsappLink: json['whatsappLink']?.toString(),
      message: json['message']?.toString(),
    );
  }
}

class RemindersNotifier extends AsyncNotifier<RemindersData> {
  @override
  RemindersData build() {
    loadReminders();
    return RemindersData(overdue: const [], upcoming: const [], sent: const []);
  }

  Future<void> loadReminders() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final apiClient = ref.read(apiClientProvider);
      final overdueResponse = await apiClient.get('/reminders/overdue');
      final upcomingResponse = await apiClient.get('/reminders/upcoming?days=7');
      final sentResponse = await apiClient.get('/reminders/sent');

      final overdue = (overdueResponse.data['items'] as List<dynamic>?)
              ?.map((item) => ReminderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];
      final upcoming = (upcomingResponse.data['items'] as List<dynamic>?)
              ?.map((item) => ReminderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];
      final sent = (sentResponse.data['items'] as List<dynamic>?)
              ?.map((item) => SentReminder.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [];

      return RemindersData(
        overdue: overdue,
        upcoming: upcoming,
        sent: sent,
      );
    });
  }

  Future<ReminderSendResult> sendReminder({
    required String channel,
    String? installmentId,
    String? debtId,
  }) async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.post(
      '/reminders/send',
      data: {
        'channel': channel,
        if (installmentId != null) 'installmentId': installmentId,
        if (debtId != null) 'debtId': debtId,
      },
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ReminderSendResult.fromJson(data);
    }
    if (data is Map) {
      return ReminderSendResult.fromJson(Map<String, dynamic>.from(data));
    }
    return const ReminderSendResult();
  }

  Future<void> refresh() async {
    await loadReminders();
  }
}

final remindersProvider =
    AsyncNotifierProvider<RemindersNotifier, RemindersData>(RemindersNotifier.new);
