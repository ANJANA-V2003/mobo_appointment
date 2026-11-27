import 'package:flutter/material.dart';

import '../models/appointment_filter_model.dart';

class AppointmentFilterSheet extends StatefulWidget {
  final AppointmentFilterModel initialFilters;

  final List<AppointmentFilterOption> types;
  final List<AppointmentFilterOption> staff;
  final List<AppointmentFilterOption> resources;

  final ValueChanged<AppointmentFilterModel> onApply;

  const AppointmentFilterSheet({
    super.key,
    required this.initialFilters,
    required this.onApply,
    this.types = const [],
    this.staff = const [],
    this.resources = const [],
  });

  static const Color primaryColor = Color(0xFFC03355);

  @override
  State<AppointmentFilterSheet> createState() => _AppointmentFilterSheetState();
}

class _AppointmentFilterSheetState extends State<AppointmentFilterSheet> {
  late AppointmentFilterModel _filters;

  bool _showGroupBy = false;

  static const List<String> _statusOptions = [
    'Confirmed',
    'In Process',
    'Needs Action',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  void _toggleStatus(String status) {
    final updated = Set<String>.from(_filters.statuses);

    if (updated.contains(status)) {
      updated.remove(status);
    } else {
      updated.add(status);
    }

    setState(() {
      _filters = _filters.copyWith(statuses: updated);
    });
  }

  void _toggleOption({
    required int id,
    required Set<int> selected,
    required ValueChanged<Set<int>> onChanged,
  }) {
    final updated = Set<int>.from(selected);

    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }

    onChanged(updated);
  }

  Future<void> _selectDate({required bool isStart}) async {
    final initialDate = isStart
        ? _filters.startDate ?? DateTime.now()
        : _filters.endDate ?? _filters.startDate ?? DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppointmentFilterSheet.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return;

    setState(() {
      if (isStart) {
        _filters = _filters.copyWith(
          startDate: selectedDate,
          clearEndDate:
              _filters.endDate != null &&
              _filters.endDate!.isBefore(selectedDate),
        );
      } else {
        _filters = _filters.copyWith(endDate: selectedDate);
      }
    });
  }

  void _clearAll() {
    setState(() {
      _filters = AppointmentFilterModel.empty();
    });
  }

  void _apply() {
    widget.onApply(_filters);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.68,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(),
            _buildTabs(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: _showGroupBy
                    ? _buildGroupByContent()
                    : _buildFilterContent(),
              ),
            ),

            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: Container(
        width: 48,
        height: 5,
        decoration: BoxDecoration(
          color: const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Filter & Group By',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF191B35),
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFF94A3B8),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _buildTab(
            label: 'Filter',
            selected: !_showGroupBy,
            onTap: () {
              setState(() => _showGroupBy = false);
            },
          ),
          _buildTab(
            label: 'Group By',
            selected: _showGroupBy,
            onTap: () {
              setState(() => _showGroupBy = true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppointmentFilterSheet.primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Status'),
        const SizedBox(height: 12),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _statusOptions.map((status) {
            return _buildChoiceChip(
              label: status,
              selected: _filters.statuses.contains(status),
              onTap: () => _toggleStatus(status),
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        _buildSectionTitle('Date Range'),
        const SizedBox(height: 12),

        _buildDateField(
          label: _formatDate(_filters.startDate, 'Select start date'),
          onTap: () => _selectDate(isStart: true),
        ),

        const SizedBox(height: 12),

        _buildDateField(
          label: _formatDate(_filters.endDate, 'Select end date'),
          onTap: () => _selectDate(isStart: false),
        ),

        const SizedBox(height: 28),

        _buildOptionSection(
          title: 'Appointment Type',
          options: widget.types,
          selectedIds: _filters.typeIds,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(typeIds: value);
            });
          },
        ),

        _buildOptionSection(
          title: 'Staff',
          options: widget.staff,
          selectedIds: _filters.staffIds,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(staffIds: value);
            });
          },
        ),

        _buildOptionSection(
          title: 'Resource',
          options: widget.resources,
          selectedIds: _filters.resourceIds,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(resourceIds: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildGroupByContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Group appointments by'),
        const SizedBox(height: 12),

        RadioGroup<AppointmentGroupBy>(
          groupValue: _filters.groupBy,
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _filters = _filters.copyWith(groupBy: value);
            });
          },
          child: Column(
            children: AppointmentGroupBy.values.map((group) {
              return Material(
                color: Colors.transparent,
                child: RadioListTile<AppointmentGroupBy>(
                  value: group,
                  title: Text(
                    group.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                  activeColor: AppointmentFilterSheet.primaryColor,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionSection({
    required String title,
    required List<AppointmentFilterOption> options,
    required Set<int> selectedIds,
    required ValueChanged<Set<int>> onChanged,
  }) {
    if (options.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(title),
          const SizedBox(height: 12),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((option) {
              return _buildChoiceChip(
                label: option.name,
                selected: selectedIds.contains(option.id),
                onTap: () {
                  _toggleOption(
                    id: option.id,
                    selected: selectedIds,
                    onChanged: onChanged,
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF252A41),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFABFC7) : Colors.white,
          border: Border.all(
            color: selected
                ? AppointmentFilterSheet.primaryColor
                : const Color(0xFFDCE3EF),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected
                ? AppointmentFilterSheet.primaryColor
                : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8FA),
          border: Border.all(color: const Color(0xFFDCE3EF)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: Color(0xFF94A3B8),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: label.startsWith('Select')
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _clearAll,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 50),
                foregroundColor: AppointmentFilterSheet.primaryColor,
                side: const BorderSide(
                  color: AppointmentFilterSheet.primaryColor,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Clear All'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 50),
                backgroundColor: AppointmentFilterSheet.primaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date, String placeholder) {
    if (date == null) return placeholder;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}
