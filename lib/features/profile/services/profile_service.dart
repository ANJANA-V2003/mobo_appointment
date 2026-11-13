import 'package:odoo_rpc/odoo_rpc.dart';

import '../models/profile_model.dart';

class ProfileService {
  Future<ProfileModel> fetchProfile({
    required OdooClient client,
    required int userId,
  }) async {
    final result = await client.callKw({
      'model': 'red.users',
      'method': 'read',
      'args': [
        [userId],
        ['name', 'email', 'phone', 'image_1920'],
      ],
      'kwargs': {},
    });

    if (result is! List || result.isEmpty) {
      throw Exception('Unable to fetch profile information');
    }
    final userData = Map<String, dynamic>.from(result.first as Map);
    return ProfileModel.fromJson(userData);
  }
}
