import 'package:flutter/material.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/peak_hours_model.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../models/event_model.dart';

import '../services/appointment_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();

  // Today's appointments
  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Peak Hours
  List<PeakHoursModel> _peakHours = [];
  bool _isPeakHoursLoading = false;
  String? _peakHoursError;

  // Quick Navigation counts
  int _customerCount = 0;
  int _appointmentTypeCount = 0;

  bool _isQuickCountsLoading = false;
  String? _quickCountsError;

  // Getters
  List<EventModel> get events => _events;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<PeakHoursModel> get peakHours => _peakHours;

  bool get isPeakHoursLoading => _isPeakHoursLoading;

  String? get peakHoursError => _peakHoursError;

  int get customerCount => _customerCount;

  int get appointmentTypeCount => _appointmentTypeCount;

  bool get isQuickCountsLoading => _isQuickCountsLoading;

  String? get quickCountsError => _quickCountsError;


  Future<void> fetchQuickNavigationCounts({
    required OdooClient client,
  }) async {
    _isQuickCountsLoading = true;
    _quickCountsError = null;
    notifyListeners();

    try {
      _customerCount =
      await _appointmentService.fetchCustomerCount(client: client);

      _appointmentTypeCount =
      await _appointmentService.fetchAppointmentTypeCount(client: client);
    } catch (e) {
      _quickCountsError = e.toString();
      debugPrint('Quick Navigation Counts Error: $e');
    } finally {
      _isQuickCountsLoading = false;
      notifyListeners();
    }
  }


  // Fetch today's appointments
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

  // Fetch Peak Hours
  Future<void> fetchPeakHours({
    required OdooClient client,
    required int userId,
    required String timezone,
    required bool isManager,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _isPeakHoursLoading = true;
    _peakHoursError = null;
    notifyListeners();

    try {
      _peakHours = await _appointmentService.fetchPeakHours(
        client: client,
        userId: userId,
        timezone: timezone,
        isManager: isManager,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _peakHoursError = e.toString();
      debugPrint('Fetch Peak Hours Error: $e');
    } finally {
      _isPeakHoursLoading = false;
      notifyListeners();
    }
  }

  // Refresh today's appointments
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

  // Clear Peak Hours data
  void clearPeakHours() {
    _peakHours = [];
    _peakHoursError = null;
    _isPeakHoursLoading = false;
    notifyListeners();
  }

  // Clear appointment data
  void clearAppointments() {
    _events = [];
    _errorMessage = null;
    _isLoading = false;

    _peakHours = [];
    _peakHoursError = null;
    _isPeakHoursLoading = false;

    notifyListeners();
  }
}

