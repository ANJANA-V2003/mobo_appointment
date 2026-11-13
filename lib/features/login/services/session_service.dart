import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class SessionService {
  final FlutterSecureStorage _secureStorage =
  const FlutterSecureStorage();

  static const String _sessionKey = 'odoo_session';

  static const String _serverUrlKey = 'server_url';
  static const String _databaseKey = 'database';
  static const String _usernameKey = 'username';

  static const String _moduleMissingKey = 'module_missing';

  Future<void> saveSession(OdooSession session) async {
    final sessionJson = jsonEncode(session.toJson());

    await _secureStorage.write(
      key: _sessionKey,
      value: sessionJson,
    );
  }

  Future<OdooSession?> getSession() async {
    final sessionJson = await _secureStorage.read(
      key: _sessionKey,
    );

    if (sessionJson == null) return null;

    final Map<String, dynamic> decoded = jsonDecode(sessionJson);

    return OdooSession.fromJson(decoded);
  }

  Future<void> saveServerDetails({
    required String serverUrl,
    required String database,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_serverUrlKey, serverUrl);
    await prefs.setString(_databaseKey, database);
    await prefs.setString(_usernameKey, username);
  }

  Future<Map<String, String>?> getServerDetails() async {
    final prefs = await SharedPreferences.getInstance();

    final serverUrl = prefs.getString(_serverUrlKey);
    final database = prefs.getString(_databaseKey);
    final username = prefs.getString(_usernameKey);

    if (serverUrl == null ||
        database == null ||
        username == null) {
      return null;
    }

    return {
      'serverUrl': serverUrl,
      'database': database,
      'username': username,
    };
  }

  Future<String?> getSavedServerUrl() async {
    final details = await getServerDetails();
    return details?['serverUrl'];
  }

  // Save module missing status
  Future<void> saveModuleMissingStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_moduleMissingKey, value);
  }

  // Check whether module was previously missing
  Future<bool> wasModuleMissing() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_moduleMissingKey) ?? false;
  }

  Future<void> clearAuthenticationSession() async {
    await _secureStorage.delete(key: _sessionKey);
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: _sessionKey);

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_serverUrlKey);
    await prefs.remove(_databaseKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_moduleMissingKey);
  }
}
