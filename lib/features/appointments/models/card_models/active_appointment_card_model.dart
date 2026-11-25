class ActiveAppointmentModel {
  final int id;
  final String clientName;
  final String serviceName;
  final int durationMinutes;
  final double payout;
  final String appointmentDateTime;

  final String? clientImage;
  final String? assignedBy;
  final String? clientNote;

  const ActiveAppointmentModel({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.durationMinutes,
    required this.payout,
    required this.appointmentDateTime,
    this.clientImage,
    this.assignedBy,
    this.clientNote,
  });
}