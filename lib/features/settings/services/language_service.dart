import 'package:odoo_rpc/odoo_rpc.dart';

import '../models/language_model.dart';

class LanguageService {
  Future<LanguageModel?> fetchUserLanguage(
      OdooClient client,
      int userId,
      ) async {
    final result = await client.callKw({
      'model': 'res.users',
      'method': 'read',
      'args': [
        [userId],
      ],
      'kwargs': {
        'fields': ['lang'],
      },
    });

    if (result.isEmpty) return null;

    final languageCode = result[0]['lang'] as String?;

    if (languageCode == null) return null;

    // Odoo stores the language code, for example en_US.
    // The app currently supports only English (US).
    return LanguageModel(
      code: languageCode,
      name: languageCode == 'en_US' ? 'English (US)' : 'English (US)',
    );
  }
}