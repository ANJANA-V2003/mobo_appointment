
import 'package:flutter/material.dart';

class AppointmentStatusTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  final int activeCount;
  final int invitationsCount;
  final int completedCount;

  const AppointmentStatusTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    this.activeCount = 0,
    this.invitationsCount = 0,
    this.completedCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tabs = [
      'Active ($activeCount)',
      'Invitations ($invitationsCount)',
      'Completed ($completedCount)',
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 15,right: 15),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = selectedIndex == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? Colors.white : const Color(0xFF191D1C))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    tabs[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? Colors.black : Colors.white)
                          : (isDark ? Colors.grey.shade400 : Colors.black87),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
