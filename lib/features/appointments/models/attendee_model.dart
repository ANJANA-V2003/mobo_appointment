class AttendeeModel {
  final int id;

  // Related event
  final int? eventId;
  final String? eventName;

  // Related contact
  final int? partnerId;
  final String? partnerName;

  final String? email;
  final String state;

  AttendeeModel({
    required this.id,
    this.eventId,
    this.eventName,
    this.partnerId,
    this.partnerName,
    this.email,
    required this.state,
  });

  factory AttendeeModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AttendeeModel(
      id: json['id'] ?? 0,

      eventId: _getRelationId(json['event_id']),
      eventName: _getRelationName(json['event_id']),

      partnerId: _getRelationId(json['partner_id']),
      partnerName: _getRelationName(json['partner_id']),

      email: json['email']?.toString(),
      state: json['state']?.toString() ?? '',
    );
  }

  static int? _getRelationId(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value[0] is int ? value[0] as int : null;
    }
    return null;
  }

  static String? _getRelationName(dynamic value) {
    if (value is List && value.length > 1) {
      return value[1]?.toString();
    }
    return null;
  }
}
