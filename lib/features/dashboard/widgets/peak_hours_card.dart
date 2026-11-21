import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';

class PeakHoursCard extends StatelessWidget {
  final String subtitle;
  final List<double> hourlyData; // e.g., 12 values from 9 AM to 8 PM
  final List<String> hourLabels; // e.g., ['9a', '10a', ..., '8p']

  const PeakHoursCard({
    super.key,
    this.subtitle = 'Busiest time is usually around 5:00 PM',
    required this.hourlyData,
    required this.hourLabels,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = hourlyData.reduce(max);
    final peakIndex = hourlyData.indexOf(maxVal);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.grey.shade900 : AppTheme.secondaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFFADBEB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Peak: ${hourLabels[peakIndex]}',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bar Chart Section
            SizedBox(
              height: 100,
              child: BarChart(
                BarChartData(
                  // maxY: maxVal * 1.2,
                  maxY: maxVal == 0
                      ? 1
                      : maxVal * 1.2, // Adds headroom above the tallest bar
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          // Show every 2nd or 3rd label to avoid crowding
                          if (index % 2 != 0 || index >= hourLabels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              hourLabels[index],
                              style: TextStyle(
                                fontSize: 10,
                                color: index == peakIndex
                                    ? AppTheme.primaryColor
                                    : Colors.grey[600],
                                fontWeight: index == peakIndex
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => Colors.black87,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${hourLabels[group.x]}\n${rod.toY.toInt()} visits',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  barGroups: List.generate(hourlyData.length, (index) {
                    final isPeak = index == peakIndex;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: hourlyData[index],
                          width: 14,
                          color: isPeak
                              ? AppTheme.primaryColor
                              : Color(0xffe1587b),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxVal * 1.2,
                            color: Color(0xFFFADBEB),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Text(
                  "Tap to view slots",
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedChevronRight,
                    size: 12,
                    color: AppTheme.primaryColor,
                    strokeWidth: 2,
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
