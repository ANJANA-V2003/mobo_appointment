import 'package:flutter/material.dart';

class AppointmentDayHeader extends StatelessWidget {
  final String title;
  final String appointmentSummary;
  final bool isToday;

  const AppointmentDayHeader({
    super.key,
    required this.title,
    required this.appointmentSummary,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Day indicator
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isToday
                  ? const Color(0xFFC03355)
                  : const Color(0xFF626775),
            ),
          ),

          const SizedBox(width: 8),

          // Day title
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Appointment count and revenue
          Container(
            constraints: const BoxConstraints(maxWidth: 110),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8EA),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              appointmentSummary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF555963),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
