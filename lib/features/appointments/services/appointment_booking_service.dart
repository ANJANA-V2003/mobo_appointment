import 'package:odoo_rpc/odoo_rpc.dart';

class AppointmentBookingService {
  Future<List<Map<String, dynamic>>> fetchBookingLines({
    required OdooClient client,
    required DateTime startDate,
    required DateTime endDate,
    int? staffId,
    bool isManager = false,
  }) async {
    final domain = <dynamic>[
      ['active', '=', true],
      ['event_start', '>=', _formatOdooDate(startDate)],
      ['event_start', '<=', _formatOdooDate(endDate)],
    ];
    // My Bookings: restrict to the logged-in staff member.
    // Manager All Staff: don't apply the staff restriction.
    if (!isManager && staffId != null) {
      domain.add(['appointment_user_id', '=', staffId]);
    }

    final result = await client.callKw({
      'model': 'appointment.booking.line',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': domain,
        'fields': [
          'id',
          'display_name',
          'appointment_user_id',
          'appointment_type_id',
          'appointment_resource_id',
          'event_start',
          'event_stop',
          'calendar_event_id',
          'active',
        ],
        'order': 'event_start asc',
      },
    });

    if (result is! List || result.isEmpty) {
      return [];
    }

    return result
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchCalendarEvents({
    required OdooClient client,
    required List<int> eventIds,
  }) async {
    if (eventIds.isEmpty) return [];

    final result = await client.callKw({
      'model': 'calendar.event',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [
          ['id', 'in', eventIds],
        ],
        'fields': [
          'id',
          'name',
          'start',
          'stop',
          'partner_ids',
          'appointment_type_id',
          'resource_ids',
          'description',
          'location',
        ],
      },
    });

    if (result is! List || result.isEmpty) {
      return [];
    }

    return result
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchPartners({
    required OdooClient client,
    required List<int> partnerIds,
  }) async {
    if (partnerIds.isEmpty) return [];

    final result = await client.callKw({
      'model': 'res.partner',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [
          ['id', 'in', partnerIds],
        ],
        'fields': ['id', 'name', 'phone', 'email'],
      },
    });

    if (result is! List || result.isEmpty) {
      return [];
    }

    return result
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  String _formatOdooDate(DateTime date) {
    final utc = date.toUtc();

    final year = utc.year.toString().padLeft(4, '0');
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');

    final hour = utc.hour.toString().padLeft(2, '0');
    final minute = utc.minute.toString().padLeft(2, '0');
    final second = utc.second.toString().padLeft(2, '0');

    return '$year-$month-$day $hour:$minute:$second';
  }
}
