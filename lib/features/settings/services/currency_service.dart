import 'package:odoo_rpc/odoo_rpc.dart';

import '../models/currency_model.dart';

class CurrencyService {
  Future<List<CurrencyModel>> fetchCurrencies(
      OdooClient client,
      ) async {
    final result = await client.callKw({
      'model': 'res.currency',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [
          ['active', '=', true],
        ],
        'fields': ['id', 'name', 'full_name', 'symbol',],
        'order': 'name asc',
      },
    });

    return (result as List)
        .map((currency) => CurrencyModel.fromJson(currency))
        .toList();
  }
}