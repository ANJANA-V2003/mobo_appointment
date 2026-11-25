class StaffCalendarModel {
  final int userId;
  final String userName;
  final int? calendarId;
  final String? calendarName;
  final List<int> resourceIds;

  StaffCalendarModel({
    required this.userId,
    required this.userName,
    this.calendarId,
    this.calendarName,
    required this.resourceIds,
  });

  factory StaffCalendarModel.fromJson(Map<String, dynamic> json) {
    final calendar = json['resource_calendar_id'];
    final resources = json['resource_ids'];

    return StaffCalendarModel(
      userId: json['id'],
      userName: json['name'] ?? '',
      calendarId: calendar is List ? calendar[0] : null,
      calendarName: calendar is List ? calendar[1] : null,
      resourceIds: resources is List
          ? List<int>.from(resources)
          : [],
    );
  }
}