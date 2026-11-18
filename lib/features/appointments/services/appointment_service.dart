import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/event_model.dart';
import '../models/attendee_model.dart';
import '../models/appointment_type_model.dart';
import '../models/resource_model.dart';

class AppointmentService {

  Future<List<EventModel>> fetchTodayEvents({
    required OdooClient client,
    required int userId,
    required String timezone,
    required bool isManager,
  }) async {
    final dateRange = _getTodayUtcRange(timezone);

    // Manager: fetch all appointments for today.
    // Staff: first find appointments assigned to that staff member.

    List<int> eventIds = [];

    if (!isManager) {

      final bookingResult = await client.callKw({
        'model': 'appointment.booking.line',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['active', '=', true],
            ['appointment_user_id', '=', userId],
            ['event_start', '<', dateRange['end']],
            ['event_stop', '>=', dateRange['start']],
          ],
          'fields': ['calendar_event_id'],
        },
      });

      if (bookingResult is! List) return [];

      eventIds = bookingResult
          .map((record) {
        final event = record['calendar_event_id'];

        if (event is List && event.isNotEmpty) {
          return event[0] as int;
        }
      })
          .whereType<int>()
          .toSet()
          .toList();

      if (eventIds.isEmpty) return [];
    }

    // Fetch calendar events.
    final List<dynamic> domain = [
      ['start', '<', dateRange['end']],
      ['stop', '>=', dateRange['start']],
      ['appointment_type_id', '!=', false],

    ];

    if (!isManager) {
      domain.add(['id', 'in', eventIds]);
    }

    final result = await client.callKw({
      'model': 'calendar.event',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': domain,
        'fields': [
          'id',
          'name',
          'start',
          'stop',
          'allday',
          'duration',
          'description',
          'location',
          'user_id',
          'partner_ids',
          'attendee_ids',
          'appointment_type_id',
          'resource_ids',
          'active',
        ],
        'order': 'start asc',
      },
    });

    if (result is! List) return [];

    return result.map((record) {
      return EventModel.fromJson(
        Map<String, dynamic>.from(record as Map),
        timezone,
      );
    }).toList();
  }

  Future<List<AttendeeModel>> fetchAttendees(
    OdooClient client,
    List<EventModel> events,
  ) async {
    // Collect attendee IDs from all fetched events.
    final attendeeIds = events
        .expand(
          (event) => event.attendeeIds,
        ) // expands the lists and fetch only the attendee of the given event.
        .toSet() // removes the duplicate of same attendees
        .toList(); // convert back to list

    // No attendees available.
    if (attendeeIds.isEmpty) {
      return [];
    }

    final result = await client.callKw({
      'model': 'calendar.attendee',
      'method': 'read',
      'args': [attendeeIds],
      'kwargs': {
        'fields': ['id', 'event_id', 'partner_id', 'email', 'state'],
      },
    });

    if (result is! List) {
      return [];
    }

    return result.map((record) {
      return AttendeeModel.fromJson(Map<String, dynamic>.from(record as Map));
    }).toList();
  }



  Future<List<AppointmentTypeModel>> fetchAppointmentTypes(
    OdooClient client,
  ) async {
    final result = await client.callKw({
      'model': 'appointment.type',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [],
        'fields': [
          'id',
          'name',
          'appointment_duration',
          'location',
          'schedule_based_on',
          'assignment_method',
          'resource_ids',
          'active',
        ],
        'order': 'name asc',
      },
    });

    if (result is! List) {
      return [];
    }

    return result.map((record) {
      return AppointmentTypeModel.fromJson(
        Map<String, dynamic>.from(record as Map),
      );
    }).toList();
  }


  Future<List<ResourceModel>> fetchResources(OdooClient client) async {
    final result = await client.callKw({
      'model': 'appointment.resource',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [],
        'fields': ['id', 'name', 'company_id', 'active'],
        'order': 'name asc',
      },
    });

    if (result is! List) {
      return [];
    }

    return result.map((record) {
      return ResourceModel.fromJson(Map<String, dynamic>.from(record as Map));
    }).toList();
  }


  Map<String, String> _getTodayUtcRange(String timezone) {
    final location = tz.getLocation(timezone);

    // Current date and time in the user's timezone.
    final now = tz.TZDateTime.now(location);

    // Start of today in the user's timezone.
    final startOfDay = tz.TZDateTime(location, now.year, now.month, now.day);

    // Start of tomorrow in the user's timezone.
    final startOfNextDay = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day + 1,
    );

    // Convert both boundaries to UTC for Odoo.
    return {
      'start': _formatOdooDateTime(startOfDay.toUtc()),
      'end': _formatOdooDateTime(startOfNextDay.toUtc()),
    };
  }

  // Format DateTime as Odoo expects:
  // yyyy-MM-dd HH:mm:ss
  String _formatOdooDateTime(DateTime dateTime) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '${dateTime.year}-'
        '${twoDigits(dateTime.month)}-'
        '${twoDigits(dateTime.day)} '
        '${twoDigits(dateTime.hour)}:'
        '${twoDigits(dateTime.minute)}:'
        '${twoDigits(dateTime.second)}';
  }
}
