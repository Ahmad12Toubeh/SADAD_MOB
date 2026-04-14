import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';

class Customer {
  final String id;
  final String name;
  final String phone;
  final num totalDebt;
  final int activeDebts;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.totalDebt = 0,
    this.activeDebts = 0,
  });
}

class CustomersNotifier extends AsyncNotifier<List<Customer>> {
  @override
  List<Customer> build() {
    _fetchCustomers();
    return [];
  }

  Future<void> _fetchCustomers() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get('/customers');
      final data = response.data;

      if (data is List) {
        return data.map((item) => Customer(
              id: item['id']?.toString() ?? '',
              name: item['name']?.toString() ?? '',
              phone: item['phone']?.toString() ?? '',
              totalDebt: item['totalDebt'] ?? 0,
              activeDebts: item['activeDebts'] ?? 0,
            ),).toList();
      }

      final items = data?['items'] as List? ?? [];
      return items.map((item) => Customer(
            id: item['id']?.toString() ?? '',
            name: item['name']?.toString() ?? '',
            phone: item['phone']?.toString() ?? '',
            totalDebt: item['totalDebt'] ?? 0,
            activeDebts: item['activeDebts'] ?? 0,
          ),).toList();
    });
  }

  Future<void> refresh() async {
    await _fetchCustomers();
  }
}

final customersProvider =
    AsyncNotifierProvider<CustomersNotifier, List<Customer>>(CustomersNotifier.new);
