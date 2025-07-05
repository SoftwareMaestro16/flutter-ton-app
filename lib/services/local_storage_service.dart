import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _addressKey = 'wallet_address';

  static Future<void> saveAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_addressKey, address);
  }

  static Future<void> removeAddress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_addressKey);
  }

  static Future<String?> loadAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_addressKey);
  }
}