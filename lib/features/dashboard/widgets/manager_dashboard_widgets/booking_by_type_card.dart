import 'package:flutter/material.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/booking_type_count_model.dart';

// Booking type data for the card
class BookingTypeData {
  final String name;
  final int count;

  const BookingTypeData({required this.name, required this.count});
}

class BookingByTypeCard extends StatelessWidget {
  // final List<BookingTypeData> bookingTypes;
  final List<BookingTypeCountModel> bookingTypes;
  const BookingByTypeCard({super.key, required this.bookingTypes});

  // Different colors for each booking type
  static const List<Color> _bookingColors = [
    Color(0xFFC03355),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFF14B8A6),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final totalBookings = bookingTypes.fold<int>(
      0,
      (total, type) => total + type.count,
    );

    final validTypes = bookingTypes.where((type) => type.count > 0).toList();

    return Container(
      constraints: const BoxConstraints(minHeight: 160),
      width: 250,
      padding: const EdgeInsets.only(top: 15, bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bookings',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              '$totalBookings',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Multicolored stacked bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 8,
                child: totalBookings == 0
                    ? Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                      )
                    : Row(
                        children: [
                          for (int i = 0; i < validTypes.length; i++)
                            Expanded(
                              flex: validTypes[i].count,
                              child: Container(
                                color:
                                    _bookingColors[i % _bookingColors.length],
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                for (int i = 0; i < bookingTypes.length; i++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _bookingColors[i % _bookingColors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${bookingTypes[i].name} '
                        '${bookingTypes[i].count}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
