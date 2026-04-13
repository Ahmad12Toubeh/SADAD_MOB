import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';

class MonthlyData {
  final int year;
  final int month;
  final num debts;
  final num collected;

  const MonthlyData({
    required this.year,
    required this.month,
    this.debts = 0,
    this.collected = 0,
  });
}

class AnalyticsData {
  final num totalDebt;
  final num totalCollected;
  final num remaining;
  final double collectionRate;
  final List<MonthlyData> monthly;

  const AnalyticsData({
    this.totalDebt = 0,
    this.totalCollected = 0,
    this.remaining = 0,
    this.collectionRate = 0,
    this.monthly = const [],
  });
}

class AnalyticsNotifier extends AsyncNotifier<AnalyticsData> {
  @override
  AnalyticsData build() {
    _fetchData();
    return const AnalyticsData();
  }

  Future<void> _fetchData() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final apiClient = ref.read(apiClientProvider);

      final results = await Future.wait([
        apiClient.get('/analytics/summary'),
        apiClient.get('/analytics/monthly', queryParameters: {'months': 12}),
      ]);

      final summary = results[0].data;
      final monthlyRaw = results[1].data;

      final monthlyList = <MonthlyData>[];
      if (monthlyRaw is List) {
        for (final item in monthlyRaw) {
          monthlyList.add(MonthlyData(
            year: item['year'] ?? 2024,
            month: item['month'] ?? 1,
            debts: item['debts'] ?? 0,
            collected: item['collected'] ?? 0,
          ));
        }
      }

      final totalDebt = summary?['totalActiveDebt'] ?? 0;
      final totalCollected = summary?['collectedThisMonth'] ?? 0;
      final remaining = (totalDebt as num) - (totalCollected as num);
      final rate = totalDebt > 0 ? (totalCollected / totalDebt * 100) : 0.0;

      return AnalyticsData(
        totalDebt: totalDebt,
        totalCollected: totalCollected,
        remaining: remaining < 0 ? 0 : remaining,
        collectionRate: rate,
        monthly: monthlyList,
      );
    });
  }
}

final analyticsProvider =
    AsyncNotifierProvider<AnalyticsNotifier, AnalyticsData>(AnalyticsNotifier.new);
