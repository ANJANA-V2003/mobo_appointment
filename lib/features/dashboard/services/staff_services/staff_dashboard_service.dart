import 'package:mobo_appointment_project/features/appointments/models/card_models/appointment_status_counts_model.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/arrivin_soon_card_model.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/my_load_card_model.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/up_next_card_model.dart';
import 'package:odoo_rpc/odoo_rpc.dart';
import 'package:timezone/timezone.dart' as tz;

class StaffDashboardService {
  Future<ArrivingSoonCardModel> fetchArrivingSoon({
    required OdooClient client,
    required int userId,
    required bool isManager,
    required String timezone,
  }) async {
    final nowUtc = DateTime.now().toUtc();
    final endUtc = nowUtc.add(const Duration(minutes: 30));

    final startString = _formatOdooDateTime(nowUtc);
    final endString = _formatOdooDateTime(endUtc);

    List<int> eventIds = [];

    // Staff: fetch only their assigned appointment booking lines.
    if (!isManager) {
      final bookingDomain = [
        ['active', '=', true],
        ['appointment_user_id', '=', userId],
        ['event_start', '>=', startString],
        ['event_start', '<', endString],
      ];

      print('Booking line domain: $bookingDomain');

      final bookingResult = await client.callKw({
        'model': 'appointment.booking.line',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': bookingDomain,
          'fields': [
            'id',
            'appointment_user_id',
            'event_start',
            'calendar_event_id',
          ],
        },
      });

      if (bookingResult is! List || bookingResult.isEmpty) {
        return ArrivingSoonCardModel.empty();
      }

      eventIds = bookingResult
          .map((record) {
            final booking = Map<String, dynamic>.from(record as Map);
            final event = booking['calendar_event_id'];

            if (event is List && event.isNotEmpty) {
              return (event[0] as num).toInt();
            }

            return null;
          })
          .whereType<int>()
          .toSet()
          .toList();

      if (eventIds.isEmpty) {
        return ArrivingSoonCardModel.empty();
      }
    }

    // Fetch appointments starting in the next 15 minutes.
    final List<dynamic> domain = [
      ['start', '>=', startString],
      ['start', '<', endString],
      ['appointment_type_id', '!=', false],
      ['active', '=', true],
    ];

    // Staff sees their assigned events.
    // Manager sees all matching appointment events.
    if (!isManager) {
      domain.add(['id', 'in', eventIds]);
    }

    final eventResult = await client.callKw({
      'model': 'calendar.event',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': domain,
        'fields': ['id', 'start', 'partner_ids'],
        'order': 'start asc',
      },
    });

    if (eventResult is! List || eventResult.isEmpty) {
      return ArrivingSoonCardModel.empty();
    }

    final events = eventResult
        .map((record) => Map<String, dynamic>.from(record as Map))
        .toList();

    // Collect attendee partner IDs.
    final partnerIds = events
        .expand((event) {
          final partners = event['partner_ids'];

          if (partners is List) {
            return partners.whereType<num>().map((id) => id.toInt());
          }

          return <int>[];
        })
        .toSet()
        .toList();

    final Map<int, String> partnerNames = {};

    if (partnerIds.isNotEmpty) {
      final partnerResult = await client.callKw({
        'model': 'res.partner',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['id', 'in', partnerIds],
          ],
          'fields': ['id', 'name'],
        },
      });

      if (partnerResult is List) {
        for (final record in partnerResult) {
          final partner = Map<String, dynamic>.from(record as Map);

          final id = (partner['id'] as num).toInt();
          final name = partner['name']?.toString() ?? '';

          // Keep only partners identified as customers.
          if (name.isNotEmpty) {
            partnerNames[id] = name;
          }
        }
      }
    }

    // Events are ordered by start time.
    final nextEvent = events.first;
    final rawStart = nextEvent['start'];

    if (rawStart == null || rawStart == false) {
      return ArrivingSoonCardModel.empty();
    }

    // Odoo datetime is UTC without a Z suffix.
    final startUtc = DateTime.parse(
      '${rawStart.toString().replaceFirst(' ', 'T')}Z',
    );

    final location = tz.getLocation(timezone);
    final localStart = tz.TZDateTime.from(startUtc, location);

    // Round up so the badge doesn't understate the remaining time.
    final remainingMinutes = (startUtc.difference(nowUtc).inSeconds / 60)
        .ceil();

    // Find the first customer partner for the next event.
    String? nextClientName;

    final eventPartnerIds = nextEvent['partner_ids'];

    if (eventPartnerIds is List) {
      for (final partnerId in eventPartnerIds) {
        if (partnerId is! num) continue;

        final id = partnerId.toInt();

        if (partnerNames.containsKey(id)) {
          nextClientName = partnerNames[id];
          break;
        }
      }
    }

    final appointmentTime =
        '${localStart.hour.toString().padLeft(2, '0')}:'
        '${localStart.minute.toString().padLeft(2, '0')}';

    final result = ArrivingSoonCardModel(
      clientCount: events.length,
      nextClientName: nextClientName,
      nextAppointmentTime: appointmentTime,
      minutesUntilNext: remainingMinutes < 0 ? 0 : remainingMinutes,
    );

    return result;
  }

  Future<UpNextCardModel> fetchUpNext({
    required OdooClient client,
    required int userId,
    required bool isManager,
    required String timezone,
  }) async {
    final nowUtc = DateTime.now().toUtc();
    final startString = _formatOdooDateTime(nowUtc);

    List<int> eventIds = [];

    // Staff: fetch only their assigned upcoming booking lines.
    if (!isManager) {
      final bookingResult = await client.callKw({
        'model': 'appointment.booking.line',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['active', '=', true],
            ['appointment_user_id', '=', userId],
            ['event_start', '>=', startString],
          ],
          'fields': ['id', 'calendar_event_id', 'event_start'],
        },
      });

      if (bookingResult is! List || bookingResult.isEmpty) {
        return UpNextCardModel.empty();
      }

      eventIds = bookingResult
          .map((record) {
            final booking = Map<String, dynamic>.from(record as Map);
            final event = booking['calendar_event_id'];

            if (event is List && event.isNotEmpty) {
              return (event[0] as num).toInt();
            }

            return null;
          })
          .whereType<int>()
          .toSet()
          .toList();

      if (eventIds.isEmpty) {
        return UpNextCardModel.empty();
      }
    }
    final now = DateTime.now();

    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));
    // Fetch all upcoming appointment events.
    final List<dynamic> domain = [
      ['start', '>=', startString],
      ['appointment_type_id', '!=', false],
      ['active', '=', true],
      ['start', '>=', _formatOdooDateTime(todayStart)],
      ['start', '<', _formatOdooDateTime(tomorrowStart)],
    ];

    // Staff sees only their assigned events.
    if (!isManager) {
      domain.add(['id', 'in', eventIds]);
    }

    final eventResult = await client.callKw({
      'model': 'calendar.event',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': domain,
        'fields': ['id', 'name', 'start', 'stop', 'partner_ids'],
        'order': 'start asc',
      },
    });

    if (eventResult is! List || eventResult.isEmpty) {
      return UpNextCardModel.empty();
    }

    final events = eventResult
        .map((record) => Map<String, dynamic>.from(record as Map))
        .toList();

    // Collect partner IDs from upcoming events.
    final partnerIds = events
        .expand((event) {
          final partners = event['partner_ids'];

          if (partners is List) {
            return partners.whereType<num>().map((id) => id.toInt());
          }

          return <int>[];
        })
        .toSet()
        .toList();

    // Fetch customer/contact names.
    final Map<int, String> partnerNames = {};

    if (partnerIds.isNotEmpty) {
      final partnerResult = await client.callKw({
        'model': 'res.partner',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['id', 'in', partnerIds],
          ],
          'fields': ['id', 'name'],
        },
      });

      if (partnerResult is List) {
        for (final record in partnerResult) {
          final partner = Map<String, dynamic>.from(record as Map);

          final id = (partner['id'] as num).toInt();
          final name = partner['name']?.toString() ?? '';

          if (name.isNotEmpty) {
            partnerNames[id] = name;
          }
        }
      }
    }
    // Events are ordered by start time.
    final nextEvent = events.first;

    final rawStart = nextEvent['start'];
    final rawStop = nextEvent['stop'];

    if (rawStart == null || rawStart == false) {
      return UpNextCardModel.empty();
    }

    // Convert Odoo UTC datetime into user's timezone.
    final startUtc = DateTime.parse(
      '${rawStart.toString().replaceFirst(' ', 'T')}Z',
    );

    final stopUtc = rawStop == null || rawStop == false
        ? null
        : DateTime.parse('${rawStop.toString().replaceFirst(' ', 'T')}Z');

    final location = tz.getLocation(timezone);

    final localStart = tz.TZDateTime.from(startUtc, location);

    final localStop = stopUtc == null
        ? null
        : tz.TZDateTime.from(stopUtc, location);

    // Resolve next appointment client.
    String? nextClientName;

    final eventPartnerIds = nextEvent['partner_ids'];

    if (eventPartnerIds is List) {
      for (final partnerId in eventPartnerIds) {
        if (partnerId is! num) continue;

        final id = partnerId.toInt();

        if (partnerNames.containsKey(id)) {
          nextClientName = partnerNames[id];
          break;
        }
      }
    }

    // Format appointment start and end times.
    String formatTime(tz.TZDateTime dateTime) {
      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';

      return '$hour:$minute $period';
    }

    final appointmentTime = formatTime(localStart);

    final appointmentEndTime = localStop == null ? null : formatTime(localStop);

    final result = UpNextCardModel(
      clientCount: events.length,
      nextClientName: nextClientName,
      nextAppointmentTime: appointmentTime,
      appointmentEndTime: appointmentEndTime,
    );

    return result;
  }

  Future<MyLoadCardModel> fetchMyLoad({
    required OdooClient client,
    required int userId,
    required String timezone,
  }) async {
    final location = tz.getLocation(timezone);
    final now = tz.TZDateTime.now(location);

    // Start and end of today in the staff member's timezone.
    final startOfDay = tz.TZDateTime(location, now.year, now.month, now.day);

    final startOfTomorrow = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day + 1,
    );

    // Convert local day boundaries to UTC for Odoo.
    final startUtc = _formatOdooDateTime(startOfDay.toUtc());
    final endUtc = _formatOdooDateTime(startOfTomorrow.toUtc());

    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    // Fetch today's bookings assigned to this staff member.
    final bookingResult = await client.callKw({
      'model': 'appointment.booking.line',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [
          ['active', '=', true],
          ['appointment_user_id', '=', userId],
          ['event_start', '>=', startUtc],
          ['event_start', '<', endUtc],
        ],
        'fields': ['id', 'event_start', 'calendar_event_id'],
      },
    });

    final bookingLines = bookingResult as List<dynamic>;

    // Collect the linked calendar event IDs.
    final eventIds = <int>{};

    for (final item in bookingLines) {
      final line = Map<String, dynamic>.from(item as Map);
      final calendarEvent = line['calendar_event_id'];

      if (calendarEvent is List && calendarEvent.isNotEmpty) {
        final eventId = calendarEvent[0];

        if (eventId is int) {
          eventIds.add(eventId);
        }
      }
    }

    double bookedHours = 0;

    if (eventIds.isNotEmpty) {
      final eventResult = await client.callKw({
        'model': 'calendar.event',
        'method': 'search_read',
        'args': [],
        'kwargs': {
          'domain': [
            ['id', 'in', eventIds.toList()],
            ['active', '=', true],
            ['appointment_type_id', '!=', false],
            ['start', '>=', _formatOdooDateTime(todayStart)],
            ['start', '<', _formatOdooDateTime(tomorrowStart)],
          ],
          'fields': ['id', 'start', 'stop'],
        },
      });

      final events = eventResult as List<dynamic>;

      for (final item in events) {
        final event = Map<String, dynamic>.from(item as Map);

        final startValue = event['start'];
        final stopValue = event['stop'];

        if (startValue == null || stopValue == null) {
          continue;
        }

        final eventStart = _parseOdooDateTime(startValue.toString());
        final eventStop = _parseOdooDateTime(stopValue.toString());

        final duration = eventStop.difference(eventStart).inMinutes;

        if (duration > 0) {
          bookedHours += duration / 60.0;
        }
      }
    }

    // Fetch the staff member's working calendar.
    final resourceResult = await client.callKw({
      'model': 'resource.resource',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [
          ['user_id', '=', userId],
        ],
        'fields': ['id', 'calendar_id'],
        'limit': 1,
      },
    });

    final resources = resourceResult as List<dynamic>;

    double availableHours = 0;

    if (resources.isNotEmpty) {
      final resource = Map<String, dynamic>.from(resources.first as Map);

      final calendarValue = resource['calendar_id'];

      if (calendarValue is List && calendarValue.isNotEmpty) {
        final calendarId = calendarValue[0];

        if (calendarId is int) {
          final attendance = await fetchWorkingHours(
            client: client,
            calendarId: calendarId,
          );

          availableHours = calculateTodayAvailableHours(
            attendance: attendance,
            timezone: timezone,
          );
        }
      }
    }

    return MyLoadCardModel(
      appointmentCount: eventIds.length,
      bookedHours: bookedHours,
      availableHours: availableHours,
    );
  }

  Future<List<dynamic>> fetchWorkingHours({
    required OdooClient client,
    required int calendarId,
  }) async {
    final result = await client.callKw({
      'model': 'resource.calendar.attendance',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [
          ['calendar_id', '=', calendarId],
        ],
        'fields': ['id', 'dayofweek', 'hour_from', 'hour_to'],
        'order': 'dayofweek asc, hour_from asc',
      },
    });

    // debugPrint('WORKING HOURS: $result');

    return result as List<dynamic>;
  }

  Future<AppointmentStatusCountsModel> fetchAppointmentStatusCounts({
    required OdooClient client,
    required int userId,
  }) async {
    // Get appointment booking lines assigned to this staff member.
    final now = DateTime.now();

    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    final bookingResult = await client.callKw({
      'model': 'appointment.booking.line',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [
          ['active', '=', true],
          ['appointment_user_id', '=', userId],
        ],
        'fields': ['id', 'calendar_event_id'],
      },
    });

    final bookingLines = bookingResult as List<dynamic>;
    final eventIds = <int>{};

    for (final item in bookingLines) {
      final line = Map<String, dynamic>.from(item as Map);
      final calendarEvent = line['calendar_event_id'];

      if (calendarEvent is List &&
          calendarEvent.isNotEmpty &&
          calendarEvent[0] is int) {
        eventIds.add(calendarEvent[0] as int);
      }
    }

    if (eventIds.isEmpty) {
      return AppointmentStatusCountsModel.empty();
    }

    // Fetch the related appointment events.
    final eventResult = await client.callKw({
      'model': 'calendar.event',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [
          ['id', 'in', eventIds.toList()],
          ['appointment_type_id', '!=', false],
          // ['stop', '<=', formatOdooDateTime(nowUtc)],
          ['start', '>=', _formatOdooDateTime(todayStart)],
          ['start', '<', _formatOdooDateTime(tomorrowStart)],
        ],
        'fields': ['id', 'appointment_status', 'appointment_invite_id'],
      },
    });

    // Fetch today's invitations directly from calendar.event.
    final invitationResult = await client.callKw({
      'model': 'calendar.event',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [
          ['appointment_status', '=', 'request'],
          ['appointment_type_id', '!=', false],
          ['start', '>=', _formatOdooDateTime(todayStart)],
          ['start', '<', _formatOdooDateTime(tomorrowStart)],
        ],
        'fields': ['id'],
      },
    });

    final invitationEvents = invitationResult as List<dynamic>;

    final invitationsCount = invitationEvents.length;

    final events = eventResult as List<dynamic>;

    int activeCount = 0;
    int completedCount = 0;

    for (final item in events) {
      final event = Map<String, dynamic>.from(item as Map);

      final status = event['appointment_status'];

      if (status == 'booked') {
        activeCount++;
      } else if (status == 'attended') {
        completedCount++;
      }
    }

    return AppointmentStatusCountsModel(
      activeCount: activeCount,
      invitationsCount: invitationsCount,
      completedCount: completedCount,
    );
  }

  Future<List<dynamic>> fetchAppointmentClient({
    required OdooClient client,
    required int partnerId,
  }) async {
    final result = await client.callKw({
      'model': 'res.partner',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [
          ['id', '=', partnerId],
        ],
        'fields': ['id', 'name', 'phone', 'email', 'comment'],
      },
    });

    return result as List<dynamic>;
  }

  double calculateTodayAvailableHours({
    required List<dynamic> attendance,
    required String timezone,
  }) {
    final location = tz.getLocation(timezone);
    final today = tz.TZDateTime.now(location);

    // Odoo: Monday = 0, Tuesday = 1, Wednesday = 2...
    final todayDayOfWeek = (today.weekday - 1).toString();

    double totalHours = 0;

    for (final item in attendance) {
      final record = Map<String, dynamic>.from(item as Map);

      if (record['dayofweek'].toString() != todayDayOfWeek) {
        continue;
      }

      final hourFrom = (record['hour_from'] as num?)?.toDouble() ?? 0;
      final hourTo = (record['hour_to'] as num?)?.toDouble() ?? 0;

      if (hourTo > hourFrom) {
        totalHours += hourTo - hourFrom;
      }
    }

    return totalHours;
  }

  DateTime _parseOdooDateTime(String value) {
    // Odoo datetime strings are normally UTC but don't include a Z suffix.
    final normalized = value.replaceFirst(' ', 'T');

    if (normalized.endsWith('Z')) {
      return DateTime.parse(normalized).toUtc();
    }

    return DateTime.parse('${normalized}Z').toUtc();
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
