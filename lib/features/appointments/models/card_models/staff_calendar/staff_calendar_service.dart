import 'package:mobo_appointment_project/features/appointments/models/card_models/staff_calendar/staff_calendar_model.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class StaffCalendarService {
  Future<List<StaffCalendarModel>> fetchStaffCalendars({
    required OdooClient client,
  }) async {
    try {
      final result = await client.callKw({
        'model': 'res.users',
        'method': 'search_read',
        'args': [
          [
            ['share', '=', false],
            ['active', '=', true],
          ],
        ],
        'kwargs': {
          'fields': [
            'id',
            'name',
            'resource_ids',
            'resource_calendar_id',
            'employee',
          ],
        },
      });

      return (result as List)
          .map(
            (item) => StaffCalendarModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } catch (e) {
      print('Error fetching staff calendars: $e');
      rethrow;
    }
  }
}