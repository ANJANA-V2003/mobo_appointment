import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';

enum DashboardDateRange { today, week, month, custom }

class DashboardDateFilter extends StatefulWidget {
  final DashboardDateRange initialRange;
  final void Function(DashboardDateRange range, DateTimeRange dateRange)
  onChanged;

  const DashboardDateFilter({
    super.key,
    this.initialRange = DashboardDateRange.week,
    required this.onChanged,
  });

  @override
  State<DashboardDateFilter> createState() => _DashboardDateFilterState();
}

class _DashboardDateFilterState extends State<DashboardDateFilter> {
  late DashboardDateRange _selectedRange;

  DateTimeRange? _customDateRange;

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.initialRange;
  }

  DateTimeRange _getDateRange(DashboardDateRange range) {
    final now = DateTime.now();
    switch (range) {
      case DashboardDateRange.today:
        final today = DateTime(now.year, now.month, now.day);
        return DateTimeRange(start: today, end: today);
      case DashboardDateRange.week:
        final today = DateTime(now.year, now.month, now.day);
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final endOfWeek = startOfWeek.add(Duration(days: 6));
        return DateTimeRange(start: startOfWeek, end: endOfWeek);

      case DashboardDateRange.month:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);

        return DateTimeRange(start: startOfMonth, end: endOfMonth);

      case DashboardDateRange.custom:
        return _customDateRange ?? DateTimeRange(start: now, end: now);
    }
  }

  Future<void> _selectRange(DashboardDateRange range) async {
    if (range == DashboardDateRange.custom) {
      final selectedDates = await showDialog<DateTimeRange>(
        context: context,
        builder: (context) {
          return _CustomDateRangeDialog(initialRange: _customDateRange);
        },
      );

      if (selectedDates == null) return;

      setState(() {
        _selectedRange = range;
        _customDateRange = selectedDates;
      });

      widget.onChanged(range, selectedDates);
      return;
    }

    final dateRange = _getDateRange(range);

    setState(() {
      _selectedRange = range;
    });

    widget.onChanged(range, dateRange);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<DashboardDateRange>(
        segments: const [
          ButtonSegment(value: DashboardDateRange.today, label: Text('Today')),
          ButtonSegment(value: DashboardDateRange.week, label: Text('Week')),
          ButtonSegment(value: DashboardDateRange.month, label: Text('Month')),
          ButtonSegment(
            value: DashboardDateRange.custom,
            label: Text('Custom'),
          ),
        ],
        selected: {_selectedRange},
        showSelectedIcon: false,
        onSelectionChanged: (selection) {
          _selectRange(selection.first);
        },
        style: SegmentedButton.styleFrom(
          textStyle: TextStyle(fontWeight: FontWeight.w500),
          shadowColor: Colors.black12,
          side: BorderSide(color: Colors.grey.shade200, width: 1),
          backgroundColor: Colors.grey.shade100,
          foregroundColor: Colors.black,
          selectedBackgroundColor: primaryColor,
          selectedForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(10),
          ),
        ),
        // ButtonStyle(
        //   visualDensity: VisualDensity.compact,
        //   padding: const WidgetStatePropertyAll(
        //     EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        //   ),
        //   textStyle: const WidgetStatePropertyAll(
        //     TextStyle(fontSize: 12, fontWeight: FontWeight.w600,color: Colors.white),
        //   ),
        //   backgroundColor: WidgetStateProperty.resolveWith((states) {
        //     if (states.contains(WidgetState.selected)) {
        //       return primaryColor;
        //     }
        //     return Colors.transparent;
        //   }),
        //   foregroundColor: WidgetStateProperty.resolveWith((states) {
        //     if (states.contains(WidgetState.selected)) {
        //       return Colors.white;
        //     }
        //     return Theme.of(context).colorScheme.onSurface;
        //   }),
        //   side: WidgetStatePropertyAll(
        //     BorderSide(color: Theme.of(context).dividerColor),
        //   ),
        //   shape: WidgetStatePropertyAll(
        //     RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        //   ),
        // ),
      ),
    );
  }
}

class _CustomDateRangeDialog extends StatefulWidget {
  final DateTimeRange? initialRange;

  const _CustomDateRangeDialog({this.initialRange});

  @override
  State<_CustomDateRangeDialog> createState() => _CustomDateRangeDialogState();
}

class _CustomDateRangeDialogState extends State<_CustomDateRangeDialog> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _startDate = widget.initialRange?.start ?? now;
    _endDate = widget.initialRange?.end ?? now;
  }

  Future<void> _pickDate(bool isStartDate) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return;

    setState(() {
      if (isStartDate) {
        _startDate = selectedDate;

        if (_startDate.isAfter(_endDate)) {
          _endDate = _startDate;
        }
      } else {
        _endDate = selectedDate;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.secondaryColor,
      title: const Text(
        'Select The Date',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDateField('Start Date', _startDate, () => _pickDate(true)),
          const SizedBox(height: 16),
          _buildDateField('End Date', _endDate, () => _pickDate(false)),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(
                    context,
                    DateTimeRange(start: _startDate, end: _endDate),
                  );
                },
                child: const Text(
                  'Apply',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(String hint, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(fillColor:Colors.grey.shade200,filled: true,
          hintText: hint,
          suffixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child:  HugeIcon(icon: HugeIcons.strokeRoundedCalendar03,),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 2,color: Colors.grey.shade400),
          ),
        ),
        child: Text('${date.day}/${date.month}/${date.year}'),
      ),
    );
  }
}
