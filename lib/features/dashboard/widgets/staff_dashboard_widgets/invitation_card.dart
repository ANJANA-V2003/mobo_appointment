import 'package:flutter/material.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';

class InvitationCard extends StatelessWidget {
  final String clientName;
  final String serviceName;
  final int durationMinutes;
  final double payout;
  final String appointmentDateTime;
  final String roomName;

  final String? clientImage;
  final String? label; // Urgent, VIP Client
  final String? assignedBy;
  final String? requestSource;
  final String? clientNote;

  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const InvitationCard({
    super.key,
    required this.clientName,
    required this.serviceName,
    required this.durationMinutes,
    required this.payout,
    required this.appointmentDateTime,
    required this.roomName,
    this.clientImage,
    this.label,
    this.assignedBy,
    this.requestSource,
    this.clientNote,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
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
            // Client details and payout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: clientImage != null
                      ? NetworkImage(clientImage!)
                      : null,
                  child: clientImage == null
                      ? Icon(Icons.person, color: Colors.grey.shade600)
                      : null,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 5,
                        children: [
                          Text(
                            clientName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          // if (label != null)
                          //   Container(
                          //     padding: const EdgeInsets.symmetric(
                          //       horizontal: 6,
                          //       vertical: 3,
                          //     ),
                          //     decoration: BoxDecoration(
                          //       color: label!.toLowerCase().contains('urgent')
                          //           ? const Color(0xFFFFF3D6)
                          //           : const Color(0xFFFCE4EC),
                          //       borderRadius: BorderRadius.circular(8),
                          //     ),
                          //     child: Text(
                          //       label!,
                          //       style: TextStyle(
                          //         fontSize: 9,
                          //         fontWeight: FontWeight.w700,
                          //         color: label!.toLowerCase().contains('urgent')
                          //             ? Colors.orange.shade800
                          //             : AppTheme.primaryColor,
                          //       ),
                          //     ),
                          //   ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '$serviceName • ${durationMinutes}m',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.end,
                //   children: [
                //     Text(
                //       '₹${payout.toStringAsFixed(2)}',
                //       style: TextStyle(
                //         fontSize: 18,
                //         fontWeight: FontWeight.w800,
                //         color: AppTheme.primaryColor,
                //       ),
                //     ),
                //     Text(
                //       'est. payout',
                //       style: TextStyle(fontSize: 10, color: secondaryTextColor),
                //     ),
                //   ],
                // ),
              ],
            ),

            const SizedBox(height: 14),

            // Appointment information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : const Color(0xFFF2F3F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          '$appointmentDateTime ($roomName)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (assignedBy != null) ...[
                    const SizedBox(height: 8),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.person_outline, size: 15),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            assignedBy!,
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (requestSource != null) ...[
                    const SizedBox(height: 8),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 15,
                          color: AppTheme.primaryColor,
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            requestSource!,
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // if (clientNote != null && clientNote!.isNotEmpty) ...[
                  //   const SizedBox(height: 8),
                  //
                  //   Row(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Icon(
                  //         Icons.chat_bubble_outline,
                  //         size: 15,
                  //
                  //       ),
                  //
                  //       const SizedBox(width: 8),
                  //
                  //       Expanded(
                  //         child: Text(
                  //           '"$clientNote"',
                  //           style: TextStyle(
                  //             fontSize: 11,
                  //             fontStyle: FontStyle.italic,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Accept and decline buttons
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 16),
                          SizedBox(width: 5),
                          Text(
                            'Accept Request',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 40,
                    child: TextButton(
                      onPressed: onDecline,
                      style: TextButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.grey.shade800
                            : const Color(0xFFF0F1F3),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Decline',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
