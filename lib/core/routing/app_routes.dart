class AppRoutes {
  AppRoutes._();

  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';

  static const dashboard = '/dashboard';
  static const customers = '/customers';
  static const debts = '/debts';
  static const analytics = '/analytics';
  static const associations = '/associations';
  static const guarantors = '/guarantors';
  static const reminders = '/reminders';
  static const settings = '/settings';

  static const owner = '/owner';
  static const subscriptions = '/subscriptions';

  static String customerDetails(String id) => '/customers/$id';
  static String customerCreate() => '/customers/new';

  static String debtDetails(String id) => '/debts/$id';
  static String debtCreate() => '/debts/new';

  static String associationDetails(String id) => '/associations/$id';
  static String guarantorDetails(String id) => '/guarantors/$id';
}
