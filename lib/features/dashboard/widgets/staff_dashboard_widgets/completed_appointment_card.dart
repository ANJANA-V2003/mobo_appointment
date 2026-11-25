
import 'package:flutter/material.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';

class CompletedAppointmentCard extends StatelessWidget {
  final String clientName;
  final String serviceName;
  final int durationMinutes;
  final double payout;
  final String appointmentDateTime;
  final String roomName;

  final String? clientImage;
  final String? assignedBy;
  final String? clientNote;

  final VoidCallback? onViewDetails;

  const CompletedAppointmentCard({
    super.key,
    required this.clientName,
    required this.serviceName,
    required this.durationMinutes,
    required this.payout,
    required this.appointmentDateTime,
    required this.roomName,
    this.clientImage,
    this.assignedBy,
    this.clientNote,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = theme.textTheme.bodyLarge?.color;
    final secondaryTextColor =
        theme.textTheme.bodyMedium?.color;

    const completedColor = Color(0xFF16A34A);

    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        top: 10,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Completed status and payout
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF163B27)
                        : const Color(0xFFE3F8E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 13,
                        color: completedColor,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: completedColor,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${payout.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: completedColor,
                      ),
                    ),
                    Text(
                      'earned',
                      style: TextStyle(
                        fontSize: 10,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Client details
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                  clientImage != null &&
                      clientImage!.isNotEmpty
                      ? NetworkImage(clientImage!)
                      : null,
                  child: clientImage == null ||
                      clientImage!.isEmpty
                      ? Icon(
                    Icons.person,
                    color: Colors.grey.shade600,
                  )
                      : null,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        clientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '$serviceName • ${durationMinutes}m',
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Appointment information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey.shade900
                    : const Color(0xFFF2F3F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: completedColor,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          appointmentDateTime,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.meeting_room_outlined,
                        size: 15,
                        color: secondaryTextColor,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          roomName,
                          style: TextStyle(
                            fontSize: 11,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (assignedBy != null) ...[
                    const SizedBox(height: 8),

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 15,
                          color: secondaryTextColor,
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            'Assigned by: $assignedBy',
                            style: TextStyle(
                              fontSize: 11,
                              color: secondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Client note
            // if (clientNote != null &&
            //     clientNote!.isNotEmpty) ...[
            //   const SizedBox(height: 10),
            //
            //   Container(
            //     width: double.infinity,
            //     padding: const EdgeInsets.all(10),
            //     decoration: BoxDecoration(
            //       color: isDark
            //           ? Colors.grey.shade900
            //           : const Color(0xFFF0F8F2),
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     child: Row(
            //       crossAxisAlignment:
            //       CrossAxisAlignment.start,
            //       children: [
            //         const Icon(
            //           Icons.chat_bubble_outline,
            //           size: 15,
            //           color: completedColor,
            //         ),
            //
            //         const SizedBox(width: 8),
            //
            //         Expanded(
            //           child: Text(
            //             clientNote!,
            //             style: TextStyle(
            //               fontSize: 11,
            //               fontStyle: FontStyle.italic,
            //               color: textColor,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ],

            const SizedBox(height: 14),

            // View details button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: onViewDetails,
                style: OutlinedButton.styleFrom(
                  foregroundColor: completedColor,
                  side: const BorderSide(
                    color: completedColor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(25),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
