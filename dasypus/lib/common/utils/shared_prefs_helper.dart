import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  // ===========================
  // SALVAR VALORES
  // ===========================

  /// Salvar um valor int
  static Future<bool> saveInt(String key, int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setInt(key, value);
    } catch (e) {
      print('❌ Erro ao salvar int: $e');
      return false;
    }
  }

  /// Salvar um valor String
  static Future<bool> saveString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(key, value);
    } catch (e) {
      print('❌ Erro ao salvar string: $e');
      return false;
    }
  }

  /// Salvar um valor bool
  static Future<bool> saveBool(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(key, value);
    } catch (e) {
      print('❌ Erro ao salvar bool: $e');
      return false;
    }
  }

  // ===========================
  // RECUPERAR VALORES
  // ===========================

  /// Recuperar um valor int
  static Future<int?> getInt(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(key);
    } catch (e) {
      print('❌ Erro ao recuperar int: $e');
      return null;
    }
  }

  /// Recuperar um valor String
  static Future<String?> getString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      print('❌ Erro ao recuperar string: $e');
      return null;
    }
  }

  /// Recuperar um valor bool
  static Future<bool?> getBool(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key);
    } catch (e) {
      print('❌ Erro ao recuperar bool: $e');
      return null;
    }
  }

  // ===========================
  // MÉTODOS ESPECÍFICOS
  // ===========================

  /// Salvar ID do usuário
  static Future<bool> saveUserId(int userId) async {
    return await saveInt('user_id', userId);
  }
  static Future<bool> saveUserName(String userName) async {
    return await saveString('user_name', userName);
  }
  /// Salvar ID do usuário filho
  static Future<bool> saveUserFilhoId(int userId) async {
    return await saveInt('userFilho_id', userId);
  }
  static Future<bool> saveUserFotoUrl(String fotoUrl) async {
    return await saveString('user_foto_url', fotoUrl);
  }
  static Future<String?> getUserFotoUrl() async {
    return await getString('user_foto_url');
  }
  /// Recuperar ID do usuário
  static Future<int?> getUserId() async {
    return await getInt('user_id');
  }
  static Future<String?> getUserName() async {
    return await getString('user_name');
  }
 /// Recuperar ID do usuário filho
  static Future<int?> getUserFilhoId() async {
    return await getInt('userFilho_id');
  }
  /// Salvar contador (exemplo)
  static Future<bool> saveCounter(int counter) async {
    return await saveInt('counter', counter);
  }

  /// Recuperar contador (exemplo)
  static Future<int?> getCounter() async {
    return await getInt('counter');
  }
  /// Salvar id Categoria
  static Future<bool> saveCategoriaId(int categoriaId) async {  
    return await saveInt('categoria_id', categoriaId);
  }
  /// Recuperar id Categoria
  static Future<int?> getCategoriaId() async {
    return await getInt('categoria_id');
  }

  // ===========================
  // LIMPEZA
  // ===========================

  /// Remover uma chave específica
  static Future<bool> remove(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(key);
    } catch (e) {
      print('❌ Erro ao remover chave: $e');
      return false;
    }
  }

  /// Limpar todos os dados
  static Future<bool> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.clear();
    } catch (e) {
      print('❌ Erro ao limpar dados: $e');
      return false;
    }
  }

  /// Verificar se uma chave existe
  static Future<bool> containsKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(key);
    } catch (e) {
      print('❌ Erro ao verificar chave: $e');
      return false;
    }
  }
}
