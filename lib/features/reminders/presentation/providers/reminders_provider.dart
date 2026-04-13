import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../pages/reminders_page.dart';

final remindersProvider = FutureProvider<RemindersData>((ref) async {
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
