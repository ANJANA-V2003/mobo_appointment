import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/booking_by_type_card.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/dashboard_date_filter.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/dashboard_header.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/formula_card.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/nav_cards.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/no_show_card.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/peak_hours_card.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/revenue_card.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/staff_filter.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/time_frame_selector.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/title_widget.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/utilization_card.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
  String _selectedStaffFilter = 'all';
  DateTimeRange? _selectedDateRange;

  bool util_formula = false;
  bool noShow_formula = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: ScrollPhysics.alwaysScrollable(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardHeader(),

              TimeframeSelector(
                onDateChanged: (range) {
                  setState(() {
                    _selectedDateRange = range;
                  });

                  // Later, refresh dashboard analytics
                  // using this selected date range.
                },
              ),
              SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: title_widget(text: 'Appointments Overview'),
              ),

              SingleChildScrollView(
                physics: ScrollPhysics.alwaysScrollable(),
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 7),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                util_formula = true;
                              });
                            },
                            child: UtilizationCard(utilizationRate: 78.4),
                          ),
                        ),

                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            setState(() {
                              noShow_formula = true;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: NoShowCard(noShowRate: 3.8),
                          ),
                        ),

                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: RevenueCard(utilizationRate: 40),
                        ),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: BookingByTypeCard(noShowRate: 68.9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (util_formula == true) ...[
                InkWell(
                  onTap: () {
                    setState(() {
                      util_formula = false;
                    });
                  },
                  child: formula_card(
                    formula:
                        "(Booked Appointment Hours / Available Staff Working Hours) * 100 % ",
                  ),
                ),
              ],

              if (noShow_formula == true) ...[
                InkWell(
                  onTap: () {
                    setState(() {
                      noShow_formula = false;
                    });
                  },
                  child: formula_card(
                    formula:
                        "(No-Show Appointments / Total Scheduled Appointments) * 100 % ",
                  ),
                ),
              ],

              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: title_widget(text: 'Quick Navigation'),
              ),
              SizedBox(height: 5),
              nav_cards(
                title: 'Customers',
                subTitle: '384 active profiles . Contact cards',
                icon: HugeIcons.strokeRoundedUserMultiple03,
              ),
              SizedBox(height: 5),
              nav_cards(
                title: 'Appointment types',
                subTitle: '14 billable service package',
                icon: HugeIcons.strokeRoundedCalendarFold,
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: title_widget(text: "Peak Hours"),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: PeakHoursCard(
                  hourlyData: [5, 18, 35, 42, 30, 25, 40, 50, 70],
                  hourLabels: [
                    '9am',
                    '10am',
                    '11am',
                    '12pm',
                    '1pm',
                    '2pm',
                    '3pm',
                    '4pm',
                    '5pm',
                  ],
                ),
              ),
              SizedBox(height: 20),
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
              const SizedBox(height: 8),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primaryColor,
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedAdd01,
          color: Colors.white,
        ),
      ),
    );
  }
}
