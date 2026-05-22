class AppConstants {
  AppConstants._();

  // --dart-define=API_URL=https://your-server.com/api orqali o'rnatiladi.
  // Agar berilmasa, lokal development IP ishlatiladi.
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://anthology-backend.onrender.com/api',
  );

  // Hive
  static const String authBoxName       = 'auth_box';
  static const String hiveEncryptionKey = 'hive_enc_key';

  // Storage keys
  static const String accessTokenKey  = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey         = 'user_data';
  static const String langKey         = 'selected_lang';

  // Network
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
