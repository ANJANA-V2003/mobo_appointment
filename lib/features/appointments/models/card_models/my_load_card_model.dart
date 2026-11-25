class MyLoadCardModel {
  final int appointmentCount;
  final double bookedHours;
  final double availableHours;

  const MyLoadCardModel({
    this.appointmentCount = 0,
    this.bookedHours = 0.0,
    this.availableHours = 0.0,
  });

  double get utilizationPercentage {
    if (availableHours <= 0) return 0;

    return (bookedHours / availableHours * 100).clamp(0, 100);
  }

  factory MyLoadCardModel.empty() {
    return const MyLoadCardModel();
  }
}