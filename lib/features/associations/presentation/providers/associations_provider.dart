import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';

class AssociationMember {
  final String id;
  final String? name;
  final String? phone;
  final bool isPaid;
  final bool isReceiver;
  final int turnOrder;

  AssociationMember({
    required this.id,
    this.name,
    this.phone,
    required this.isPaid,
    required this.isReceiver,
    required this.turnOrder,
  });

  factory AssociationMember.fromJson(Map<String, dynamic> json) {
    return AssociationMember(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      isPaid: json['isPaid'] as bool? ?? false,
      isReceiver: json['isReceiver'] as bool? ?? false,
      turnOrder: json['turnOrder'] as int? ?? 0,
    );
  }
}

class Association {
  final String id;
  final String name;
  final double monthlyAmount;
  final String associationKind;
  final int members;
  final double totalValue;
  final List<AssociationMember> membersList;

  Association({
    required this.id,
    required this.name,
    required this.monthlyAmount,
    required this.associationKind,
    required this.members,
    required this.totalValue,
    required this.membersList,
  });

  factory Association.fromJson(Map<String, dynamic> json) {
    final membersList = (json['membersList'] as List<dynamic>?)
            ?.map((m) => AssociationMember.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [];

    return Association(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      monthlyAmount: (json['monthlyAmount'] as num?)?.toDouble() ?? 0.0,
      associationKind: json['associationKind'] as String? ?? 'rotating',
      members: json['members'] as int? ?? 0,
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0.0,
      membersList: membersList,
    );
  }
}

final associationsProvider = FutureProvider<List<Association>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/associations');
  
  final items = (response.data['items'] as List<dynamic>?)
          ?.map((item) => Association.fromJson(item as Map<String, dynamic>))
          .toList() ??
      [];
  
  return items;
});
