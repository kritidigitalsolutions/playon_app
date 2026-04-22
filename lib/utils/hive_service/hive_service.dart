import 'package:hive/hive.dart';
import 'package:play_on_app/utils/hive_service/userdetail.dart';

class HiveService {
  static const String boxName = 'userBox';
  static const String userKey = 'user';

  static Box<UserDetails> get _box => Hive.box<UserDetails>(boxName);

  static Future<void> saveUser(UserDetails user) async {
    await _box.put(userKey, user);
  }

  static UserDetails? getUser() {
    return _box.get(userKey);
  }

  static String? getToken() {
    return _box.get(userKey)?.token;
  }

  static Future<void> logout() async {
    await _box.clear();
  }

  static bool isLogin() {
    final user = getUser();
    return user != null && user.token != null && user.token!.isNotEmpty;
  }

  static bool isProfileComplete() {
    final user = getUser();
    return user != null && user.isNewUser == false;
  }
}
