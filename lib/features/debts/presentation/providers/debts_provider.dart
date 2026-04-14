import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';

class Debt {
  final String id;
  final String customerId;
  final String customerName;
  final String type;
  final num principalAmount;
  final String currency;
  final String planType;
  final String? dueDate;
  final String? category;
  final String? notes;
  final String status;
  final bool hasGuarantor;
  final bool? guarantorActive;
  final String? createdAt;
  final String? updatedAt;

  const Debt({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.type,
    required this.principalAmount,
    required this.currency,
    required this.planType,
    this.dueDate,
    this.category,
    this.notes,
    required this.status,
    required this.hasGuarantor,
    this.guarantorActive,
    this.createdAt,
    this.updatedAt,
  });

  factory Debt.fromJson(Map<dynamic, dynamic> json) {
    return Debt(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      type: json['type']?.toString() ?? 'other',
      principalAmount: json['principalAmount'] is num ? json['principalAmount'] as num : 0,
      currency: json['currency']?.toString() ?? 'JOD',
      planType: json['planType']?.toString() ?? 'one_time',
      dueDate: json['dueDate']?.toString(),
      category: json['category']?.toString(),
      notes: json['notes']?.toString(),
      status: json['status']?.toString() ?? 'active',
      hasGuarantor: json['hasGuarantor'] == true,
      guarantorActive: json['guarantorActive'] as bool?,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}

class DebtInstallment {
  final String id;
  final String debtId;
  final num amount;
  final String dueDate;
  final String status;
  final String? paidAt;
  final bool isInitialPayment;

  const DebtInstallment({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.paidAt,
    required this.isInitialPayment,
  });

  factory DebtInstallment.fromJson(Map<dynamic, dynamic> json) {
    return DebtInstallment(
      id: json['id']?.toString() ?? '',
      debtId: json['debtId']?.toString() ?? '',
      amount: json['amount'] is num ? json['amount'] as num : 0,
      dueDate: json['dueDate']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      paidAt: json['paidAt']?.toString(),
      isInitialPayment: json['isInitialPayment'] == true,
    );
  }
}

class DebtGuarantor {
  final String? name;
  final String? phone;
  final String? notes;
  final String? proofImageUrl;
  final String? proofImagePublicId;
  final bool? statusActive;

  const DebtGuarantor({
    this.name,
    this.phone,
    this.notes,
    this.proofImageUrl,
    this.proofImagePublicId,
    this.statusActive,
  });

  factory DebtGuarantor.fromJson(Map<dynamic, dynamic> json) {
    return DebtGuarantor(
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      notes: json['notes']?.toString(),
      proofImageUrl: json['proofImageUrl']?.toString(),
      proofImagePublicId: json['proofImagePublicId']?.toString(),
      statusActive: json['status'] == 'active' || json['active'] == true,
    );
  }
}

class DebtDetails {
  final Debt debt;
  final List<DebtInstallment> installments;
  final DebtGuarantor? guarantor;

  const DebtDetails({
    required this.debt,
    required this.installments,
    this.guarantor,
  });
}

class DebtsNotifier extends AsyncNotifier<List<Debt>> {
  @override
  List<Debt> build() {
    loadDebts();
    return const [];
  }

  Future<void> loadDebts() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get('/debts');
      final data = response.data;
      final items = data is Map ? (data['items'] as List? ?? []) : (data as List? ?? []);
      return items
          .whereType<Map>()
          .map((item) => Debt.fromJson(item))
          .toList();
    });
  }

  Future<DebtDetails> getDebt(String id) async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get('/debts/$id');
    final data = response.data as Map;
    final debt = Debt.fromJson(data['debt'] as Map);
    final installments = (data['installments'] as List? ?? [])
        .whereType<Map>()
        .map((item) => DebtInstallment.fromJson(item))
        .toList();
    final guarantorRaw = data['guarantor'];
    return DebtDetails(
      debt: debt,
      installments: installments,
      guarantor: guarantorRaw is Map ? DebtGuarantor.fromJson(guarantorRaw) : null,
    );
  }

  Future<Debt> createDebt(Map<String, dynamic> input) async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.post('/debts', data: input);
    final data = response.data as Map;
    return Debt.fromJson(data['debt'] as Map);
  }

  Future<Debt> updateDebt(String id, Map<String, dynamic> input) async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.patch('/debts/$id', data: input);
    return Debt.fromJson(response.data as Map);
  }

  Future<void> deleteDebt(String id) async {
    final apiClient = ref.read(apiClientProvider);
    await apiClient.delete('/debts/$id');
  }

  Future<void> payInstallment(String installmentId, Map<String, dynamic> input) async {
    final apiClient = ref.read(apiClientProvider);
    await apiClient.post('/installments/$installmentId/payments', data: input);
  }

  Future<void> activateGuarantor(String debtId) async {
    final apiClient = ref.read(apiClientProvider);
    await apiClient.post('/debts/$debtId/guarantor/activate');
  }

  Future<void> refresh() async {
    await loadDebts();
  }
}

final debtsProvider =
    AsyncNotifierProvider<DebtsNotifier, List<Debt>>(DebtsNotifier.new);
