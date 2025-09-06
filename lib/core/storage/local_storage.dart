import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Create a storage instance
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// Save a key-value pair
  static Future<void> writeData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Read data by key
  static Future<String?> readData(String key) async {
    return await _storage.read(key: key);
  }

  /// Delete data by key
  static Future<void> deleteData(String key) async {
    await _storage.delete(key: key);
  }

  /// Delete all stored values
  static Future<void> deleteAllData() async {
    await _storage.deleteAll();
  }
}
