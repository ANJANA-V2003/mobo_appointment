import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../models/profile_model.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  ProfileModel? _profile;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  ProfileModel? get profile => _profile;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get hasProfile => profile != null;

  String? get errorMessage => _errorMessage;

  // Fetch profile
  Future<void> fetchProfile({
    required OdooClient client,
    required int userId,
  }) async {
    if (hasProfile) return;
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

  // Update profile
  Future<bool> updateProfile({
    required OdooClient client,
    required int userId,
    required String name,
    required String email,
    required String phone,
    String? imageBase64,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Send updated information to Odoo
      await _profileService.updateProfile(
        client: client,
        userId: userId,
        name: name,
        email: email,
        phone: phone,
        imageBase64: imageBase64,
      );

      // Fetch the latest profile information
      _profile = await _profileService.fetchProfile(
        client: client,
        userId: userId,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearProfile() {
    _profile = null;
    _errorMessage = null;
    _isLoading = false;
    _isSaving = false;
    notifyListeners();
  }
}
