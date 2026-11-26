import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';

class PendingPaymentCard extends StatelessWidget {
  final int? pendingCount;
  final double? pendingAmount;
  final String currencySymbol;
  final VoidCallback? onTap;

  const PendingPaymentCard({
    super.key,
    this.pendingCount,
    this.pendingAmount,
    this.currencySymbol = '\$',
    // '₹',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final count = pendingCount ?? 0;
    final amount = pendingAmount ?? 0.0;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).cardColor : AppTheme.secondaryColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.15)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payments Pending',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(color: Colors.grey.shade400,borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedWallet01,
                      size: 15,
                      color:Colors.grey.shade600,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              '$currencySymbol${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              '$count ${count == 1 ? 'payment' : 'payments'} pending',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
