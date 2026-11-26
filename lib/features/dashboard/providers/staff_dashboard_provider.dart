import 'package:flutter/widgets.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/active_appointment_card_model.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/appointment_status_counts_model.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/arrivin_soon_card_model.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/my_load_card_model.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/staff_calendar/invitation_request_model.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/up_next_card_model.dart';
import 'package:mobo_appointment_project/features/dashboard/services/staff_services/active_appointment_service.dart';
import 'package:mobo_appointment_project/features/dashboard/services/staff_services/completed_appointment_service.dart';
import 'package:mobo_appointment_project/features/dashboard/services/staff_services/invitations_appointment_service.dart';
import 'package:mobo_appointment_project/features/dashboard/services/staff_services/staff_dashboard_service.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class StaffDashboardProvider extends ChangeNotifier {
  final StaffDashboardService _staffDashboardService = StaffDashboardService();
  final ActiveAppointmentService _activeAppointmentService =
      ActiveAppointmentService();
  final InvitationsAppointmentService _invitationsAppointmentService =
      InvitationsAppointmentService();

  final CompletedAppointmentService _completedAppointmentService =
      CompletedAppointmentService();

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

  // invitation request cards getters

  List<InvitationRequestModel> _invitationRequests = [];

  bool _isLoadingInvitations = false;
  String? _invitationError;

  List<InvitationRequestModel> get invitationRequests => _invitationRequests;

  bool get isLoadingInvitations => _isLoadingInvitations;

  String? get invitationError => _invitationError;

  final Set<int> _processingInvitationIds = {};

  bool isInvitationProcessing(int invitationId) {
    return _processingInvitationIds.contains(invitationId);
  }

  // completed appointment getters
  List<ActiveAppointmentModel> _completedAppointments = [];

  bool _isLoadingCompletedAppointments = false;
  String? _completedAppointmentsError;

  List<ActiveAppointmentModel> get completedAppointments =>
      _completedAppointments;

  bool get isLoadingCompletedAppointments => _isLoadingCompletedAppointments;

  String? get completedAppointmentsError => _completedAppointmentsError;

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
      final rawAppointments = await _activeAppointmentService
          .fetchActiveAppointments(client: client, userId: userId);

      _activeAppointments = _activeAppointmentService.mapActiveAppointments(
        rawAppointments,
      );

      debugPrint('PROVIDER ACTIVE APPOINTMENTS: ${_activeAppointments.length}');
    } catch (e) {
      debugPrint('FETCH ACTIVE APPOINTMENTS ERROR: $e');
    }

    notifyListeners();
  }

  Future<void> fetchInvitationRequests({required OdooClient client}) async {
    _isLoadingInvitations = true;
    _invitationError = null;
    notifyListeners();

    try {
      final result = await _invitationsAppointmentService
          .fetchInvitationRequests(client: client);

      _invitationRequests = result
          .map(
            (item) => InvitationRequestModel.fromOdoo(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (e) {
      _invitationError = e.toString();
      debugPrint('Error fetching invitations: $e');
    } finally {
      _isLoadingInvitations = false;
      notifyListeners();
    }
  }

  Future<void> acceptInvitation({
    required OdooClient client,
    required int appointmentId,
    required int userId,
  }) async {
    if (_processingInvitationIds.contains(appointmentId)) return;

    _processingInvitationIds.add(appointmentId);
    notifyListeners();

    try {
      await _invitationsAppointmentService.acceptInvitation(
        client: client,
        appointmentId: appointmentId,
      );

      await fetchInvitationRequests(client: client);

      await fetchActiveAppointments(client: client, userId: userId);
    } catch (e) {
      debugPrint('Error accepting invitation: $e');
      rethrow;
    } finally {
      _processingInvitationIds.remove(appointmentId);
      notifyListeners();
    }
  }

  Future<void> declineInvitation({
    required OdooClient client,
    required int appointmentId,
  }) async {
    if (_processingInvitationIds.contains(appointmentId)) return;

    _processingInvitationIds.add(appointmentId);
    notifyListeners();

    try {
      await _invitationsAppointmentService.declineInvitation(
        client: client,
        appointmentId: appointmentId,
      );

      await fetchInvitationRequests(client: client);
    } catch (e) {
      debugPrint('Error declining invitation: $e');
      rethrow;
    } finally {
      _processingInvitationIds.remove(appointmentId);
      notifyListeners();
    }
  }

  Future<void> fetchCompletedAppointments({required OdooClient client}) async {
    _isLoadingCompletedAppointments = true;
    _completedAppointmentsError = null;
    notifyListeners();

    try {
      final result = await _completedAppointmentService
          .fetchCompletedAppointments(client: client);

      _completedAppointments = result.map((item) {
        final event = Map<String, dynamic>.from(item);

        final appointmentType = event['appointment_type_id'];

        final startString = event['start'] as String;
        final startDateTime = DateTime.parse(
          '${startString.replaceFirst(' ', 'T')}Z',
        ).toLocal();

        final hour = startDateTime.hour % 12 == 0
            ? 12
            : startDateTime.hour % 12;

        final minute = startDateTime.minute.toString().padLeft(2, '0');

        final period = startDateTime.hour >= 12 ? 'PM' : 'AM';

        return ActiveAppointmentModel(
          id: event['id'] as int,
          clientName: event['client_name'] ?? 'Unknown Client',
          serviceName: appointmentType is List && appointmentType.length > 1
              ? appointmentType[1].toString()
              : 'Appointment',
          durationMinutes: event['duration_minutes'] ?? 0,
          payout: 0.0,
          appointmentDateTime:
              '${startDateTime.day}/${startDateTime.month}/${startDateTime.year} '
              '$hour:$minute $period',
          clientNote: event['client_note'],
        );
      }).toList();
    } catch (e) {
      _completedAppointmentsError = e.toString();
      debugPrint('Error fetching completed appointments: $e');
    } finally {
      _isLoadingCompletedAppointments = false;
      notifyListeners();
    }
  }
}
