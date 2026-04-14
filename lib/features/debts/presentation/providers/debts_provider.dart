import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';

class Debt {
  final String id;
  final String customerId;
  final String customerName;
  final num principalAmount;
  final String type;
  final DateTime dueDate;
  final String status;

  const Debt({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.principalAmount,
    required this.type,
    required this.dueDate,
    required this.status,
  });
}

class DebtsNotifier extends AsyncNotifier<List<Debt>> {
  @override
  List<Debt> build() {
    _fetchDebts();
    return [];
  }

  Future<void> _fetchDebts() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get('/debts');
      final data = response.data;

      final items = data is List ? data : (data?['items'] as List? ?? []);
      return items.map((item) => Debt(
            id: item['id']?.toString() ?? '',
            customerId: item['customerId']?.toString() ?? '',
            customerName: item['customerName']?.toString() ?? '',
            principalAmount: item['principalAmount'] ?? 0,
            type: item['type']?.toString() ?? '',
            dueDate: item['dueDate'] != null
                ? DateTime.tryParse(item['dueDate'].toString()) ?? DateTime.now()
                : DateTime.now(),
            status: item['status']?.toString() ?? 'active',
          ),).toList();
    });
  }

  Future<void> refresh() async {
    await _fetchDebts();
  }
}

final debtsProvider =
    AsyncNotifierProvider<DebtsNotifier, List<Debt>>(DebtsNotifier.new);
