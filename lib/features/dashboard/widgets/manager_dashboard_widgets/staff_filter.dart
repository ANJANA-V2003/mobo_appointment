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
        color: isDark ? Colors.grey.shade900 : AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
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
                    ? Colors.white
                    : Colors.transparent
              : isSelected
              ? Colors.black
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
                          ? Colors.black
                          : Colors.grey.shade600
                    : isSelected
                    ? AppTheme.white
                    : Colors.grey.shade600,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
