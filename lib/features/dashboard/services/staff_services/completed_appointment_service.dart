import 'package:odoo_rpc/odoo_rpc.dart';
class CompletedAppointmentService {
  Future<List<dynamic>> fetchCompletedAppointments({
    required OdooClient client,
  }) async {
    final nowUtc = DateTime.now().toUtc();

    String formatOdooDateTime(DateTime dateTime) {
      final utc = dateTime.toUtc();

      final year = utc.year.toString().padLeft(4, '0');
      final month = utc.month.toString().padLeft(2, '0');
      final day = utc.day.toString().padLeft(2, '0');
      final hour = utc.hour.toString().padLeft(2, '0');
      final minute = utc.minute.toString().padLeft(2, '0');
      final second = utc.second.toString().padLeft(2, '0');

      return '$year-$month-$day $hour:$minute:$second';
    }

    final now = DateTime.now();

    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));
    final result = await client.callKw({
      'model': 'calendar.event',
      'method': 'search_read',
      'args': [],
      'kwargs': {
        'domain': [
          ['appointment_status', '=', 'attended'],
          ['appointment_type_id', '!=', false],
          [
            'stop',
            '<=',
            formatOdooDateTime(nowUtc),
          ],
          ['start', '>=', _formatOdooDateTime(todayStart)],
          ['start', '<', _formatOdooDateTime(tomorrowStart)],
        ],
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
        'order': 'stop desc',
      },
    });

    final completedAppointments = <Map<String, dynamic>>[];

    for (final item in result) {
      final event = Map<String, dynamic>.from(item);

      final partnerIds =
      List<dynamic>.from(event['partner_ids'] ?? []);

      String clientName = 'Unknown Client';
      // String? clientNote;

      if (partnerIds.isNotEmpty) {
        final partnerResult = await client.callKw({
          'model': 'res.partner',
          'method': 'search_read',
          'args': [],
          'kwargs': {
            'domain': [
              ['id', '=', partnerIds.first],
            ],
            'fields': [
              'id',
              'name',
            ],
            'limit': 1,
          },
        });

        if (partnerResult.isNotEmpty) {
          final partner =
          Map<String, dynamic>.from(partnerResult.first);

          clientName = partner['name'] ?? 'Unknown Client';
          // clientNote = partner['comment'];
        }
      }

      final startString = event['start'] as String;
      final stopString = event['stop'] as String;

      final startDateTime = DateTime.parse(
        '${startString.replaceFirst(' ', 'T')}Z',
      );

      final stopDateTime = DateTime.parse(
        '${stopString.replaceFirst(' ', 'T')}Z',
      );

      event['client_name'] = clientName;
      // event['client_note'] = clientNote;
      event['duration_minutes'] =
          stopDateTime
              .difference(startDateTime)
              .inMinutes;

      completedAppointments.add(event);
    }

    return completedAppointments;
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