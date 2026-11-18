import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../models/login_model.dart';
import '../services/auth_service.dart';
import '../services/module_service.dart';
import '../services/session_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SessionService _sessionService = SessionService();
  final ModuleService _moduleService = ModuleService();

  OdooClient? _client;
  OdooSession? _session;

  bool isLoading = false;
  bool isModuleInstalled = false;
  bool isCheckingModule = false;
  bool shouldOpenServerLogin = false;

  String? errorMessage;
  String? moduleError;

  bool get isLoggedIn => _session != null;

  OdooClient? get client => _client;

  OdooSession? get session => _session;

  // for the dashboard user details...
  int? get userId => _session?.userId;

  int? get partnerId => _session?.partnerId;

  String get userTimezone =>
      _session?.userTz ?? 'UTC';

  // LOGIN
  Future<bool> login({
    required String serverUrl,
    required String database,
    required LoginModel credentials,
  }) async {
    isLoading = true;
    errorMessage = null;
    moduleError = null;
    isModuleInstalled = false;
    notifyListeners();

    try {
      final result = await _authService.login(
        serverUrl: serverUrl,
        database: database,
        username: credentials.userName,
        password: credentials.password,
      );

      _client = result.client;
      _session = result.session;

      await _sessionService.saveSession(_session!);

      await _sessionService.saveServerDetails(
        serverUrl: serverUrl,
        database: database,
        username: credentials.userName,
      );

      await checkAppointmentModule();

      return true;
    } catch (e) {
      errorMessage = e.toString();

      _client?.close();
      _client = null;
      _session = null;

      await _sessionService.clearSession();

      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAppointmentModule() async {
    if (_client == null) return;

    isCheckingModule = true;
    isModuleInstalled = false;
    moduleError = null;
    notifyListeners();

    try {
      isModuleInstalled =
      await _moduleService.isAppointmentModuleInstalled(_client!);

      // Remember the module status.
      await _sessionService.saveModuleMissingStatus(
        !isModuleInstalled,
      );

      if (isModuleInstalled) {
        shouldOpenServerLogin = false;
      }
    } catch (e) {
      moduleError = e.toString();
    } finally {
      isCheckingModule = false;
      notifyListeners();
    }
  }
  Future<void> restoreSession() async {
    isLoading = true;
    errorMessage = null;
    moduleError = null;
    isModuleInstalled = false;
    shouldOpenServerLogin = false;

    notifyListeners();

    OdooClient? restoredClient;

    try {
      // First check whether module was previously missing.
      final wasMissing =
      await _sessionService.wasModuleMissing();

      if (wasMissing) {
        shouldOpenServerLogin = true;

        // Remove only authentication session.
        // Server URL and database remain saved.
        await _sessionService.clearAuthenticationSession();

        _client = null;
        _session = null;

        return;
      }

      final savedSession = await _sessionService.getSession();
      final serverDetails = await _sessionService.getServerDetails();

      if (savedSession == null || serverDetails == null) {
        return;
      }

      restoredClient = OdooClient(
        serverDetails['serverUrl']!,
        sessionId: savedSession,
      );

      // Verify saved session.
      await restoredClient.checkSession();

      _client = restoredClient;
      _session = savedSession;

      await checkAppointmentModule();

      // If the module is missing now, send user to server login.
      if (!isModuleInstalled) {
        shouldOpenServerLogin = true;

        await _sessionService.clearAuthenticationSession();

        _client?.close();
        _client = null;
        _session = null;
      }
    } catch (e) {
      restoredClient?.close();

      await _sessionService.clearAuthenticationSession();

      _client?.close();
      _client = null;
      _session = null;

      isModuleInstalled = false;
      moduleError = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  Future<void> logout() async {
    try {
      await _client?.destroySession();
    } catch (_) {}

    _client?.close();

    await _sessionService.clearAuthenticationSession();

    _client = null;
    _session = null;

    isModuleInstalled = false;
    isCheckingModule = false;

    errorMessage = null;
    moduleError = null;

    notifyListeners();
  }
}
