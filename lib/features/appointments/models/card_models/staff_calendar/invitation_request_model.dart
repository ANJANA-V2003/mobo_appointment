class InvitationRequestModel {
  final int id;
  final String clientName;
  final String serviceName;
  final int durationMinutes;
  final DateTime startDateTime;
  final String? clientNote;

  const InvitationRequestModel({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.durationMinutes,
    required this.startDateTime,
    this.clientNote,
  });

  factory InvitationRequestModel.fromOdoo(
      Map<String, dynamic> data,
      ) {
    final startString = data['start'] as String;

    // Odoo stores this datetime as UTC without a trailing Z.
    final startDateTime = DateTime.parse(
      '${startString.replaceFirst(' ', 'T')}Z',
    ).toLocal();

    final stopString = data['stop'] as String;
    final stopDateTime = DateTime.parse(
      '${stopString.replaceFirst(' ', 'T')}Z',
    ).toLocal();

    final appointmentType = data['appointment_type_id'];

    return InvitationRequestModel(
      id: data['id'] as int,
      clientName: data['client_name'] ?? 'Unknown Client',
      serviceName: appointmentType is List &&
          appointmentType.length > 1
          ? appointmentType[1].toString()
          : 'Appointment',
      durationMinutes: data['duration_minutes'] ??
          stopDateTime.difference(startDateTime).inMinutes,
      startDateTime: startDateTime,
      clientNote: data['client_note'],
    );
  }

  String get formattedDateTime {
    final date = startDateTime;
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return '${date.day} ${months[date.month - 1]}, '
        '$hour:$minute $period';
  }
}