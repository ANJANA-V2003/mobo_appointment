import 'package:odoo_rpc/odoo_rpc.dart';

import '../models/timezone_model.dart';

class TimezoneService {
  Future<List<TimezoneModel>> fetchTimezones(OdooClient client) async {
    final result = await client.callKw({
      'model': 'res.users',
      'method': 'fields_get',
      'args': [],
      'kwargs': {
        'allfields': ['tz'],
        'attributes': ['selection'],
      },
    });

    final selection = result['tz']['selection'] as List;

    return selection
        .map((timezone) => TimezoneModel.fromJson(timezone))
        .toList();
  }

  Future<String?> fetchUserTimezone(OdooClient client, int userId) async {
    final result = await client.callKw({
      'model': 'res.users',
      'method': 'read',
      'args': [
        [userId],
      ],
      'kwargs': {
        'fields': ['tz'],
      },
    });

    if (result.isEmpty) return null;

    return result[0]['tz'] as String?;
  }

  Future<bool> updateUserTimezone(
    OdooClient client,
    int userId,
    String timezone,
  ) async {
    final result = await client.callKw({
      'model': 'res.users',
      'method': 'write',
      'args': [
        [userId],
        {'tz': timezone},
      ],
      'kwargs': {},
    });

    return result == true;
  }


}
