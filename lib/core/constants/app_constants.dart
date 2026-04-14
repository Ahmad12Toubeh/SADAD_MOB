class AppConstants {
  AppConstants._();

  static const String appName = 'SADAD';
  // Temporary until the API is deployed to your own server.
  static const String apiBaseUrl = 'https://sadad-api.onrender.com';
  static const String apiPathPrefix = '/api';
  static const String apiVersion = 'v1';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String localeKey = 'app_locale';
  static const String themeKey = 'app_theme';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
