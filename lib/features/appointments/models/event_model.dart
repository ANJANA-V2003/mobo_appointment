import 'package:mobo_appointment_project/features/appointments/widgets/odoo_date_time.dart';

class EventModel {
  final int id;
  final String name;
  final DateTime? start;
  final DateTime? stop;
  final bool allDay;
  final double duration;
  final String? description;
  final String? location;

  // Organizer
  final int? organizerId;  // both are from user_id
  final String? organizerName;

  // Related records
  final List<int> partnerIds; //contains records from res.partner
  final List<int> attendeeIds; // contains the records from calendar.attendees
  final int? appointmentTypeId;
  final List<int> resourceIds;

  final bool active;

  EventModel({
    required this.id,
    required this.name,
    this.start,
    this.stop,
    required this.allDay,
    required this.duration,
    this.description,
    this.location,
    this.organizerId,
    this.organizerName,
    required this.partnerIds,
    required this.attendeeIds,
    this.appointmentTypeId,
    required this.resourceIds,
    required this.active,
  });

  factory EventModel.fromJson(Map<String, dynamic> json, String timezone) {
    return EventModel(
      // id: json['id'] ?? 0,
      // name: json['name'] ?? '', changed

      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',

      // Convert UTC dates into the user's timezone.
      start: OdooDateTime.convertToUserTimezone(json['start'], timezone),
      stop: OdooDateTime.convertToUserTimezone(json['stop'], timezone),

      allDay: json['allday'] == true, // changed
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString(),
      location: json['location']?.toString(),

      organizerId: _getRelationId(json['user_id']),
      organizerName: _getRelationName(json['user_id']),

      partnerIds: _getIdList(json['partner_ids']),
      attendeeIds: _getIdList(json['attendee_ids']),

      appointmentTypeId: _getRelationId(json['appointment_type_id']),

      resourceIds: _getIdList(json['resource_ids']),

      active: json['active'] != false, // changed
    );
  }

  // Extract ID from a Many2one field.
  static int? _getRelationId(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value[0] is int ? value[0] as int : null;
    }
    return null;
  }

  // Extract display name from a Many2one field.
  static String? _getRelationName(dynamic value) {
    if (value is List && value.length > 1) {
      return value[1]?.toString();
    }
    return null;
  }

  // Extract IDs from Many2many or One2many fields.
  static List<int> _getIdList(dynamic value) {
    if (value is List) {
      return value.whereType<int>().toList();
    }
    return [];
  }
}
