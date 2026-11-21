
class PeakHoursModel {
  final int hour;
  final int count;

  const PeakHoursModel({
    required this.hour,
    required this.count,
  });

  String get label {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour $period';
  }
}
