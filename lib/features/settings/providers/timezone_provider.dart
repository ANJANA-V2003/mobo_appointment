
import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../models/timezone_model.dart';
import '../services/timezone_service.dart';

class TimezoneProvider extends ChangeNotifier {
  final TimezoneService _timezoneService = TimezoneService();

  List<TimezoneModel> _timezones = [];
  TimezoneModel? _selectedTimezone;

  bool _isLoading = false;
  bool _isUpdating = false;

  List<TimezoneModel> get timezones => _timezones;
  TimezoneModel? get selectedTimezone => _selectedTimezone;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;

  // Find the timezone object from the current list.
  TimezoneModel? _findTimezone(String name) {
    for (final timezone in _timezones) {
      if (timezone.name == name) {
        return timezone;
      }
    }
    return null;
  }

  Future<void> loadTimezones(OdooClient client, int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch available timezones.
      final fetchedTimezones =
      await _timezoneService.fetchTimezones(client);

      // Remove duplicate timezone names.
      final uniqueTimezones = <String, TimezoneModel>{};

      for (final timezone in fetchedTimezones) {
        uniqueTimezones.putIfAbsent(
          timezone.name,
              () => timezone,
        );
      }

      _timezones = uniqueTimezones.values.toList();

      // Fetch the logged-in user's timezone.
      final timezoneName =
      await _timezoneService.fetchUserTimezone(client, userId);

      // Select the object from the current list.
      _selectedTimezone = _findTimezone(timezoneName!);
    } catch (e) {
      debugPrint('Failed to load timezones: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changeTimezone(
      OdooClient client,
      int userId,
      TimezoneModel timezone,
      ) async {
    _isUpdating = true;
    notifyListeners();

    try {
      final success =
      await _timezoneService.updateUserTimezone(
        client,
        userId,
        timezone.name,
      );

      if (success) {
        // Always use the object from the provider's current list.
        _selectedTimezone = _findTimezone(timezone.name);
      }

      return success;
    } catch (e) {
      debugPrint('Failed to update timezone: $e');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
}
