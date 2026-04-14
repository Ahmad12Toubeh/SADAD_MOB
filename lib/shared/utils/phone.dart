class PhoneUtils {
  PhoneUtils._();

  static String sanitizeJordan07Input(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    if (digits.startsWith('962')) {
      final local = digits.substring(3);
      return local.startsWith('0') ? local : '0$local';
    }
    return digits.startsWith('0') ? digits : '0$digits';
  }

  static bool isValidJordan07(String value) {
    return RegExp(r'^07\d{8}$').hasMatch(value);
  }
}
