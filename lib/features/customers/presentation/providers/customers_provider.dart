import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';

class Customer {
  final String id;
  final String type;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? cr;
  final String? notes;
  final String? proofImageUrl;
  final String? proofImagePublicId;
  final String status;
  final num totalDebt;
  final int activeDebts;
  final String? createdAt;
  final String? updatedAt;

  const Customer({
    required this.id,
    required this.type,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.cr,
    this.notes,
    this.proofImageUrl,
    this.proofImagePublicId,
    required this.status,
    this.totalDebt = 0,
    this.activeDebts = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<dynamic, dynamic> json) {
    final summary = json['summary'];
    return Customer(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'individual',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      cr: json['cr']?.toString(),
      notes: json['notes']?.toString(),
      proofImageUrl: json['proofImageUrl']?.toString(),
      proofImagePublicId: json['proofImagePublicId']?.toString(),
      status: json['status']?.toString() ?? 'regular',
      totalDebt: json['totalDebt'] is num
          ? json['totalDebt'] as num
          : summary is Map && summary['totalDebt'] is num
              ? summary['totalDebt'] as num
              : 0,
      activeDebts: json['activeDebts'] is num
          ? (json['activeDebts'] as num).toInt()
          : summary is Map && summary['activeDebts'] is num
              ? (summary['activeDebts'] as num).toInt()
              : 0,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}

class CustomerDebt {
  final String id;
  final String type;
  final num principalAmount;
  final String currency;
  final String planType;
  final String? dueDate;
  final String? category;
  final String status;
  final String? createdAt;

  const CustomerDebt({
    required this.id,
    required this.type,
    required this.principalAmount,
    required this.currency,
    required this.planType,
    this.dueDate,
    this.category,
    required this.status,
    this.createdAt,
  });

  factory CustomerDebt.fromJson(Map<dynamic, dynamic> json) {
    return CustomerDebt(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'other',
      principalAmount: json['principalAmount'] is num ? json['principalAmount'] as num : 0,
      currency: json['currency']?.toString() ?? 'JOD',
      planType: json['planType']?.toString() ?? 'one_time',
      dueDate: json['dueDate']?.toString(),
      category: json['category']?.toString(),
      status: json['status']?.toString() ?? 'active',
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class CustomersNotifier extends AsyncNotifier<List<Customer>> {
  @override
  List<Customer> build() {
    loadCustomers();
    return const [];
  }

  Future<void> loadCustomers({String search = ''}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get(
        '/customers',
        queryParameters: {
          'page': 1,
          'limit': 50,
          if (search.trim().isNotEmpty) 'search': search.trim(),
        },
      );
      final data = response.data;
      final items = data is Map ? (data['items'] as List? ?? []) : (data as List? ?? []);
      return items
          .whereType<Map>()
          .map((item) => Customer.fromJson(item))
          .toList();
    });
  }

  Future<Customer> createCustomer(Map<String, dynamic> input) async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.post('/customers', data: input);
    return Customer.fromJson(response.data as Map);
  }

  Future<Customer> getCustomer(String id) async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get('/customers/$id');
    return Customer.fromJson(response.data as Map);
  }

  Future<Customer> updateCustomer(String id, Map<String, dynamic> input) async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.patch('/customers/$id', data: input);
    return Customer.fromJson(response.data as Map);
  }

  Future<void> deleteCustomer(String id) async {
    final apiClient = ref.read(apiClientProvider);
    await apiClient.delete('/customers/$id');
  }

  Future<List<CustomerDebt>> getCustomerDebts(String id) async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get('/customers/$id/debts');
    final data = response.data;
    final items = data is Map ? (data['items'] as List? ?? []) : (data as List? ?? []);
    return items
        .whereType<Map>()
        .map((item) => CustomerDebt.fromJson(item))
        .toList();
  }

  Future<void> refresh({String search = ''}) async {
    await loadCustomers(search: search);
  }
}

final customersProvider =
    AsyncNotifierProvider<CustomersNotifier, List<Customer>>(CustomersNotifier.new);
