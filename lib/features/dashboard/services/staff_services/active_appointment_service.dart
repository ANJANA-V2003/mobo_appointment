import 'package:mobo_appointment_project/features/appointments/models/card_models/active_appointment_card_model.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class ActiveAppointmentService {

  Future<List<dynamic>> fetchActiveAppointments({
    required OdooClient client,
    required int userId,
  }) async {
    // Step 1: Fetch booking lines assigned to this staff member.
    final bookingLines = await client.callKw({
      'model': 'appointment.booking.line',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [
          ['appointment_user_id', '=', userId],
          ['active', '=', true],
        ],
        'fields': [
          'id',
          'calendar_event_id',
          'appointment_user_id',
          'appointment_type_id',
          'event_start',
        ],
        'order': 'event_start asc',
      },
    });

    final lines = bookingLines as List<dynamic>;

    if (lines.isEmpty) {
      return [];
    }

    // Step 2: Collect linked calendar event IDs.
    final eventIds = lines
        .where((line) => line['calendar_event_id'] != false)
        .map<int>(
          (line) => line['calendar_event_id'][0] as int,
    )
        .toSet()
        .toList();

    if (eventIds.isEmpty) {
      return [];
    }

    final now = DateTime.now();

    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    final domain = [
      ['appointment_status', '=', 'booked'],
      ['appointment_type_id', '!=', false],
      ['start', '>=', _formatOdooDateTime(todayStart)],
      ['start', '<', _formatOdooDateTime(tomorrowStart)],
    ];

    // Step 3: Fetch booked appointment events.
    final events = await client.callKw({
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
          'partner_ids',
          'appointment_status',
          'appointment_type_id',
          'description',
        ],
        'order': 'start asc',
      },
    });

    final eventList = events as List<dynamic>;

    if (eventList.isEmpty) {
      return [];
    }

    // Step 4: Fetch client details and calculate duration.
    final List<Map<String, dynamic>> appointments = [];

    for (final event in eventList) {
      final eventMap = event as Map<String, dynamic>;

      final partnerIds = eventMap['partner_ids'] as List<dynamic>? ?? [];

      String clientName = 'Unknown Client';
      String? clientNote;

      if (partnerIds.isNotEmpty) {
        final partnerId = partnerIds.first as int;

        final partners = await client.callKw({
          'model': 'res.partner',
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': [
              ['id', '=', partnerId],
            ],
            'fields': [
              'id',
              'name',
              'comment',
            ],
          },
        });

        final partnerList = partners as List<dynamic>;

        if (partnerList.isNotEmpty) {
          final partner = partnerList.first as Map<String, dynamic>;

          clientName = partner['name'] ?? 'Unknown Client';

          final comment = partner['comment'];

          if (comment is String && comment.trim().isNotEmpty) {
            clientNote = comment;
          }
        }
      }

      final start = DateTime.parse(
        '${(eventMap['start'] as String).replaceFirst(' ', 'T')}Z',
      );

      final stop = DateTime.parse(
        '${(eventMap['stop'] as String).replaceFirst(' ', 'T')}Z',
      );

      final durationMinutes = stop.difference(start).inMinutes;

      appointments.add({
        ...eventMap,
        'client_name': clientName,
        'client_note': clientNote,
        'duration_minutes': durationMinutes,
      });
    }

    return appointments;
  }

  List<ActiveAppointmentModel> mapActiveAppointments(
      List<dynamic> appointments,
      ) {
    return appointments.map((appointment) {
      final data = appointment as Map<String, dynamic>;

      final appointmentType =
          data['appointment_type_id'] as List<dynamic>? ?? [];

      final start = DateTime.parse(
        '${(data['start'] as String).replaceFirst(' ', 'T')}Z',
      );

      return ActiveAppointmentModel(
        id: data['id'] as int,
        clientName: data['client_name'] ?? 'Unknown Client',
        serviceName: appointmentType.length > 1
            ? appointmentType[1].toString()
            : 'Appointment',
        durationMinutes: data['duration_minutes'] as int? ?? 0,
        payout: 0.0, // We'll connect the actual payout field next.
        appointmentDateTime: start.toLocal().toString(),
        clientNote: data['client_note'] as String?,
      );
    }).toList();
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