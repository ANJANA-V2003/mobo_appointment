import 'package:mobo_appointment_project/features/appointments/models/event_model.dart';

class NoShowModel {
  static double calculateRate(List<EventModel> events) {
    final completedAppointments = events.where((event) {
      return event.appointmentStatus == 'booked' ||
          event.appointmentStatus == 'no_show';
    }).toList();

    if (completedAppointments.isEmpty) {
      return 0.0;
    }

    final noShowAppointments = completedAppointments.where((event) {
      return event.appointmentStatus == 'no_show';
    }).length;

    return (noShowAppointments / completedAppointments.length) * 100;
  }
}