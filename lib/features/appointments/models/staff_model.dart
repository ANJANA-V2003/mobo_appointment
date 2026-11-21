class StaffModel {
  final int id;
  final String name;
  final String? email;
  final String? timezone;
  final bool active;


  StaffModel({
    required this.id,
    required this.name,
    this.email,
    this.timezone,
    required this.active,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] is String
          ? json['email']
          : null,
      timezone: json['tz'] is String
          ? json['tz']
          : null,
      active: json['active'] ?? false,
    );
  }
}