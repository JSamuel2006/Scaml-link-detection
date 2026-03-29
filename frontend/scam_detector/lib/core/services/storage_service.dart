import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> saveToken(String token) =>
      _storage.write(key: kTokenKey, value: token);

  static Future<String?> getToken() => _storage.read(key: kTokenKey);

  static Future<void> saveRole(String role) =>
      _storage.write(key: kRoleKey, value: role);

  static Future<String?> getRole() => _storage.read(key: kRoleKey);

  static Future<void> saveName(String name) =>
      _storage.write(key: kNameKey, value: name);

  static Future<String?> getName() => _storage.read(key: kNameKey);

  static Future<void> saveUserId(int id) =>
      _storage.write(key: kUserIdKey, value: id.toString());

  static Future<String?> getUserId() => _storage.read(key: kUserIdKey);

  static Future<void> savePermissionsGranted(bool granted) =>
      _storage.write(key: kPermissionsGrantedKey, value: granted.toString());

  static Future<bool> getPermissionsGranted() async {
    final val = await _storage.read(key: kPermissionsGrantedKey);
    return val == 'true';
  }

  static Future<void> clearAll() => _storage.deleteAll();
}
