import 'package:flutter/widgets.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../models/profile_model.dart';

class ProfileService {
  Future<ProfileModel> fetchProfile({
    required OdooClient client,
    required int userId,
  }) async {
    final result = await client.callKw({
      'model': 'res.users',
      'method': 'read',
      'args': [
        [userId],
        ['name', 'email', 'phone', 'image_1920', 'address', 'website'],
      ],
      'kwargs': {},
    });

    if (result is! List || result.isEmpty) {
      throw Exception('Unable to fetch profile information');
    }
    final userData = Map<String, dynamic>.from(result.first as Map);
    debugPrint('User name: ${userData['name']}');
    debugPrint('Image value: ${userData['image_1920']}');
    debugPrint('Image type: ${userData['image_1920'].runtimeType}');

    return ProfileModel.fromJson(userData);
  }

  // function to update the profile
  Future<void> updateProfile({
    required OdooClient client,
    required int userId,
    required String name,
    required String email,
    required String phone,
    String? imageBase64,
  }) async {
    final values = <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
    };

    // Update the photo only if a new photo was selected
    if (imageBase64 != null) {
      values['image_1920'] = imageBase64;
    }

    final result = await client.callKw({
      'model': 'res.users',
      'method': 'write',
      'args': [
        [userId],
        values,
      ],
      'kwargs': {},
    });

    if (result != true) {
      throw Exception('unable to update profile information');
    }
  }
}
