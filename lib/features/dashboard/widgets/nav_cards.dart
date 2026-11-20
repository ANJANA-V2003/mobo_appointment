import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';

class nav_cards extends StatelessWidget {
  const nav_cards({
    super.key,
    required this.title,
    required this.subTitle,
    required this.icon,
  });

  final String title;
  final String subTitle;
  final dynamic icon;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 5, right: 10),
      child: Container(
        height: 80,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : AppTheme.secondaryColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xFFFADBEB),
                      //0xFFF8D0DB
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: icon,
                        color: AppTheme.primaryColor,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 2),
                        Text(
                          subTitle,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // HugeIcon(icon: HugeIcons.strokeRoundedChevronRight)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
