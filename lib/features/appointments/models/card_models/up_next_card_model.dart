class UpNextCardModel {
  final int clientCount;
  final String? nextClientName;
  final String? nextAppointmentTime;
  final String? appointmentEndTime;
  final int? minutesUntilNext;

  const UpNextCardModel({
    this.clientCount = 0,
    this.nextClientName,
    this.nextAppointmentTime,
    this.appointmentEndTime,
    this.minutesUntilNext,
  });

  factory UpNextCardModel.empty() {
    return const UpNextCardModel();
  }
}