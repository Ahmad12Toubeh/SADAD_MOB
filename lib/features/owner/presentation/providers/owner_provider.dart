import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';

class OwnerOverviewData {
  final int customersCount;
  final num totalCollected;
  final int activeSubscriptions;
  final int expiringSoon;
  final int trialUsers;
  final String currency;

  const OwnerOverviewData({
    this.customersCount = 0,
    this.totalCollected = 0,
    this.activeSubscriptions = 0,
    this.expiringSoon = 0,
    this.trialUsers = 0,
    this.currency = 'JOD',
  });
}

class OwnerPlan {
  final String id;
  final String name;
  final int months;
  final num price;
  final String currency;
  final String? description;
  final bool isActive;

  const OwnerPlan({
    required this.id,
    required this.name,
    required this.months,
    required this.price,
    required this.currency,
    this.description,
    required this.isActive,
  });
}

class OwnerUser {
  final String id;
  final String fullName;
  final String email;
  final String role;

  const OwnerUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });
}

class OwnerDashboardData {
  final bool allowed;
  final String? role;
  final OwnerOverviewData overview;
  final List<OwnerPlan> plans;
  final List<OwnerUser> users;

  const OwnerDashboardData({
    required this.allowed,
    this.role,
    this.overview = const OwnerOverviewData(),
    this.plans = const [],
    this.users = const [],
  });
}

class OwnerNotifier extends AsyncNotifier<OwnerDashboardData> {
  @override
  OwnerDashboardData build() {
    _fetch();
    return const OwnerDashboardData(allowed: false);
  }

  Future<void> _fetch() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final apiClient = ref.read(apiClientProvider);

      final profileResponse = await apiClient.get('/settings/profile');
      final profile = profileResponse.data as Map?;
      final role = (profile?['role']?.toString() ?? '').toLowerCase();
      final allowed = role == 'owner' || role == 'admin';

      if (!allowed) {
        return OwnerDashboardData(allowed: false, role: role);
      }

      final results = await Future.wait([
        apiClient.get('/settings/owner/overview'),
        apiClient.get('/settings/owner/plans'),
        apiClient.get('/settings/subscription/admin/users'),
      ]);

      final overviewRaw = results[0].data as Map?;
      final plansRaw = results[1].data;
      final usersRaw = results[2].data;

      final plans = <OwnerPlan>[];
      if (plansRaw is List) {
        for (final item in plansRaw) {
          if (item is! Map) continue;
          plans.add(
            OwnerPlan(
              id: item['id']?.toString() ?? '',
              name: item['name']?.toString() ?? '',
              months: item['months'] is num ? (item['months'] as num).toInt() : 0,
              price: item['price'] ?? 0,
              currency: item['currency']?.toString() ?? 'JOD',
              description: item['description']?.toString(),
              isActive: item['isActive'] == true,
            ),
          );
        }
      }

      final users = <OwnerUser>[];
      if (usersRaw is List) {
        for (final item in usersRaw) {
          if (item is! Map) continue;
          users.add(
            OwnerUser(
              id: item['id']?.toString() ?? '',
              fullName: item['fullName']?.toString() ?? '',
              email: item['email']?.toString() ?? '',
              role: item['role']?.toString() ?? '',
            ),
          );
        }
      }

      return OwnerDashboardData(
        allowed: true,
        role: role,
        overview: OwnerOverviewData(
          customersCount: overviewRaw?['customersCount'] is num
              ? (overviewRaw?['customersCount'] as num).toInt()
              : 0,
          totalCollected: overviewRaw?['totalCollected'] ?? 0,
          activeSubscriptions: overviewRaw?['activeSubscriptions'] is num
              ? (overviewRaw?['activeSubscriptions'] as num).toInt()
              : 0,
          expiringSoon: overviewRaw?['expiringSoon'] is num
              ? (overviewRaw?['expiringSoon'] as num).toInt()
              : 0,
          trialUsers: overviewRaw?['trialUsers'] is num
              ? (overviewRaw?['trialUsers'] as num).toInt()
              : 0,
          currency: overviewRaw?['currency']?.toString() ?? 'JOD',
        ),
        plans: plans,
        users: users,
      );
    });
  }

  Future<void> refresh() async {
    await _fetch();
  }
}

final ownerProvider =
    AsyncNotifierProvider<OwnerNotifier, OwnerDashboardData>(OwnerNotifier.new);
