class AppointmentStatusCountsModel {
  final int activeCount;
  final int invitationsCount;
  final int completedCount;

  const AppointmentStatusCountsModel({
    this.activeCount = 0,
    this.invitationsCount = 0,
    this.completedCount = 0,
  });

  factory AppointmentStatusCountsModel.empty() {
    return const AppointmentStatusCountsModel();
  }
}