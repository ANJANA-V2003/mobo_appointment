import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AppointmentSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  const AppointmentSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: isDark ? Border.all(color: Colors.grey.shade700) : null,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.03)
                        : Colors.black12,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(fontSize: 13, color: Color(0xFF626775)),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedSearch01,
                      color: isDark ? Colors.grey.shade700 : Colors.black,
                    ),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: isDark ? Border.all(color: Colors.grey.shade700) : null,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.03)
                        : Colors.black12,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedFilter,
                    color: isDark ? Colors.grey.shade700 : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
