import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';

class formula_card extends StatelessWidget {
  const formula_card({super.key, required this.formula});
  final String formula;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
          border: Border.all(color: AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Formula : ",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    size: 10,
                    strokeWidth: 2,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2, top: 4),
                child: Text(
                  formula,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
