class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'البريد الإلكتروني مطلوب';
    if (!value.contains('@') || !value.contains('.')) return 'بريد إلكتروني غير صالح';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'كلمة المرور مطلوبة';
    if (value.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    return null;
  }

  static String? required(String? value, [String field = 'هذا الحقل']) {
    if (value == null || value.trim().isEmpty) return '$field مطلوب';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'رقم الهاتف مطلوب';
    if (value.length < 8) return 'رقم هاتف غير صالح';
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.isEmpty) return 'المبلغ مطلوب';
    final num = double.tryParse(value);
    if (num == null || num <= 0) return 'مبلغ غير صالح';
    return null;
  }
}
