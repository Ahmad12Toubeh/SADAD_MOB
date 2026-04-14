import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';

class Guarantor {
  final String id;
  final String name;
  final String? phone;
  final double totalDebt;
  final String debtStatus;
  final String? debtId;

  Guarantor({
    required this.id,
    required this.name,
    this.phone,
    required this.totalDebt,
    required this.debtStatus,
    this.debtId,
  });

  factory Guarantor.fromJson(Map<String, dynamic> json) {
    return Guarantor(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      totalDebt: (json['totalDebt'] as num?)?.toDouble() ?? 0.0,
      debtStatus: json['debtStatus'] as String? ?? 'active',
      debtId: json['debtId'] as String?,
    );
  }
}

class GuarantorsNotifier extends AsyncNotifier<List<Guarantor>> {
  @override
  List<Guarantor> build() {
    loadGuarantors();
    return const [];
  }

  Future<void> loadGuarantors() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get('/guarantors');
      final data = response.data;
      final items = data is Map ? (data['items'] as List<dynamic>? ?? const []) : (data as List<dynamic>? ?? const []);
      return items
          .whereType<Map>()
          .map((item) => Guarantor.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    });
  }

  Future<Guarantor> getGuarantor(String id) async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get('/guarantors/$id');
    final data = response.data;
    final raw = data is Map ? (data['guarantor'] ?? data['item'] ?? data) : data;
    return Guarantor.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<void> refresh() async {
    await loadGuarantors();
  }
}

final guarantorsProvider =
    AsyncNotifierProvider<GuarantorsNotifier, List<Guarantor>>(GuarantorsNotifier.new);
