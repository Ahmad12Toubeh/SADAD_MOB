import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  return const [];
}

class AssociationMember {
  final String id;
  final String? name;
  final String? phone;
  final bool isPaid;
  final bool isReceiver;
  final int turnOrder;

  const AssociationMember({
    required this.id,
    this.name,
    this.phone,
    required this.isPaid,
    required this.isReceiver,
    required this.turnOrder,
  });

  factory AssociationMember.fromJson(Map<String, dynamic> json) {
    return AssociationMember(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      isPaid: json['isPaid'] == true,
      isReceiver: json['isReceiver'] == true,
      turnOrder: (json['turnOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'isPaid': isPaid,
      'isReceiver': isReceiver,
      'turnOrder': turnOrder,
    };
  }
}

class AssociationFundTransaction {
  final String id;
  final String type;
  final double amount;
  final String? note;
  final String status;
  final String? memberId;
  final String? memberName;
  final String? approverId;
  final String? approverName;
  final String? createdAt;

  const AssociationFundTransaction({
    required this.id,
    required this.type,
    required this.amount,
    this.note,
    required this.status,
    this.memberId,
    this.memberName,
    this.approverId,
    this.approverName,
    this.createdAt,
  });

  factory AssociationFundTransaction.fromJson(Map<String, dynamic> json) {
    return AssociationFundTransaction(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'in',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      note: json['note']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      memberId: json['memberId']?.toString(),
      memberName: json['memberName']?.toString(),
      approverId: json['approverId']?.toString(),
      approverName: json['approverName']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class AssociationHistoryEntry {
  final String month;
  final String? receiverName;
  final int paidCount;
  final double totalCollected;

  const AssociationHistoryEntry({
    required this.month,
    this.receiverName,
    required this.paidCount,
    required this.totalCollected,
  });

  factory AssociationHistoryEntry.fromJson(Map<String, dynamic> json) {
    return AssociationHistoryEntry(
      month: json['month']?.toString() ?? '-',
      receiverName: json['receiverName']?.toString(),
      paidCount: (json['paidCount'] as num?)?.toInt() ?? 0,
      totalCollected: (json['totalCollected'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AssociationDetails {
  final Association association;
  final double fundBalance;
  final String? fundGuarantorMemberId;
  final List<AssociationFundTransaction> fundTransactions;
  final List<AssociationHistoryEntry> history;

  const AssociationDetails({
    required this.association,
    required this.fundBalance,
    this.fundGuarantorMemberId,
    required this.fundTransactions,
    required this.history,
  });
}

class Association {
  final String id;
  final String name;
  final double monthlyAmount;
  final String associationKind;
  final int members;
  final double totalValue;
  final List<AssociationMember> membersList;

  const Association({
    required this.id,
    required this.name,
    required this.monthlyAmount,
    required this.associationKind,
    required this.members,
    required this.totalValue,
    required this.membersList,
  });

  factory Association.fromJson(Map<String, dynamic> json) {
    final membersList = _asList(json['membersList'])
        .map((member) => AssociationMember.fromJson(_asMap(member)))
        .toList();

    return Association(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      monthlyAmount: (json['monthlyAmount'] as num?)?.toDouble() ?? 0.0,
      associationKind: json['associationKind']?.toString() ?? 'rotating',
      members: (json['members'] as num?)?.toInt() ?? membersList.length,
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0.0,
      membersList: membersList,
    );
  }
}

class AssociationsNotifier extends AsyncNotifier<List<Association>> {
  @override
  List<Association> build() {
    loadAssociations();
    return const [];
  }

  Future<void> loadAssociations() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.get('/associations');
      final data = response.data;
      final items = data is Map ? _asList(data['items']) : _asList(data);
      return items.map((item) => Association.fromJson(_asMap(item))).toList();
    });
  }

  Future<Association> createAssociation(Map<String, dynamic> input) async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.post('/associations', data: input);
    final data = _asMap(response.data);
    final association = data['association'] ?? data['item'] ?? data;
    return Association.fromJson(_asMap(association));
  }

  Future<AssociationDetails> getAssociation(String id) async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.get('/associations/$id');
    final data = _asMap(response.data);
    final associationRaw = _asMap(data['association'] ?? data['item'] ?? data);
    final association = Association.fromJson(associationRaw);
    final transactions = _asList(data['fundTransactions'] ?? data['transactions'])
        .map((item) => AssociationFundTransaction.fromJson(_asMap(item)))
        .toList();
    final history = _asList(data['history'] ?? data['historyEntries'])
        .map((item) => AssociationHistoryEntry.fromJson(_asMap(item)))
        .toList();
    final fundBalance = (data['fundBalance'] as num?)?.toDouble() ??
        (associationRaw['fundBalance'] as num?)?.toDouble() ??
        0.0;
    final fundGuarantorMemberId = data['fundGuarantorMemberId']?.toString() ??
        associationRaw['fundGuarantorMemberId']?.toString();
    return AssociationDetails(
      association: association,
      fundBalance: fundBalance,
      fundGuarantorMemberId: fundGuarantorMemberId,
      fundTransactions: transactions,
      history: history,
    );
  }

  Future<Association> updateAssociation(String id, Map<String, dynamic> input) async {
    final apiClient = ref.read(apiClientProvider);
    final response = await apiClient.patch('/associations/$id', data: input);
    final data = _asMap(response.data);
    final association = data['association'] ?? data['item'] ?? data;
    return Association.fromJson(_asMap(association));
  }

  Future<void> deleteAssociation(String id) async {
    final apiClient = ref.read(apiClientProvider);
    await apiClient.delete('/associations/$id');
  }

  Future<void> closeAssociationMonth(String id) async {
    final apiClient = ref.read(apiClientProvider);
    await apiClient.post('/associations/$id/close-month');
  }

  Future<void> reopenAssociationCycle(String id) async {
    final apiClient = ref.read(apiClientProvider);
    await apiClient.post('/associations/$id/reopen-cycle');
  }

  Future<void> addAssociationFundTransaction(String id, Map<String, dynamic> input) async {
    final apiClient = ref.read(apiClientProvider);
    await apiClient.post('/associations/$id/fund-transactions', data: input);
  }

  Future<void> approveAssociationFundTransaction(
    String id, {
    required String transactionId,
    required String memberId,
  }) async {
    final apiClient = ref.read(apiClientProvider);
    await apiClient.post(
      '/associations/$id/fund-transactions/$transactionId/approve',
      data: {'memberId': memberId},
    );
  }

  Future<void> refresh() async {
    await loadAssociations();
  }
}

final associationsProvider =
    AsyncNotifierProvider<AssociationsNotifier, List<Association>>(AssociationsNotifier.new);
