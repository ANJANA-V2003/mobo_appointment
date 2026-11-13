import 'package:odoo_rpc/odoo_rpc.dart';

class ModuleService {
  Future<bool> isAppointmentModuleInstalled(
      OdooClient client,
      ) async {
    final result = await client.callKw({
      'model': 'ir.module.module',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [
          ['name', '=', 'appointment'],
          ['state', '=', 'installed'],
        ],
        'fields': ['name', 'state'],
        'limit': 1,
      },
    });

    return result.isNotEmpty;
  }
}