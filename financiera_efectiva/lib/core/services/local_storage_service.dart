class LocalStorageService {
  final Map<String, Object> _memory = {};

  Future<void> setBool(String key, bool value) async {
    _memory[key] = value;
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    return _memory[key] as bool? ?? defaultValue;
  }

  Future<void> setString(String key, String value) async {
    _memory[key] = value;
  }

  Future<String?> getString(String key) async {
    return _memory[key] as String?;
  }
}
