class AppointmentTypeModel {
  final int id;
  final String name;
  final double duration;
  final String? location;
  final String? scheduleBasedOn;
  final String? assignmentMethod;
  final bool active;
  final List<int> resourceIds;

  AppointmentTypeModel({
    required this.id,
    required this.name,
    required this.duration,
    this.location,
    this.scheduleBasedOn,
    this.assignmentMethod,
    required this.active,
    required this.resourceIds,
  });

  factory AppointmentTypeModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AppointmentTypeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      duration:
      (json['appointment_duration'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] ?? '',
      scheduleBasedOn: json['schedule_based_on'],
      assignmentMethod: json['assignment_method'],
      active: json['active'] ?? true,
      resourceIds: _getIdList(json['resource_ids']),
    );
  }

  static List<int> _getIdList(dynamic value) {
    if (value is List) {
      return value.whereType<int>().toList();
    }
    return [];
  }
}