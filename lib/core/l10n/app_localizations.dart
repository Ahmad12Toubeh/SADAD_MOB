import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [Locale('ar'), Locale('en')];

  String get _lang => locale.languageCode;

  // ── App ──
  String get appName => _t('app.name');

  // ── Auth Login ──
  String get loginTitle => _t('auth.login.title');
  String get loginSubtitle => _t('auth.login.subtitle');
  String get emailLabel => _t('auth.login.emailLabel');
  String get emailPlaceholder => _t('auth.login.emailPlaceholder');
  String get passwordLabel => _t('auth.login.passwordLabel');
  String get passwordPlaceholder => _t('auth.login.passwordPlaceholder');
  String get forgotPassword => _t('auth.login.forgotPassword');
  String get loginSubmit => _t('auth.login.submit');
  String get loginLoading => _t('auth.login.loading');
  String get noAccount => _t('auth.login.noAccount');
  String get createAccount => _t('auth.login.createAccount');

  // ── Auth Register ──
  String get registerTitle => _t('auth.register.title');
  String get registerSubtitle => _t('auth.register.subtitle');
  String get nameLabel => _t('auth.register.nameLabel');
  String get storeNameLabel => _t('auth.register.storeNameLabel');
  String get registerSubmit => _t('auth.register.submit');
  String get hasAccount => _t('auth.register.hasAccount');
  String get loginLink => _t('auth.register.login');

  // ── Auth Forgot Password ──
  String get forgotTitle => _t('auth.forgot.title');
  String get forgotSubtitle => _t('auth.forgot.subtitle');
  String get forgotSubmit => _t('auth.forgot.submit');
  String get forgotSuccess => _t('auth.forgot.success');
  String get forgotCheckEmail => _t('auth.forgot.checkEmail');
  String get backToLogin => _t('auth.forgot.backToLogin');

  // ── Dashboard ──
  String get dashboardTitle => _t('dashboard.title');
  String get dashboardSubtitle => _t('dashboard.subtitle');
  String get totalActiveDebt => _t('dashboard.totalActiveDebt');
  String get collectedThisMonth => _t('dashboard.collectedThisMonth');
  String get overdueDebt => _t('dashboard.overdueDebt');
  String get activeCustomers => _t('dashboard.activeCustomers');
  String get recentActivity => _t('dashboard.recentActivity');
  String get viewAll => _t('common.viewAll');

  // ── Customers ──
  String get customersTitle => _t('customers.title');
  String get addCustomer => _t('customers.add');
  String get searchCustomer => _t('customers.search');
  String get noCustomers => _t('customers.empty');
  String get addNewCustomer => _t('customers.addNew');
  String get phoneLabel => _t('customers.phone');
  String get notesLabel => _t('customers.notes');
  String get activeDebts => _t('customers.activeDebts');

  // ── Debts ──
  String get debtsTitle => _t('debts.title');
  String get addDebt => _t('debts.add');
  String get noDebts => _t('debts.empty');
  String get filterAll => _t('debts.filter.all');
  String get filterActive => _t('debts.filter.active');
  String get filterPaid => _t('debts.filter.paid');
  String get filterLate => _t('debts.filter.late');
  String get amount => _t('debts.amount');
  String get type => _t('debts.type');
  String get dueDate => _t('debts.dueDate');
  String get status => _t('common.status');

  // ── Status ──
  String get statusPaid => _t('status.paid');
  String get statusLate => _t('status.late');
  String get statusActive => _t('status.active');

  // ── Types ──
  String get typeInvoice => _t('type.invoice');
  String get typeLoan => _t('type.loan');
  String get typeOther => _t('type.other');

  // ── Analytics ──
  String get analyticsTitle => _t('analytics.title');
  String get analyticsSubtitle => _t('analytics.subtitle');
  String get totalDebt => _t('analytics.totalDebt');
  String get totalCollected => _t('analytics.totalCollected');
  String get remaining => _t('analytics.remaining');
  String get collectionRate => _t('analytics.collectionRate');
  String get monthlyAnalysis => _t('analytics.monthly');
  String get noMonthlyData => _t('analytics.noMonthlyData');

  // ── Settings ──
  String get settingsTitle => _t('settings.title');
  String get storeSettings => _t('settings.store');
  String get storeName => _t('settings.storeName');
  String get currency => _t('settings.currency');
  String get saveChanges => _t('settings.save');
  String get appSettings => _t('settings.app');
  String get darkMode => _t('settings.darkMode');
  String get darkModeSubtitle => _t('settings.darkModeSubtitle');
  String get language => _t('settings.language');
  String get notifications => _t('settings.notifications');
  String get notificationsSubtitle => _t('settings.notificationsSubtitle');
  String get account => _t('settings.account');
  String get profile => _t('settings.profile');
  String get changePassword => _t('settings.changePassword');
  String get logout => _t('settings.logout');
  String get logoutConfirm => _t('settings.logoutConfirm');

  // ── Common ──
  String get cancel => _t('common.cancel');
  String get add => _t('common.add');
  String get close => _t('common.close');
  String get delete => _t('common.delete');
  String get edit => _t('common.edit');
  String get save => _t('common.save');
  String get noResults => _t('common.noResults');
  String get retry => _t('common.retry');
  String get error => _t('common.error');
  String get sar => _t('common.sar');

  // ── Validation ──
  String get emailRequired => _t('validation.emailRequired');
  String get emailInvalid => _t('validation.emailInvalid');
  String get passwordRequired => _t('validation.passwordRequired');
  String get passwordTooShort => _t('validation.passwordTooShort');
  String get fieldRequired => _t('validation.fieldRequired');
  String get phoneRequired => _t('validation.phoneRequired');
  String get phoneInvalid => _t('validation.phoneInvalid');

  // ── Months ──
  String monthName(int m) => _t('months.$m');

  String _t(String key) {
    return _strings[_lang]?[key] ?? _strings['ar']?[key] ?? key;
  }

  static const _strings = <String, Map<String, String>>{
    'ar': {
      'app.name': 'SADAD',
      'auth.login.title': 'تسجيل الدخول',
      'auth.login.subtitle': 'أدخل بياناتك للوصول إلى حسابك',
      'auth.login.emailLabel': 'البريد الإلكتروني',
      'auth.login.emailPlaceholder': 'example@email.com',
      'auth.login.passwordLabel': 'كلمة المرور',
      'auth.login.passwordPlaceholder': 'أدخل كلمة المرور',
      'auth.login.forgotPassword': 'نسيت كلمة المرور؟',
      'auth.login.submit': 'تسجيل الدخول',
      'auth.login.loading': 'جاري تسجيل الدخول...',
      'auth.login.noAccount': 'ما عندك حساب؟',
      'auth.login.createAccount': 'إنشاء حساب',
      'auth.register.title': 'إنشاء حساب جديد',
      'auth.register.subtitle': 'أنشئ حسابك لبدء إدارة الديون',
      'auth.register.nameLabel': 'الاسم الكامل',
      'auth.register.storeNameLabel': 'اسم المتجر',
      'auth.register.submit': 'إنشاء حساب',
      'auth.register.hasAccount': 'عندك حساب؟',
      'auth.register.login': 'تسجيل الدخول',
      'auth.forgot.title': 'نسيت كلمة المرور؟',
      'auth.forgot.subtitle': 'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين',
      'auth.forgot.submit': 'إرسال رابط إعادة التعيين',
      'auth.forgot.success': 'تم إرسال رابط إعادة التعيين',
      'auth.forgot.checkEmail': 'تحقق من بريدك الإلكتروني لإعادة تعيين كلمة المرور',
      'auth.forgot.backToLogin': 'العودة لتسجيل الدخول',
      'dashboard.title': 'لوحة التحكم',
      'dashboard.subtitle': 'نظرة عامة على الديون والمدفوعات',
      'dashboard.totalActiveDebt': 'إجمالي الديون النشطة',
      'dashboard.collectedThisMonth': 'المحصّل هذا الشهر',
      'dashboard.overdueDebt': 'الديون المتأخرة',
      'dashboard.activeCustomers': 'العملاء النشطين',
      'dashboard.recentActivity': 'النشاط الأخير',
      'customers.title': 'العملاء',
      'customers.add': 'إضافة عميل',
      'customers.search': 'بحث عن عميل...',
      'customers.empty': 'لا يوجد عملاء بعد',
      'customers.addNew': 'إضافة عميل جديد',
      'customers.phone': 'رقم الهاتف',
      'customers.notes': 'ملاحظات',
      'customers.activeDebts': 'ديون نشطة',
      'debts.title': 'الديون',
      'debts.add': 'إضافة دين',
      'debts.empty': 'لا توجد ديون',
      'debts.filter.all': 'الكل',
      'debts.filter.active': 'نشطة',
      'debts.filter.paid': 'مدفوعة',
      'debts.filter.late': 'متأخرة',
      'debts.amount': 'المبلغ',
      'debts.type': 'النوع',
      'debts.dueDate': 'تاريخ الاستحقاق',
      'status.paid': 'مدفوع',
      'status.late': 'متأخر',
      'status.active': 'نشط',
      'type.invoice': 'فاتورة',
      'type.loan': 'قرض',
      'type.other': 'أخرى',
      'analytics.title': 'التحليلات',
      'analytics.subtitle': 'إحصائيات وتقارير الديون',
      'analytics.totalDebt': 'إجمالي الديون',
      'analytics.totalCollected': 'المحصّل',
      'analytics.remaining': 'المتبقي',
      'analytics.collectionRate': 'نسبة التحصيل',
      'analytics.monthly': 'التحليل الشهري',
      'analytics.noMonthlyData': 'لا توجد بيانات شهرية',
      'settings.title': 'الإعدادات',
      'settings.store': 'إعدادات المتجر',
      'settings.storeName': 'اسم المتجر',
      'settings.currency': 'العملة',
      'settings.save': 'حفظ التغييرات',
      'settings.app': 'إعدادات التطبيق',
      'settings.darkMode': 'الوضع الداكن',
      'settings.darkModeSubtitle': 'تفعيل المظهر الداكن',
      'settings.language': 'اللغة',
      'settings.notifications': 'الإشعارات',
      'settings.notificationsSubtitle': 'تفعيل إشعارات التذكير',
      'settings.account': 'الحساب',
      'settings.profile': 'الملف الشخصي',
      'settings.changePassword': 'تغيير كلمة المرور',
      'settings.logout': 'تسجيل الخروج',
      'settings.logoutConfirm': 'هل أنت متأكد من تسجيل الخروج؟',
      'common.cancel': 'إلغاء',
      'common.add': 'إضافة',
      'common.close': 'إغلاق',
      'common.delete': 'حذف',
      'common.edit': 'تعديل',
      'common.save': 'حفظ',
      'common.viewAll': 'عرض الكل',
      'common.noResults': 'لا توجد نتائج',
      'common.retry': 'إعادة المحاولة',
      'common.error': 'حدث خطأ',
      'common.status': 'الحالة',
      'common.sar': 'ر.س',
      'validation.emailRequired': 'البريد الإلكتروني مطلوب',
      'validation.emailInvalid': 'بريد إلكتروني غير صالح',
      'validation.passwordRequired': 'كلمة المرور مطلوبة',
      'validation.passwordTooShort': 'كلمة المرور قصيرة جداً',
      'validation.fieldRequired': 'هذا الحقل مطلوب',
      'validation.phoneRequired': 'رقم الهاتف مطلوب',
      'validation.phoneInvalid': 'رقم هاتف غير صالح',
      'months.1': 'يناير', 'months.2': 'فبراير', 'months.3': 'مارس',
      'months.4': 'أبريل', 'months.5': 'مايو', 'months.6': 'يونيو',
      'months.7': 'يوليو', 'months.8': 'أغسطس', 'months.9': 'سبتمبر',
      'months.10': 'أكتوبر', 'months.11': 'نوفمبر', 'months.12': 'ديسمبر',
    },
    'en': {
      'app.name': 'SADAD',
      'auth.login.title': 'Login',
      'auth.login.subtitle': 'Enter your credentials to access your account',
      'auth.login.emailLabel': 'Email',
      'auth.login.emailPlaceholder': 'example@email.com',
      'auth.login.passwordLabel': 'Password',
      'auth.login.passwordPlaceholder': 'Enter your password',
      'auth.login.forgotPassword': 'Forgot password?',
      'auth.login.submit': 'Login',
      'auth.login.loading': 'Logging in...',
      'auth.login.noAccount': "Don't have an account?",
      'auth.login.createAccount': 'Create account',
      'auth.register.title': 'Create Account',
      'auth.register.subtitle': 'Create your account to start managing debts',
      'auth.register.nameLabel': 'Full Name',
      'auth.register.storeNameLabel': 'Store Name',
      'auth.register.submit': 'Create Account',
      'auth.register.hasAccount': 'Already have an account?',
      'auth.register.login': 'Login',
      'auth.forgot.title': 'Forgot Password?',
      'auth.forgot.subtitle': 'Enter your email and we\'ll send you a reset link',
      'auth.forgot.submit': 'Send Reset Link',
      'auth.forgot.success': 'Reset Link Sent',
      'auth.forgot.checkEmail': 'Check your email to reset your password',
      'auth.forgot.backToLogin': 'Back to Login',
      'dashboard.title': 'Dashboard',
      'dashboard.subtitle': 'Overview of debts and payments',
      'dashboard.totalActiveDebt': 'Total Active Debt',
      'dashboard.collectedThisMonth': 'Collected This Month',
      'dashboard.overdueDebt': 'Overdue Debt',
      'dashboard.activeCustomers': 'Active Customers',
      'dashboard.recentActivity': 'Recent Activity',
      'customers.title': 'Customers',
      'customers.add': 'Add Customer',
      'customers.search': 'Search customers...',
      'customers.empty': 'No customers yet',
      'customers.addNew': 'Add New Customer',
      'customers.phone': 'Phone',
      'customers.notes': 'Notes',
      'customers.activeDebts': 'active debts',
      'debts.title': 'Debts',
      'debts.add': 'Add Debt',
      'debts.empty': 'No debts found',
      'debts.filter.all': 'All',
      'debts.filter.active': 'Active',
      'debts.filter.paid': 'Paid',
      'debts.filter.late': 'Late',
      'debts.amount': 'Amount',
      'debts.type': 'Type',
      'debts.dueDate': 'Due Date',
      'status.paid': 'Paid',
      'status.late': 'Late',
      'status.active': 'Active',
      'type.invoice': 'Invoice',
      'type.loan': 'Loan',
      'type.other': 'Other',
      'analytics.title': 'Analytics',
      'analytics.subtitle': 'Debt statistics and reports',
      'analytics.totalDebt': 'Total Debt',
      'analytics.totalCollected': 'Collected',
      'analytics.remaining': 'Remaining',
      'analytics.collectionRate': 'Collection Rate',
      'analytics.monthly': 'Monthly Analysis',
      'analytics.noMonthlyData': 'No monthly data',
      'settings.title': 'Settings',
      'settings.store': 'Store Settings',
      'settings.storeName': 'Store Name',
      'settings.currency': 'Currency',
      'settings.save': 'Save Changes',
      'settings.app': 'App Settings',
      'settings.darkMode': 'Dark Mode',
      'settings.darkModeSubtitle': 'Enable dark theme',
      'settings.language': 'Language',
      'settings.notifications': 'Notifications',
      'settings.notificationsSubtitle': 'Enable reminder notifications',
      'settings.account': 'Account',
      'settings.profile': 'Profile',
      'settings.changePassword': 'Change Password',
      'settings.logout': 'Logout',
      'settings.logoutConfirm': 'Are you sure you want to logout?',
      'common.cancel': 'Cancel',
      'common.add': 'Add',
      'common.close': 'Close',
      'common.delete': 'Delete',
      'common.edit': 'Edit',
      'common.save': 'Save',
      'common.viewAll': 'View All',
      'common.noResults': 'No results',
      'common.retry': 'Retry',
      'common.error': 'An error occurred',
      'common.status': 'Status',
      'common.sar': 'SAR',
      'validation.emailRequired': 'Email is required',
      'validation.emailInvalid': 'Invalid email address',
      'validation.passwordRequired': 'Password is required',
      'validation.passwordTooShort': 'Password is too short',
      'validation.fieldRequired': 'This field is required',
      'validation.phoneRequired': 'Phone number is required',
      'validation.phoneInvalid': 'Invalid phone number',
      'months.1': 'January', 'months.2': 'February', 'months.3': 'March',
      'months.4': 'April', 'months.5': 'May', 'months.6': 'June',
      'months.7': 'July', 'months.8': 'August', 'months.9': 'September',
      'months.10': 'October', 'months.11': 'November', 'months.12': 'December',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
