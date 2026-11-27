import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AppointmentCard extends StatelessWidget {
  final String clientName;
  final String appointmentTime;
  final String serviceName;
  final String? clientEmail;
  final String? clientPhone;
  final List<List<dynamic>> serviceIcon;
  final Color? serviceIconColor;
  final VoidCallback? onTap;
  final bool isLoading;

  const AppointmentCard({
    super.key,
    required this.clientName,
    required this.appointmentTime,
    required this.serviceName,
    this.serviceIcon = HugeIcons.strokeRoundedCalendar04,
    this.serviceIconColor,
    this.onTap,
    this.isLoading = false,
    this.clientEmail,
    this.clientPhone,
  });

  static const Color primaryColor = Color(0xFFC03355);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: Colors.grey.shade700) : null,
        ),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Client name and appointment time
              Row(
                children: [
                  Expanded(
                    child: Text(
                      clientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: Color(0xFF626775),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    appointmentTime,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              // Service icon and service name
              Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedMail01,
                    color: primaryColor,
                    size: 18,
                    strokeWidth: 2,
                  ),

                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      clientEmail ?? "null",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedPhoneCall,
                    color: primaryColor,
                    size: 18,
                    strokeWidth: 2,
                  ),

                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      clientPhone ?? "null",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Service icon and service name
              Row(
                children: [
                  HugeIcon(
                    icon: serviceIcon,
                    color: primaryColor,
                    size: 18,
                    strokeWidth: 2,
                  ),

                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      serviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
