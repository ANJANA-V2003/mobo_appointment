import 'package:flutter/material.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';

class StaffFilter extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onChanged;

  const StaffFilter({
    super.key,
    required this.selectedFilter,
    required this.onChanged,
  });

  static const Color primaryColor = Color(0xFFC03355);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Color(0xFFF1F2F4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption('All Staff', 'all', context),
          _buildOption('My Own', 'own', context),
        ],
      ),
    );
  }

  Widget _buildOption(String title, String value, BuildContext context) {
    final isSelected = selectedFilter == value;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: isDark
              ? isSelected
                    ? AppTheme.primaryColor
                    : Colors.transparent
              : isSelected
              ? Colors.white
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isDark
                    ? isSelected
                          ? Colors.white
                          : Colors.grey.shade600
                    : isSelected
                    ? AppTheme.primaryColor
                    : Colors.grey.shade600,
              ),
            ),

            if (value == 'all') ...[
              const SizedBox(width: 5),
              // Container(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: 5,
              //     vertical: 2,
              //   ),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFFCE8EE),
              //     borderRadius: BorderRadius.circular(5),
              //   ),
              //   child: const Text(
              //     '8',
              //     style: TextStyle(
              //       color: primaryColor,
              //       fontSize: 9,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // ),
            ],
          ],
        ),
      ),
    );
  }
}
