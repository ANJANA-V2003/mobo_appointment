class AppointmentBookingModel {
  final int id;

  final int? customerId;
  final String customerName;
  final String customerPhone;
  final String customerEmail;

  final int? appointmentTypeId;
  final String appointmentTypeName;

  final int? staffId;
  final String staffName;

  final int? resourceId;
  final String resourceName;

  final DateTime? startDateTime;
  final DateTime? endDateTime;

  final String status;

  const AppointmentBookingModel({
    required this.id,
    this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    this.appointmentTypeId,
    required this.appointmentTypeName,
    this.staffId,
    required this.staffName,
    this.resourceId,
    required this.resourceName,
    this.startDateTime,
    this.endDateTime,
    required this.status,
  });

  factory AppointmentBookingModel.fromJson(Map<String, dynamic> json) {
    return AppointmentBookingModel(
      id: json['id'] ?? 0,
      customerId: json['customerId'],
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      appointmentTypeId: json['appointmentTypeId'],
      appointmentTypeName: json['appointmentTypeName'] ?? '',
      staffId: json['staffId'],
      staffName: json['staffName'] ?? '',
      resourceId: json['resourceId'],
      resourceName: json['resourceName'] ?? '',
      startDateTime: json['startDateTime'] != null
          ? DateTime.tryParse(json['startDateTime'])
          : null,
      endDateTime: json['endDateTime'] != null
          ? DateTime.tryParse(json['endDateTime'])
          : null,
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'appointmentTypeId': appointmentTypeId,
      'appointmentTypeName': appointmentTypeName,
      'staffId': staffId,
      'staffName': staffName,
      'resourceId': resourceId,
      'resourceName': resourceName,
      'startDateTime': startDateTime?.toIso8601String(),
      'endDateTime': endDateTime?.toIso8601String(),
      'status': status,
    };
  }
}
