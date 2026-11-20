import 'package:flutter/material.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';

class RevenueCard extends StatelessWidget {
  final double utilizationRate;

  const RevenueCard({super.key, required this.utilizationRate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 160,
      width: 250,
      padding: const EdgeInsets.only(top: 15,bottom: 15),
      decoration: BoxDecoration(
        color: isDark?Colors.grey.shade900:AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Revenue', style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600)),
                Container(
                  height: 18,
                  width: 90,
                  decoration: BoxDecoration(
                    color: Color(0xffafcfbb),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "SALES LINKED",
                      style: TextStyle(
                        color: Color(0xff326c56),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              '\$ 12,450.00',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Text(
              '18 paid invoices . 96.2% collected',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Divider(),
          ),

          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  'Odoo synced',
                  style: TextStyle(fontSize: 10,),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Text(
                  'View ledger',
                  style: TextStyle(fontSize: 10, color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
