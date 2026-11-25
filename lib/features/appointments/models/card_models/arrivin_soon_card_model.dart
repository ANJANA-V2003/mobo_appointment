
class ArrivingSoonCardModel {
  final int clientCount;
  final String? nextClientName;
  final String? nextAppointmentTime;
  final int? minutesUntilNext;

  const ArrivingSoonCardModel({
    this.clientCount = 0,
    this.nextClientName,
    this.nextAppointmentTime,
    this.minutesUntilNext,
  });

  factory ArrivingSoonCardModel.empty() {
    return const ArrivingSoonCardModel();
  }
}
