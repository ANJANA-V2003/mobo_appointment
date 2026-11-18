
import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../models/event_model.dart';
import '../services/appointment_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();

  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<EventModel> get events => _events;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> fetchTodayEvents({
    required OdooClient client,
    required int userId,
    required String timezone,
    required bool isManager,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _appointmentService.fetchTodayEvents(
        client: client,
        userId: userId,
        timezone: timezone,
        isManager: isManager,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAppointments({
    required OdooClient client,
    required int userId,
    required String timezone,
    required bool isManager,
  }) async {
    await fetchTodayEvents(
      client: client,
      userId: userId,
      timezone: timezone,
      isManager: isManager,
    );
  }

  void clearAppointments() {
    _events = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
