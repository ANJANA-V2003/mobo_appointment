import 'package:flutter/widgets.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/booking_type_count_model.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/peak_hours_model.dart';
import 'package:mobo_appointment_project/features/appointments/models/staff_model.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/event_model.dart';
import '../models/attendee_model.dart';
import '../models/appointment_type_model.dart';
import '../models/resource_model.dart';

class AppointmentService {

  Future<int> fetchCustomerCount({
    required OdooClient client,
  }) async {
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

  Future<int> fetchAppointmentTypeCount({
    required OdooClient client,
  }) async {
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

  Future<bool> areRevenueModulesInstalled(
      OdooClient client,
      ) async {
    final result = await client.callKw({
      'model': 'ir.module.module',
      'method': 'search_read',
      'args': [
        [
          ['name', 'in', ['sale_management', 'account']],
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
        installedModules.contains('account');
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
        'fields': [
          'id',
          'start',
        ],
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
      final localDateTime = tz.TZDateTime.from(
        utcDateTime,
        location,
      );

      hourlyCounts[localDateTime.hour] =
          hourlyCounts[localDateTime.hour]! + 1;
    }

    // Return all hours in chronological order.
    return List.generate(24, (hour) {
      return PeakHoursModel(
        hour: hour,
        count: hourlyCounts[hour]!,
      );
    });
  }

  List<PeakHoursModel> _emptyPeakHours() {
    return List.generate(
      24,
          (hour) => PeakHoursModel(hour: hour, count: 0),
    );
  }


  //for the utilization card
  // Future<List<ResourceModel>> fetchStaffResources(
  //     OdooClient client,
  //     ) async {
  //   final result = await client.callKw({
  //     'model': 'resource.resource',
  //     'method': 'search_read',
  //     'args': [],
  //     'kwargs': {
  //       'domain': [
  //         ['resource_type', '=', 'user'],
  //         ['active', '=', true],
  //       ],
  //       'fields': [
  //         'id',
  //         'name',
  //         'company_id',
  //         'active',
  //         'user_id',
  //         'calendar_id',
  //         'tz',
  //       ],
  //       'order': 'name asc',
  //     },
  //   });
  //   if (result is! List) {
  //     return [];
  //   }
  //   return result.map((record) {
  //     return ResourceModel.fromJson(
  //       Map<String, dynamic>.from(record as Map),
  //     );
  //   }).toList();
  // }

  //for bookings card

  Future<List<StaffModel>> fetchStaff(
      OdooClient client,
      ) async {
    try {
      // Fetch appointment types
      final types = await client.callKw({
        'model': 'appointment.type',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'fields': ['staff_user_ids'],
        },
      });

      final Set<int> staffIds = {};

      for (final type in types) {
        final ids = type['staff_user_ids'];

        if (ids is List) {
          staffIds.addAll(ids.cast<int>());
        }
      }

      if (staffIds.isEmpty) {
        return [];
      }

      // Fetch unique staff members
      final result = await client.callKw({
        'model': 'res.users',
        'method': 'search_read',
        'args': [
          [
            ['id', 'in', staffIds.toList()],
          ],
        ],
        'kwargs': {
          'fields': [
            'id',
            'name',
            'email',
            'tz',
            'active',
          ],
        },
      });


      return (result as List)
          .map(
            (item) => StaffModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } catch (e) {
      debugPrint('Fetch staff error: $e');
      rethrow;
    }
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
        'fields': [
          'id',
          'appointment_type_id',
        ],
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

      if (appointmentType is! List ||
          appointmentType.isEmpty) {
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
    bookingTypes.sort(
          (a, b) => b.count.compareTo(a.count),
    );

    return bookingTypes;
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
