
import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/currency_model.dart';
import '../services/currency_service.dart';

class CurrencyProvider extends ChangeNotifier {
  final CurrencyService _currencyService = CurrencyService();

  List<CurrencyModel> _currencies = [];
  CurrencyModel? _selectedCurrency;
  bool _isLoading = false;

  List<CurrencyModel> get currencies => _currencies;
  CurrencyModel? get selectedCurrency => _selectedCurrency;
  bool get isLoading => _isLoading;

  Future<void> loadCurrencies(OdooClient client) async {
    _isLoading = true;
    notifyListeners();

    try {
      final currencies =
      await _currencyService.fetchCurrencies(client);

      _currencies = currencies;

      await _loadSelectedCurrency();
    } catch (e) {
      debugPrint('Failed to load currencies: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSelectedCurrency() async {
    final prefs = await SharedPreferences.getInstance();

    final savedCurrencyId =
    prefs.getInt('selected_currency_id');

    if (savedCurrencyId == null) return;

    final matchingCurrencies = _currencies.where(
          (currency) => currency.id == savedCurrencyId,
    );

    _selectedCurrency = matchingCurrencies.isNotEmpty
        ? matchingCurrencies.first
        : null;
  }

  Future<void> changeCurrency(CurrencyModel currency) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('selected_currency_id', currency.id);

    _selectedCurrency = currency;
    notifyListeners();
  }
}
