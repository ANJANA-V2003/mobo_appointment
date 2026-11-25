import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/title_widget.dart';

enum DashboardTimeframe { today, week, month, custom }

class TimeframeSelector extends StatefulWidget {
  final ValueChanged<DateTimeRange> onDateChanged;

  const TimeframeSelector({super.key, required this.onDateChanged});

  @override
  State<TimeframeSelector> createState() => _TimeframeSelectorState();
}

class _TimeframeSelectorState extends State<TimeframeSelector> {
  static const Color primaryColor = Color(0xFFC03355);
  static const Color selectedColor = Color(0xFF292D32);

  DashboardTimeframe _selectedTimeframe = DashboardTimeframe.week;

  late DateTimeRange _selectedRange;

  @override
  void initState() {
    super.initState();

    // Default timeframe is current week
    _selectedRange = _getWeekRange(DateTime.now());
  }

  // Get today's date range
  DateTimeRange _getTodayRange(DateTime date) {
    final today = DateTime(date.year, date.month, date.day);

    return DateTimeRange(start: today, end: today);
  }

  // Get Monday to Sunday date range
  DateTimeRange _getWeekRange(DateTime date) {
    final currentDate = DateTime(date.year, date.month, date.day);

    final monday = currentDate.subtract(
      Duration(days: currentDate.weekday - 1),
    );

    final sunday = monday.add(const Duration(days: 6));

    return DateTimeRange(start: monday, end: sunday);
  }

  // Get first and last date of current month
  DateTimeRange _getMonthRange(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);

    final lastDay = DateTime(date.year, date.month + 1, 0);

    return DateTimeRange(start: firstDay, end: lastDay);
  }

  // Handle timeframe selection
  void _selectTimeframe(DashboardTimeframe timeframe) async {
    if (timeframe == DashboardTimeframe.custom) {
      await _showCustomDatePicker();
      return;
    }

    final now = DateTime.now();

    DateTimeRange range;

    switch (timeframe) {
      case DashboardTimeframe.today:
        range = _getTodayRange(now);
        break;

      case DashboardTimeframe.week:
        range = _getWeekRange(now);
        break;

      case DashboardTimeframe.month:
        range = _getMonthRange(now);
        break;

      case DashboardTimeframe.custom:
        return;
    }

    setState(() {
      _selectedTimeframe = timeframe;
      _selectedRange = range;
    });

    widget.onDateChanged(range);
  }

  // Open customized calendar
  Future<void> _showCustomDatePicker() async {
    List<DateTime?> selectedDates = [_selectedRange.start, _selectedRange.end];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final result = await showDialog<List<DateTime?>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              title: const Text(
                'Select Date Range',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              content: SizedBox(
                width: 320,
                child: CalendarDatePicker2WithActionButtons(
                  value: selectedDates,
                  config: CalendarDatePicker2WithActionButtonsConfig(
                    calendarType: CalendarDatePicker2Type.range,

                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),

                    firstDayOfWeek: 1,

                    controlsHeight: 42,
                    dayMaxWidth: 36,

                    selectedDayHighlightColor: primaryColor,
                    selectedRangeHighlightColor: const Color(0xFFF9E5EA),

                    centerAlignModePicker: true,

                    weekdayLabels: const [
                      'Mo',
                      'Tu',
                      'We',
                      'Th',
                      'Fr',
                      'Sa',
                      'Su',
                    ],

                    weekdayLabelTextStyle: TextStyle(
                      color: isDark ? Colors.grey : Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),

                    controlsTextStyle: TextStyle(
                      color: isDark ? Colors.grey : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),

                    dayTextStyle: const TextStyle(
                      // color: Colors.black87,
                      fontSize: 12,
                    ),

                    selectedDayTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),

                    selectedRangeDayTextStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),

                  onValueChanged: (dates) {
                    setDialogState(() {
                      selectedDates = dates;
                    });
                  },

                  onCancelTapped: () {
                    Navigator.pop(dialogContext);
                  },

                  onOkTapped: () {
                    if (selectedDates.isNotEmpty &&
                        selectedDates.first != null) {
                      Navigator.pop(dialogContext, selectedDates);
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null || result.isEmpty || result.first == null) {
      return;
    }

    final start = result.first!;
    final end = result.length > 1 && result[1] != null ? result[1]! : start;

    final range = DateTimeRange(
      start: start.isBefore(end) ? start : end,
      end: start.isBefore(end) ? end : start,
    );

    setState(() {
      _selectedTimeframe = DashboardTimeframe.custom;
      _selectedRange = range;
    });

    widget.onDateChanged(range);
  }

  // Format date range
  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}';
  }

  String _getDateRangeText() {
    final start = _selectedRange.start;
    final end = _selectedRange.end;

    if (start.year != end.year) {
      return '${_formatDate(start)}, ${start.year} – '
          '${_formatDate(end)}, ${end.year}';
    }

    if (start.month == end.month) {
      return '${_formatDate(start)} – ${end.day}';
    }

    return '${_formatDate(start)} – ${_formatDate(end)}';
  }

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCalendar03,
                  size: 13,
                  color: isDark ? Colors.white : primaryColor,
                ),
                const SizedBox(width: 5),
                Text(
                  _getDateRangeText(),
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: GoogleFonts.manrope().fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          //   ],
          // ),

          const SizedBox(height: 9),

          // Timeframe options
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : AppTheme.secondaryColor,
              borderRadius: BorderRadius.circular(9),
              boxShadow: [BoxShadow(blurRadius: 3, color: Colors.black12)],
            ),
            child: Row(
              children: [
                _buildOption('Today', DashboardTimeframe.today),
                _buildOption('Week', DashboardTimeframe.week),
                _buildOption('Month', DashboardTimeframe.month),
                _buildOption(
                  'Custom',
                  DashboardTimeframe.custom,
                  showIcon: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Individual timeframe option

  Widget _buildOption(
    String title,
    DashboardTimeframe timeframe, {
    bool showIcon = false,
  }) {
    final theme = Theme.of(context);
    // final colorScheme = theme.colorScheme;
    final isSelected = _selectedTimeframe == timeframe;
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => _selectTimeframe(timeframe),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? isDark
                      ? Colors.white
                      : Colors.black
                : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? isDark
                            ? Colors.black
                            : Colors.white
                      : isDark
                      ? Colors.grey
                      : Colors.black,
                ),
              ),

              // if (showIcon) ...[
              //   const SizedBox(width: 3),
              //   Icon(
              //     Icons.tune,
              //     size: 12,
              //     color: isSelected
              //         ? Colors.white
              //         : Colors.grey,
              //   ),
              // ],
            ],
          ),
        ),
      ),
    );
  }
}
