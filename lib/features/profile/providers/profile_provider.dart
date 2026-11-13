import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../models/profile_model.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  ProfileModel? _profile;

  bool _isLoading = false;
  String? _errorMessage;

  ProfileModel? get profile => _profile;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // did up-to here.

  // Fetch profile
  Future<void> fetchProfile({
    required OdooClient client,
    required int userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _profileService.fetchProfile(
        client: client,
        userId: userId,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}