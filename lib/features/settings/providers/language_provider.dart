
import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../models/language_model.dart';
import '../services/language_service.dart';

class LanguageProvider extends ChangeNotifier {
  final LanguageService _languageService = LanguageService();

  LanguageModel? _selectedLanguage;
  bool _isLoading = false;

  LanguageModel? get selectedLanguage => _selectedLanguage;
  bool get isLoading => _isLoading;

  Future<void> loadLanguage(
      OdooClient client,
      int userId,
      ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final language = await _languageService.fetchUserLanguage(
        client,
        userId,
      );

      _selectedLanguage = language;
    } catch (e) {
      debugPrint('Failed to load language: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
