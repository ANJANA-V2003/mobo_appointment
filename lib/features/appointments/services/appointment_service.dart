import 'package:flutter/widgets.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/booking_type_count_model.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/peak_hours_model.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/event_model.dart';
import '../models/attendee_model.dart';
import '../models/appointment_type_model.dart';
import '../models/resource_model.dart';

class AppointmentService {
  Future<int> fetchCustomerCount({required OdooClient client}) async {
    final result = await client.callKw({
      'model': 'res.partner',
      'method': 'search_count',
      'args': [
        [
          ['active', '=', true],
          ['customer_rank', '>', 0],
        ],
      ],
      'kwargs': {},
    });

    return result as int;
  }

  Future<int> fetchAppointmentTypeCount({required OdooClient client}) async {
    final result = await client.callKw({
      'model': 'appointment.type',
      'method': 'search_count',
      'args': [
        [
          ['active', '=', true],
        ],
      ],
      'kwargs': {},
    });

    return result as int;
  }

  Map<String, String> _getUtcDateRange({
    required DateTime startDate,
    required DateTime endDate,
    required String timezone,
  }) {
    final location = tz.getLocation(timezone);

    // Start of the selected start date.
    final start = tz.TZDateTime(
      location,
      startDate.year,
      startDate.month,
      startDate.day,
    );

    // End date is exclusive, so include the entire selected end date.
    final end = tz.TZDateTime(
      location,
      endDate.year,
      endDate.month,
      endDate.day + 1,
    );

    String formatOdooDate(DateTime date) {
      final utc = date.toUtc();

      return '${utc.year.toString().padLeft(4, '0')}-'
          '${utc.month.toString().padLeft(2, '0')}-'
          '${utc.day.toString().padLeft(2, '0')} '
          '${utc.hour.toString().padLeft(2, '0')}:'
          '${utc.minute.toString().padLeft(2, '0')}:'
          '${utc.second.toString().padLeft(2, '0')}';
    }

    return {'start': formatOdooDate(start), 'end': formatOdooDate(end)};
  }

  Future<List<EventModel>> fetchEventsByDateRange({
    required OdooClient client,
    required int userId,
    required String timezone,
    required bool isManager,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final dateRange = _getUtcDateRange(
      startDate: startDate,
      endDate: endDate,
      timezone: timezone,
    );

    List<int> eventIds = [];

    // Staff: find appointments assigned to that staff member.
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
              return (event[0] as num).toInt();
            }

            return null;
          })
          .whereType<int>()
          .toSet()
          .toList();

      if (eventIds.isEmpty) return [];
    }

    // Fetch calendar events within the selected date range.
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
          'appointment_status',
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
        'domain': [
          ['active', '=', true],
        ],
        'fields': [
          'id',
          'name',
          'company_id',
          'active',
          'resource_calendar_id',
          'tz',
        ],
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

  Future<bool> areRevenueModulesInstalled(OdooClient client) async {
    final result = await client.callKw({
      'model': 'ir.module.module',
      'method': 'search_read',
      'args': [
        [
          [
            'name',
            'in',
            ['sale_management', 'accountant'],
          ],
          ['state', '=', 'installed'],
        ],
      ],
      'kwargs': {
        'fields': ['name', 'state'],
      },
    });

    final installedModules = (result as List)
        .map((module) => module['name'] as String)
        .toSet();

    return installedModules.contains('sale_management') &&
        installedModules.contains('accountant');
  }

  // fetching the booking hours of the staffs
  Future<double> fetchBookedStaffHours({
    required OdooClient client,
    required int userId,
    required bool isAllStaff,
    required DateTime startDate,
    required DateTime endDate,
    required String timezone,
  }) async {
    final dateRange = _getUtcDateRange(
      startDate: startDate,
      endDate: endDate,
      timezone: timezone,
    );

    final start = DateTime.parse(dateRange['start']!).toUtc();
    final end = DateTime.parse(dateRange['end']!).toUtc();

    final domain = <dynamic>[
      ['active', '=', true],
      ['event_start', '<', dateRange['end']],
      ['event_stop', '>', dateRange['start']],
    ];

    if (!isAllStaff) {
      domain.add(['appointment_user_id', '=', userId]);
    }

    final result = await client.callKw({
      'model': 'appointment.booking.line',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': domain,
        'fields': [
          'appointment_user_id',
          'event_start',
          'event_stop',
        ],
      },
    });

    if (result is! List) return 0.0;

    double totalHours = 0.0;

    for (final record in result) {
      final data = Map<String, dynamic>.from(record as Map);

      final startValue = data['event_start'];
      final stopValue = data['event_stop'];

      if (startValue == null || stopValue == null) continue;

      final bookingStart = DateTime.parse(
        startValue.toString().replaceFirst(' ', 'T'),
      ).toUtc();

      final bookingStop = DateTime.parse(
        stopValue.toString().replaceFirst(' ', 'T'),
      ).toUtc();

      final clippedStart =
      bookingStart.isBefore(start) ? start : bookingStart;

      final clippedStop =
      bookingStop.isAfter(end) ? end : bookingStop;

      if (clippedStop.isAfter(clippedStart)) {
        totalHours += clippedStop
            .difference(clippedStart)
            .inMinutes / 60.0;
      }
    }

    return totalHours;
  }


  // for peak hours
  Future<List<PeakHoursModel>> fetchPeakHours({
    required OdooClient client,
    required int userId,
    required String timezone,
    required bool isManager,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final location = tz.getLocation(timezone);

    // Convert selected dates into the user's timezone.
    final startOfDay = tz.TZDateTime(
      location,
      startDate.year,
      startDate.month,
      startDate.day,
    );

    // End date is inclusive.
    final endExclusive = tz.TZDateTime(
      location,
      endDate.year,
      endDate.month,
      endDate.day + 1,
    );

    // Convert boundaries to UTC for Odoo.
    final startUtc = _formatOdooDateTime(startOfDay.toUtc());
    final endUtc = _formatOdooDateTime(endExclusive.toUtc());

    List<int> eventIds = [];

    // Staff: fetch only their assigned appointment events.
    if (!isManager) {
      final bookingResult = await client.callKw({
        'model': 'appointment.booking.line',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['active', '=', true],
            ['appointment_user_id', '=', userId],
            ['event_start', '<', endUtc],
            ['event_stop', '>=', startUtc],
          ],
          'fields': ['calendar_event_id'],
        },
      });

      if (bookingResult is! List) {
        return [];
      }

      eventIds = bookingResult
          .map((record) {
            final event = record['calendar_event_id'];

            if (event is List && event.isNotEmpty) {
              return event[0] as int;
            }

            return null;
          })
          .whereType<int>()
          .toSet()
          .toList();

      if (eventIds.isEmpty) {
        return _emptyPeakHours();
      }
    }

    // Fetch appointment events.
    final List<dynamic> domain = [
      ['start', '>=', startUtc],
      ['start', '<', endUtc],
      ['appointment_type_id', '!=', false],
      ['active', '=', true],
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
        'fields': ['id', 'start'],
        'order': 'start asc',
      },
    });

    if (result is! List) {
      return [];
    }

    // Initialize all 24 hours with zero appointments.
    final Map<int, int> hourlyCounts = {
      for (int hour = 0; hour < 24; hour++) hour: 0,
    };

    // Group appointments by their local starting hour.
    final Set<int> countedEventIds = {};

    for (final record in result) {
      final event = Map<String, dynamic>.from(record as Map);

      final eventId = event['id'] as int;

      // Prevent duplicate counting.
      if (!countedEventIds.add(eventId)) {
        continue;
      }

      final rawStart = event['start'];

      if (rawStart == null || rawStart == false) {
        continue;
      }

      // Odoo datetime strings are UTC without a timezone suffix.
      final utcDateTime = DateTime.parse(
        '${rawStart.toString().replaceFirst(' ', 'T')}Z',
      );

      // Convert UTC into the selected user's timezone.
      final localDateTime = tz.TZDateTime.from(utcDateTime, location);

      hourlyCounts[localDateTime.hour] = hourlyCounts[localDateTime.hour]! + 1;
    }

    // Return all hours in chronological order.
    return List.generate(24, (hour) {
      return PeakHoursModel(hour: hour, count: hourlyCounts[hour]!);
    });
  }

  List<PeakHoursModel> _emptyPeakHours() {
    return List.generate(24, (hour) => PeakHoursModel(hour: hour, count: 0));
  }

  Future<List<BookingTypeCountModel>> fetchBookingTypeCounts({
    required OdooClient client,
    required int userId,
    required String timezone,
    required bool isManager,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final location = tz.getLocation(timezone);

    // Start of the selected start date in the user's timezone.
    final startOfDay = tz.TZDateTime(
      location,
      startDate.year,
      startDate.month,
      startDate.day,
    );

    // End date is inclusive, so fetch until the start of
    // the following day.
    final endExclusive = tz.TZDateTime(
      location,
      endDate.year,
      endDate.month,
      endDate.day + 1,
    );

    // Convert date boundaries to UTC for Odoo.
    final startUtc = _formatOdooDateTime(startOfDay.toUtc());
    final endUtc = _formatOdooDateTime(endExclusive.toUtc());

    List<int> eventIds = [];

    // Staff can only see their own appointment bookings.
    if (!isManager) {
      final bookingResult = await client.callKw({
        'model': 'appointment.booking.line',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['active', '=', true],
            ['appointment_user_id', '=', userId],
            ['event_start', '<', endUtc],
            ['event_stop', '>=', startUtc],
          ],
          'fields': ['calendar_event_id'],
        },
      });

      if (bookingResult is! List) {
        return [];
      }

      eventIds = bookingResult
          .map((record) {
            final event = record['calendar_event_id'];

            if (event is List && event.isNotEmpty) {
              return event[0] as int;
            }

            return null;
          })
          .whereType<int>()
          .toSet()
          .toList();

      if (eventIds.isEmpty) {
        return [];
      }
    }

    // Fetch appointment events for the selected date range.
    final List<dynamic> domain = [
      ['start', '<', endUtc],
      ['stop', '>=', startUtc],
      ['appointment_type_id', '!=', false],
      ['active', '=', true],
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
        'fields': ['id', 'appointment_type_id'],
      },
    });

    if (result is! List) {
      return [];
    }

    // Group appointments by appointment type.
    final Map<int, BookingTypeCountModel> counts = {};

    for (final record in result) {
      final event = Map<String, dynamic>.from(record as Map);

      final appointmentType = event['appointment_type_id'];

      if (appointmentType is! List || appointmentType.isEmpty) {
        continue;
      }

      final typeId = appointmentType[0] as int;
      final typeName = appointmentType.length > 1
          ? appointmentType[1].toString()
          : 'Unknown Type';

      final currentCount = counts[typeId]?.count ?? 0;

      counts[typeId] = BookingTypeCountModel(
        appointmentTypeId: typeId,
        name: typeName,
        count: currentCount + 1,
      );
    }

    final bookingTypes = counts.values.toList();

    // Display the most frequently booked types first.
    bookingTypes.sort((a, b) => b.count.compareTo(a.count));

    return bookingTypes;
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
