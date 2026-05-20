import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class HiveStorage {
  late Box _box;

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> init() async {
    final encKey = await _resolveEncryptionKey();
    _box = await Hive.openBox(
      AppConstants.authBoxName,
      encryptionCipher: HiveAesCipher(encKey),
    );
  }

  // Encryption key: mavjud bo'lsa oladi, yo'q bo'lsa yaratadi
  Future<List<int>> _resolveEncryptionKey() async {
    final stored = await _secureStorage.read(key: AppConstants.hiveEncryptionKey);
    if (stored != null) {
      return base64Url.decode(stored);
    }
    final newKey = Hive.generateSecureKey();
    await _secureStorage.write(
      key: AppConstants.hiveEncryptionKey,
      value: base64UrlEncode(newKey),
    );
    return newKey;
  }

  // ─── Tokenlar ────────────────────────────────────────────────────────────────

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _box.put(AppConstants.accessTokenKey, accessToken);
    await _box.put(AppConstants.refreshTokenKey, refreshToken);
  }

  String? getAccessToken()  => _box.get(AppConstants.accessTokenKey)  as String?;
  String? getRefreshToken() => _box.get(AppConstants.refreshTokenKey) as String?;

  // ─── Foydalanuvchi ───────────────────────────────────────────────────────────

  Future<void> saveUser(Map<String, dynamic> user) =>
      _box.put(AppConstants.userKey, jsonEncode(user));

  Map<String, dynamic>? getUser() {
    final raw = _box.get(AppConstants.userKey) as String?;
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // ─── Til ─────────────────────────────────────────────────────────────────────

  Future<void> saveLanguage(String langCode) =>
      _box.put(AppConstants.langKey, langCode);

  String? getLanguage() => _box.get(AppConstants.langKey) as String?;

  // ─── Tozalash ────────────────────────────────────────────────────────────────

  Future<void> clearAuth() async {
    await _box.delete(AppConstants.accessTokenKey);
    await _box.delete(AppConstants.refreshTokenKey);
    await _box.delete(AppConstants.userKey);
  }

  Future<void> clearAll() => _box.clear();
}
