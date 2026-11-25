class ResourceModel {
  final int id;
  final String name;
  final int? companyId;
  final String? companyName;
  final bool active;
  //



  final int? calendarId;
  final String? calendarName;

  final String? timezone;

  ResourceModel({
    required this.id,
    required this.name,
    this.companyId,
    this.companyName,
    required this.active,
    //
    this.calendarId,
    this.calendarName,
    this.timezone,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    // final user = json['user_id'];
    final calendar = json['calendar_id'];
    return ResourceModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      companyId: _getRelationId(json['company_id']),
      companyName: _getRelationName(json['company_id']),
      active: json['active'] ?? true,
      // changes made

      calendarId: _getRelationId(calendar),
      calendarName: _getRelationName(calendar),

      timezone: json['tz']?.toString(),

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
