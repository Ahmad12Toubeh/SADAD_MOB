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

final guarantorsProvider = FutureProvider<List<Guarantor>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/guarantors');
  
  final items = (response.data['items'] as List<dynamic>?)
          ?.map((item) => Guarantor.fromJson(item as Map<String, dynamic>))
          .toList() ??
      [];
  
  return items;
});
