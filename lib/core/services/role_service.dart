// import 'package:odoo_rpc/odoo_rpc.dart';
//
// class RoleService {
//   Future<bool> isManager(OdooClient client) async {
//     final result = await client.callKw({
//       'model': 'res.users',
//       'method': 'has_group', // checks whether the user is in the given security group
//       'args': [
//         [client.sessionId!.userId], // to identify logged in user record.
//         'appointment.group_appointment_manager'], // the XML ID of administrator
//       'kwargs': {},
//     });
//
//     return result == true;
//   }
//
//   Future<bool> isStaff(OdooClient client) async {
//     final result = await client.callKw({
//       'model': 'res.users',
//       'method': 'has_group',
//       'args': [
//         [client.sessionId!.userId],
//         'appointment.group_appointment_user'],  // the XML ID of user
//       'kwargs': {},
//     });
//
//     return result == true;
//   }
// }

import 'package:odoo_rpc/odoo_rpc.dart';

class RoleService {
  // Reusable method to check any Odoo group.
  Future<bool> hasGroup(OdooClient client, String groupXmlId) async {
    final userId = client.sessionId?.userId;

    if (userId == null) {
      throw Exception('User session not found');
    }

    final result = await client.callKw({
      'model': 'res.users',
      'method': 'has_group',
      'args': [
        [userId],
        groupXmlId,
      ],
      'kwargs': {},
    });

    return result == true;
  }

  // Check Manager access.
  Future<bool> isManager(OdooClient client) {
    return hasGroup(client, 'appointment.group_appointment_manager');
  }

  // Check Staff access.
  Future<bool> isStaff(OdooClient client) {
    return hasGroup(client,
        'appointment.group_appointment_user');
  }
}
