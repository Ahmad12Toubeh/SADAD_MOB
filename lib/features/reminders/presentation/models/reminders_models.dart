class ReminderItem {
  final String? id;
  final String? installmentId;
  final String? customerName;
  final String? customerEmail;
  final double amount;
  final String? dueDate;

  ReminderItem({
    this.id,
    this.installmentId,
    this.customerName,
    this.customerEmail,
    required this.amount,
    this.dueDate,
  });

  factory ReminderItem.fromJson(Map<String, dynamic> json) {
    return ReminderItem(
      id: json['id']?.toString(),
      installmentId: json['installmentId'] as String?,
      customerName: json['customerName'] as String?,
      customerEmail: json['customerEmail'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['dueDate'] as String?,
    );
  }
}

class SentReminder {
  final String id;
  final String? customer;
  final String? channel;
  final String? sentAt;

  SentReminder({
    required this.id,
    this.customer,
    this.channel,
    this.sentAt,
  });

  factory SentReminder.fromJson(Map<String, dynamic> json) {
    return SentReminder(
      id: json['id'] as String? ?? '',
      customer: json['customer'] as String?,
      channel: json['channel'] as String?,
      sentAt: json['sentAt'] as String?,
    );
  }
}

class RemindersData {
  final List<ReminderItem> overdue;
  final List<ReminderItem> upcoming;
  final List<SentReminder> sent;

  RemindersData({
    required this.overdue,
    required this.upcoming,
    required this.sent,
  });
}
