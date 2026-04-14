import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';

class DashboardData {
  final num totalActiveDebt;
  final num collectedThisMonth;
  final num overdueAmount;
  final int activeCustomers;
  final String currency;
  final List<RecentDebt> recentActivity;

  const DashboardData({
    this.totalActiveDebt = 0,
    this.collectedThisMonth = 0,
    this.overdueAmount = 0,
    this.activeCustomers = 0,
    this.currency = 'ر.س',
    this.recentActivity = const [],
  });
}

class RecentDebt {
  final String id;
  final String customerName;
  final num principalAmount;
  final String type;
  final DateTime dueDate;
  final String status;

  const RecentDebt({
    required this.id,
    required this.customerName,
    required this.principalAmount,
    required this.type,
    required this.dueDate,
    required this.status,
  });
}

class DashboardNotifier extends AsyncNotifier<DashboardData> {
  @override
  DashboardData build() {
    _fetchData();
    return const DashboardData();
  }

  Future<void> _fetchData() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final apiClient = ref.read(apiClientProvider);

      final results = await Future.wait([
        apiClient.get('/analytics/summary'),
        apiClient.get('/analytics/monthly', queryParameters: {'months': 6}),
        apiClient.get('/analytics/recent-activity', queryParameters: {'limit': 5}),
      ]);

      final summary = results[0].data;
      final recentRaw = results[2].data;

      final recentList = <RecentDebt>[];
      if (recentRaw is List) {
        for (final item in recentRaw) {
          recentList.add(RecentDebt(
            id: item['id']?.toString() ?? '',
            customerName: item['customerName']?.toString() ?? '',
            principalAmount: item['principalAmount'] ?? 0,
            type: item['type']?.toString() ?? '',
            dueDate: item['dueDate'] != null
                ? DateTime.tryParse(item['dueDate'].toString()) ?? DateTime.now()
                : DateTime.now(),
            status: item['status']?.toString() ?? 'active',
          ),);
        }
      }

      return DashboardData(
        totalActiveDebt: summary?['totalActiveDebt'] ?? 0,
        collectedThisMonth: summary?['collectedThisMonth'] ?? 0,
        overdueAmount: summary?['overdueAmount'] ?? 0,
        activeCustomers: summary?['activeCustomers'] ?? 0,
        currency: summary?['currency'] ?? 'ر.س',
        recentActivity: recentList,
      );
    });
  }

  Future<void> refresh() async {
    await _fetchData();
  }
}

final dashboardProvider =
    AsyncNotifierProvider<DashboardNotifier, DashboardData>(DashboardNotifier.new);
