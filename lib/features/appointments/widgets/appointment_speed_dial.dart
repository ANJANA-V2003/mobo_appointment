import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hugeicons/hugeicons.dart';

class AppointmentSpeedDial extends StatelessWidget {
  final VoidCallback onCreateAppointment;
  final VoidCallback onCreateCustomer;
  final VoidCallback onCreateAppointmentType;

  const AppointmentSpeedDial({
    super.key,
    required this.onCreateAppointment,
    required this.onCreateCustomer,
    required this.onCreateAppointmentType,
  });

  static const Color primaryColor = Color(0xFFC03355);

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.list,
      activeIcon: Icons.close,

      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      activeBackgroundColor: primaryColor,
      activeForegroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
      ),
      buttonSize: const Size(64, 64),
      childrenButtonSize: const Size(56, 56),

      elevation: 4,
      overlayOpacity: 0.35,
      overlayColor: Colors.black,

      direction: SpeedDialDirection.up,
      spacing: 10,
      spaceBetweenChildren: 12,

      children: [
        SpeedDialChild(
          child: const Icon(Icons.event_available),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          label: 'Create Appointment',
          labelStyle: const TextStyle(fontSize: 16, color: Colors.black87),
          labelBackgroundColor: Colors.white,
          onTap: onCreateAppointment,
        ),

        SpeedDialChild(
          child: const Icon(Icons.person_add_alt_1),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          label: 'Create Customer',
          labelStyle: const TextStyle(fontSize: 16, color: Colors.black87),
          labelBackgroundColor: Colors.white,
          onTap: onCreateCustomer,
        ),

        SpeedDialChild(
          child: const Icon(Icons.category_outlined),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          label: 'Create Appointment Type',
          labelStyle: const TextStyle(fontSize: 16, color: Colors.black87),
          labelBackgroundColor: Colors.white,
          onTap: onCreateAppointmentType,
        ),
      ],
    );
  }
}
