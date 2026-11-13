import 'package:flutter/material.dart';

import '../models/database_model.dart';
import '../../../../core/models/server_config_model.dart';
import '../service/server_service.dart';

class ServerProvider extends ChangeNotifier {
  final ServerService _service = ServerService();

  String protocol = 'https://';
  String url = '';

  List<DatabaseModel> _databases = [];
  String? selectedDatabase;

  bool isLoading = false;
  String? errorMessage;

  List<DatabaseModel> get databases => _databases;

  ServerConfigModel get serverConfig {
    return ServerConfigModel(
      protocol: protocol,
      url: url,
      database: selectedDatabase,
    );
  }

  Future<void> fetchDatabases() async {
    if (url.trim().isEmpty) {
      errorMessage = 'Please enter a server URL';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    _databases = [];
    selectedDatabase = null;

    notifyListeners();

    try {
      final config = serverConfig;

      _databases = await _service.fetchDatabases(config.fullUrl);

      if (_databases.isNotEmpty) {
        selectedDatabase =_databases.first.name;
      }else {
        errorMessage = 'No databases found';
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateProtocol(String value) {
    protocol = value;
    _databases = [];
    selectedDatabase = null;
    errorMessage = null;

    notifyListeners();
  }

  void updateUrl(String value) {
    url = value;
    _databases = [];
    selectedDatabase = null;
    errorMessage = null;

    notifyListeners();
  }
  
  void updateDatabase(String? value) {
    selectedDatabase = value;
    notifyListeners();
  }


}
