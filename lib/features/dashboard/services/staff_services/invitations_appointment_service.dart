import 'package:odoo_rpc/odoo_rpc.dart';

class InvitationsAppointmentService {
  Future<List<dynamic>> fetchInvitationRequests({
    required OdooClient client,
  }) async {
    final now = DateTime.now();

    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    final domain = [
      ['appointment_status', '=', 'request'],
      ['appointment_type_id', '!=', false],
      ['start', '>=', _formatOdooDateTime(todayStart)],
      ['start', '<', _formatOdooDateTime(tomorrowStart)],
    ];
    // Step 1: Fetch appointment requests.
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
          'partner_ids',
          'appointment_status',
          'appointment_type_id',
          'appointment_invite_id',
          'description',
        ],
        'order': 'start asc',
      },
    });

    final events = result as List<dynamic>;

    if (events.isEmpty) {
      return [];
    }

    final List<Map<String, dynamic>> invitations = [];

    // Step 2: Fetch client details and calculate duration.
    for (final event in events) {
      final eventMap = event as Map<String, dynamic>;

      final partnerIds =
          eventMap['partner_ids'] as List<dynamic>? ?? [];

      String clientName = 'Unknown Client';
      String? clientNote;

      if (partnerIds.isNotEmpty) {
        final partnerId = partnerIds.first as int;

        final partnerResult = await client.callKw({
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

        final partners = partnerResult as List<dynamic>;

        if (partners.isNotEmpty) {
          final partner = partners.first as Map<String, dynamic>;

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

      invitations.add({
        ...eventMap,
        'client_name': clientName,
        'client_note': clientNote,
        'duration_minutes': stop.difference(start).inMinutes,
      });
    }

    return invitations;
  }


  Future<void> acceptInvitation({
    required OdooClient client,
    required int appointmentId,
  }) async {
    await client.callKw({
      'model': 'calendar.event',
      'method': 'action_set_appointment_booked',
      'args': [
        [appointmentId],
      ],
      'kwargs': {},
    });
  }

  Future<void> declineInvitation({
    required OdooClient client,
    required int appointmentId,
  }) async {
    await client.callKw({
      'model': 'calendar.event',
      'method': 'action_set_appointment_cancelled',
      'args': [
        [appointmentId],
      ],
      'kwargs': {},
    });
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