import 'package:flutter/material.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/dashboard_date_filter.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/dashboard_header.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/no_show_card.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/staff_filter.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/time_frame_selector.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/utilization_card.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  String _selectedStaffFilter = 'all';
  DateTimeRange? _selectedDateRange;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardHeader(),

              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: StaffFilter(
                  selectedFilter: _selectedStaffFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedStaffFilter = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              TimeframeSelector(
                onDateChanged: (range) {
                  setState(() {
                    _selectedDateRange = range;
                  });

                  // Later, refresh dashboard analytics
                  // using this selected date range.
                },
              ),

              const SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: UtilizationCard(utilizationRate: 78.8),
                        ),
                      ),
                      const SizedBox(width: 4),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: NoShowCard(noShowRate: 30),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
