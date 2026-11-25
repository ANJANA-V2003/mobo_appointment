import 'package:flutter/widgets.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/active_appointment_card_model.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/appointment_status_counts_model.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/arrivin_soon_card_model.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/my_load_card_model.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/up_next_card_model.dart';
import 'package:mobo_appointment_project/features/dashboard/services/staff_dashboard_service.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class StaffDashboardProvider extends ChangeNotifier {
  final StaffDashboardService _staffDashboardService = StaffDashboardService();

  // Arriving Soon card
  ArrivingSoonCardModel _arrivingSoon = ArrivingSoonCardModel.empty();

  bool _isArrivingSoonLoading = false;
  String? _arrivingSoonError;

  ArrivingSoonCardModel get arrivingSoon => _arrivingSoon;

  bool get isArrivingSoonLoading => _isArrivingSoonLoading;

  String? get arrivingSoonError => _arrivingSoonError;

  // My Load card
  MyLoadCardModel _myLoad = MyLoadCardModel.empty();
  bool _isMyLoadLoading = false;
  String? _myLoadError;

  MyLoadCardModel get myLoad => _myLoad;
  bool get isMyLoadLoading => _isMyLoadLoading;
  String? get myLoadError => _myLoadError;

  // appointment count tab getters
  AppointmentStatusCountsModel _appointmentStatusCounts =
      AppointmentStatusCountsModel.empty();

  AppointmentStatusCountsModel get appointmentStatusCounts =>
      _appointmentStatusCounts;

  //active card getters

  List<ActiveAppointmentModel> _activeAppointments = [];

  List<ActiveAppointmentModel> get activeAppointments => _activeAppointments;

  Future<void> fetchArrivingSoon({
    required OdooClient client,
    required int userId,
    required bool isManager,
    required String timezone,
  }) async {
    _isArrivingSoonLoading = true;
    _arrivingSoonError = null;
    notifyListeners();

    try {
      _arrivingSoon = await _staffDashboardService.fetchArrivingSoon(
        client: client,
        userId: userId,
        isManager: isManager,
        timezone: timezone,
      );
    } catch (e) {
      _arrivingSoonError = e.toString();
      debugPrint('Arriving Soon Error: $e');
    } finally {
      _isArrivingSoonLoading = false;
      notifyListeners();
    }
  }

  // Up Next card
  UpNextCardModel _upNext = UpNextCardModel.empty();

  bool _isUpNextLoading = false;
  String? _upNextError;

  UpNextCardModel get upNext => _upNext;

  bool get isUpNextLoading => _isUpNextLoading;

  String? get upNextError => _upNextError;

  Future<void> fetchUpNext({
    required OdooClient client,
    required int userId,
    required bool isManager,
    required String timezone,
  }) async {
    _isUpNextLoading = true;
    _upNextError = null;
    notifyListeners();

    try {
      _upNext = await _staffDashboardService.fetchUpNext(
        client: client,
        userId: userId,
        isManager: isManager,
        timezone: timezone,
      );
    } catch (e) {
      _upNextError = e.toString();
      debugPrint('Up Next Error: $e');
    } finally {
      _isUpNextLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyLoad({
    required OdooClient client,
    required int userId,
    required String timezone,
  }) async {
    _isMyLoadLoading = true;
    _myLoadError = null;
    notifyListeners();

    try {
      _myLoad = await _staffDashboardService.fetchMyLoad(
        client: client,
        userId: userId,
        timezone: timezone,
      );

      // debugPrint(
      //   'MY LOAD: '
      //       'appointments=${_myLoad.appointmentCount}, '
      //       'booked=${_myLoad.bookedHours}, '
      //       'available=${_myLoad.availableHours}',
      // );
    } catch (e) {
      _myLoadError = e.toString();
      debugPrint('My Load Error: $e');
    } finally {
      _isMyLoadLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWorkingHours({
    required OdooClient client,
    required String timezone,
  }) async {
    try {
      final attendance = await _staffDashboardService.fetchWorkingHours(
        client: client,
        calendarId: 1,
      );

      final availableHours = _staffDashboardService
          .calculateTodayAvailableHours(
            attendance: attendance,
            timezone: timezone,
          );

      debugPrint('TODAY AVAILABLE HOURS: $availableHours');
    } catch (e) {
      debugPrint('WORKING HOURS ERROR: $e');
    }
  }

  Future<void> fetchAppointmentStatusCounts({
    required OdooClient client,
    required int userId,
  }) async {
    try {
      _appointmentStatusCounts = await _staffDashboardService
          .fetchAppointmentStatusCounts(client: client, userId: userId);

      debugPrint(
        'APPOINTMENT TAB COUNTS: '
        'active=${_appointmentStatusCounts.activeCount}, '
        'invitations=${_appointmentStatusCounts.invitationsCount}, '
        'completed=${_appointmentStatusCounts.completedCount}',
      );
    } catch (e) {
      debugPrint('Appointment Status Counts Error: $e');
    }

    notifyListeners();
  }

  Future<void> fetchActiveAppointments({
    required OdooClient client,
    required int userId,
  }) async {
    try {
      final result = await _staffDashboardService.fetchActiveAppointments(
        client: client,
        userId: userId,
      );

      debugPrint('ACTIVE APPOINTMENTS: $result');
    } catch (e) {
      debugPrint('ACTIVE APPOINTMENTS ERROR: $e');
    }
    notifyListeners();
  }
}
