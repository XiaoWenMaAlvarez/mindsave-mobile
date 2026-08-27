import 'package:mindsave/home/infrastructure/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageServiceImpl implements LocalStorageService {
  Future<SharedPreferences> getSharedPreferences() async {
    return SharedPreferences.getInstance();
  }

  @override
  Future<void> setKeyValue<T>(String key, T value) async {
    final SharedPreferences sharedPreferences = await getSharedPreferences();
    if (value is String) {
      await sharedPreferences.setString(key, value);
      return;
    }
    if (value is bool) {
      await sharedPreferences.setBool(key, value);
      return;
    }
    if (value is int) {
      await sharedPreferences.setInt(key, value);
      return;
    }
    if (value is double) {
      await sharedPreferences.setDouble(key, value);
      return;
    }
    throw UnimplementedError(
      "Método no implementado para. ${value.runtimeType}",
    );
  }

  @override
  Future<T?> getValue<T>(String key) async {
    final SharedPreferences sharedPreferences = await getSharedPreferences();
    if (T == String) {
      return sharedPreferences.getString(key) as T?;
    }
    if (T == bool) {
      return sharedPreferences.getBool(key) as T?;
    }
    if (T == int) {
      return sharedPreferences.getInt(key) as T?;
    }
    if (T == double) {
      return sharedPreferences.getDouble(key) as T?;
    }
    throw UnimplementedError("Método no implementado para. $T");
  }

  @override
  Future<bool> removeKey(String key) async {
    final SharedPreferences sharedPreferences = await getSharedPreferences();
    return await sharedPreferences.remove(key);
  }
}
