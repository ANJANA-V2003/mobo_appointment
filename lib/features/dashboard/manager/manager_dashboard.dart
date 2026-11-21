import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';
import 'package:mobo_appointment_project/features/appointments/models/card_models/booking_type_count_model.dart';
import 'package:mobo_appointment_project/features/appointments/providers/appointment_provider.dart';
import 'package:mobo_appointment_project/features/appointments/services/appointment_service.dart';
import 'package:mobo_appointment_project/features/appointments/widgets/appointment_speed_dial.dart';
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
import 'package:mobo_appointment_project/features/login/provider/auth_provider.dart';
import 'package:provider/provider.dart';

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
  final AppointmentService _appointmentService = AppointmentService();

  List<BookingTypeCountModel> _bookingTypes = [];

  bool _isLoadingBookingTypes = false;
  String? _bookingTypeError;

  bool? _canShowRevenue;

  Future<void> _loadBookingTypes() async {
    final authProvider = context.read<AuthProvider>();

    final client = authProvider.client;
    final userId = authProvider.session?.userId;

    if (client == null || userId == null) {
      return;
    }

    setState(() {
      _isLoadingBookingTypes = true;
      _bookingTypeError = null;
    });

    try {
      final selectedRange = _selectedDateRange;

      final now = DateTime.now();

      final startDate =
          selectedRange?.start ?? DateTime(now.year, now.month, now.day);

      final endDate =
          selectedRange?.end ?? DateTime(now.year, now.month, now.day);

      final result = await _appointmentService.fetchBookingTypeCounts(
        client: client,
        userId: userId,

        // Replace this with the timezone selected in your Settings provider.
        timezone: 'Asia/Kolkata',

        // All Staff means show all staff's bookings.
        // My Own means filter bookings for the logged-in user.
        isManager: _selectedStaffFilter == 'all',

        startDate: startDate,
        endDate: endDate,
      );

      if (!mounted) return;

      setState(() {
        _bookingTypes = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _bookingTypeError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBookingTypes = false;
        });
      }
    }
  }

  Future<void> _checkRevenueModules() async {
    final authProvider = context.read<AuthProvider>();
    final client = authProvider.client;

    if (client == null) return;

    try {
      final appointmentService = AppointmentService();

      final result = await appointmentService.areRevenueModulesInstalled(
        client,
      );

      if (!mounted) return;

      setState(() {
        _canShowRevenue = result;
      });
    } catch (e) {
      debugPrint('Revenue module check error: $e');

      if (!mounted) return;

      setState(() {
        _canShowRevenue = false;
      });
    }
  }

  Future<void> _loadPeakHours() async {
    final authProvider = context.read<AuthProvider>();
    final appointmentProvider = context.read<AppointmentProvider>();

    final client = authProvider.client;
    final userId = authProvider.session?.userId;

    if (client == null || userId == null) {
      return;
    }

    final selectedRange = _selectedDateRange;
    final now = DateTime.now();

    final startDate =
        selectedRange?.start ?? DateTime(now.year, now.month, now.day);

    final endDate =
        selectedRange?.end ?? DateTime(now.year, now.month, now.day);

    await appointmentProvider.fetchPeakHours(
      client: client,
      userId: userId,
      timezone: 'Asia/Kolkata',
      isManager: _selectedStaffFilter == 'all',
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<void> _loadQuickNavigationCounts() async {
    final authProvider = context.read<AuthProvider>();
    final appointmentProvider = context.read<AppointmentProvider>();

    final client = authProvider.client;

    if (client == null) return;

    await appointmentProvider.fetchQuickNavigationCounts(client: client);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadBookingTypes();
        _loadPeakHours();
        _loadQuickNavigationCounts();
        _checkRevenueModules();
      }
    });
  }

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

              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 8),
                    child: StaffFilter(
                      selectedFilter: _selectedStaffFilter,
                      onChanged: (value) {
                        setState(() {
                          _selectedStaffFilter = value;
                        });

                        _loadBookingTypes();
                        _loadPeakHours();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: TimeframeSelector(
                      onDateChanged: (range) {
                        setState(() {
                          _selectedDateRange = range;
                        });

                        _loadBookingTypes();
                        _loadPeakHours();
                      },
                    ),
                  ),
                ],
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
                        if (_canShowRevenue == true) ...[
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: RevenueCard(utilizationRate: 40),
                          ),
                        ],

                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: BookingByTypeCard(bookingTypes: _bookingTypes),
                        ),
                        const SizedBox(width: 15),
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

              Consumer<AppointmentProvider>(
                builder: (context, provider, child) {
                  String subtitle;

                  if (provider.isQuickCountsLoading) {
                    subtitle = 'Loading customers...';
                  } else if (provider.quickCountsError != null) {
                    subtitle = 'Unable to load customers';
                  } else {
                    subtitle = '${provider.customerCount} active profiles';
                  }

                  return nav_cards(
                    title: 'Customers',
                    subTitle: subtitle,
                    icon: HugeIcons.strokeRoundedUserMultiple03,
                    onTap: () {},
                  );
                },
              ),
              // nav_cards(
              //   title: 'Customers',
              //   subTitle: '384 active profiles . Contact cards',
              //   icon: HugeIcons.strokeRoundedUserMultiple03,
              //   onTap: () {},
              // ),
              SizedBox(height: 5),
              Consumer<AppointmentProvider>(
                builder: (context, provider, child) {
                  String subtitle;

                  if (provider.isQuickCountsLoading) {
                    subtitle = 'Loading appointment types...';
                  } else if (provider.quickCountsError != null) {
                    subtitle = 'Unable to load appointment types';
                  } else {
                    subtitle =
                        '${provider.appointmentTypeCount} active services';
                  }

                  return nav_cards(
                    title: 'Appointment types',
                    subTitle: subtitle,
                    icon: HugeIcons.strokeRoundedCalendarFold,
                    onTap: () {},
                  );
                },
              ),
              // nav_cards(
              //   title: 'Appointment types',
              //   subTitle: '14 billable service package',
              //   icon: HugeIcons.strokeRoundedCalendarFold,
              //   onTap: () {},
              // ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: title_widget(text: "Peak Hours"),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Consumer<AppointmentProvider>(
                  builder: (context, provider, child) {
                    if (provider.isPeakHoursLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (provider.peakHoursError != null) {
                      return TextButton(
                        onPressed: _loadPeakHours,
                        child: const Text('Failed to load Peak Hours. Retry'),
                      );
                    }
                    // can change the working hours here...
                    final businessHours = provider.peakHours
                        .where((item) => item.hour >= 8 && item.hour <= 20)
                        .toList();

                    if (businessHours.every((item) => item.count == 0)) {
                      return const Text('No appointment data available.');
                    }

                    final hourlyData = businessHours
                        .map((item) => item.count.toDouble())
                        .toList();

                    final hourLabels = businessHours
                        .map((item) => item.label)
                        .toList();

                    final peakIndex = hourlyData.indexOf(
                      hourlyData.reduce((a, b) => a > b ? a : b),
                    );

                    return PeakHoursCard(
                      subtitle: 'Busiest time: ${hourLabels[peakIndex]}',
                      hourlyData: hourlyData,
                      hourLabels: hourLabels,
                    );
                  },
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
      floatingActionButton: // use speed dial flutter
      // FloatingActionButton(
      //   onPressed: () {},
      //   backgroundColor: AppTheme.primaryColor,
      //   child: HugeIcon(
      //     icon: HugeIcons.strokeRoundedAdd01,
      //     color: Colors.white,
      //   ),
      // ),
      AppointmentSpeedDial(
        onCreateAppointment: () {
          // Open your Create Appointment screen
          // context.pushNamed('createAppointment');
        },

        onCreateCustomer: () {
          // Open your Create Customer screen
          // context.pushNamed('createCustomer');
        },

        onCreateAppointmentType: () {
          // Open your Appointment Type form
          // context.pushNamed('createAppointmentType');
        },
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,
    );
  }
}
