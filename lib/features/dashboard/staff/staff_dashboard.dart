import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_appointment_project/core/routing/app_routes.dart';
import 'package:mobo_appointment_project/core/theme/app_theme.dart';
import 'package:mobo_appointment_project/features/dashboard/providers/staff_dashboard_provider.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/dashboard_header.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/staff_dashboard_widgets/active_appointment_card.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/staff_dashboard_widgets/appointment_status_tabs.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/staff_dashboard_widgets/arriving_soon_card.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/staff_dashboard_widgets/completed_appointment_card.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/staff_dashboard_widgets/invitation_card.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/staff_dashboard_widgets/my_load_card.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/staff_dashboard_widgets/pending_payment_card.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/staff_dashboard_widgets/quick_action_button.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/staff_dashboard_widgets/up_next_card.dart';
import 'package:mobo_appointment_project/features/dashboard/widgets/title_widget.dart';
import 'package:mobo_appointment_project/features/login/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  int _selectedTab = 1;

  List completedAppointments = [];
  List invitation = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        _fetchArrivingSoon();
        _fetchUpNext();
        _fetchMyLoad();
        _fetchappointmentCounts();
        _fetchActiveAppointments();
      }
    });
  }

  Future<void> _fetchArrivingSoon() async {
    final authProvider = context.read<AuthProvider>();

    // Get these values from your existing AuthProvider / RoleProvider.
    final client = authProvider.client;
    final userId = authProvider.session?.userId;
    final isManager = false;
    final timezone = 'Asia/Kolkata';

    if (client == null || userId == null) {
      return;
    }
    await context.read<StaffDashboardProvider>().fetchArrivingSoon(
      client: client,
      userId: userId,
      isManager: isManager,
      timezone: timezone,
    );

    context.read<StaffDashboardProvider>().fetchUpNext(
      client: client,
      userId: userId,
      isManager: isManager,
      timezone: timezone,
    );
  }

  Future<void> _fetchUpNext() async {
    final authProvider = context.read<AuthProvider>();

    // Get these values from your existing AuthProvider / RoleProvider.
    final client = authProvider.client;
    final userId = authProvider.session?.userId;
    final isManager = false;
    final timezone = 'Asia/Kolkata';

    if (client == null || userId == null) {
      return;
    }
    context.read<StaffDashboardProvider>().fetchUpNext(
      client: client,
      userId: userId,
      isManager: isManager,
      timezone: timezone,
    );

    context.read<StaffDashboardProvider>().fetchWorkingHours(
      client: authProvider.client!, timezone: 'Asia/Kolkata',

    );

    context.read<StaffDashboardProvider>().fetchMyLoad(
      client: authProvider.client!,
      userId: authProvider.userId!,
      timezone: 'Asia/Kolkata',
    );
  }

  Future<void> _fetchMyLoad() async {
    final authProvider = context.read<AuthProvider>();

    // Get these values from your existing AuthProvider / RoleProvider.
    final client = authProvider.client;
    final userId = authProvider.session?.userId;
    final timezone = 'Asia/Kolkata';

    if (client == null || userId == null) {
      return;
    }

    context.read<StaffDashboardProvider>().fetchMyLoad(
      client: client,
      userId: userId,
      timezone: timezone,
    );

    context.read<StaffDashboardProvider>().fetchActiveAppointments(
      client:client,
      userId: userId,
    );
  }

  Future<void> _fetchappointmentCounts() async {
    final authProvider = context.read<AuthProvider>();

    // Get these values from your existing AuthProvider / RoleProvider.
    final client = authProvider.client;
    final userId = authProvider.session?.userId;


    if (client == null || userId == null) {
      return;
    }

    context.read<StaffDashboardProvider>().fetchAppointmentStatusCounts(
      client: authProvider.client!,
      userId: authProvider.userId!,
    );  }

  Future<void> _fetchActiveAppointments() async {
    final authProvider = context.read<AuthProvider>();

    final client = authProvider.client;
    final userId = authProvider.session?.userId;

    if (client == null || userId == null) {
      return;
    }

    await context.read<StaffDashboardProvider>().fetchActiveAppointments(
      client: client,
      userId: userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data for changing the visibility of arriving soon
    Widget _buildAppointmentList() {
      switch (_selectedTab) {
        case 0:
          return _buildActiveAppointments();

        case 1:
          return _buildInvitations();

        case 2:
          return _buildCompletedAppointments();

        default:
          return const SizedBox.shrink();
      }
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: ScrollPhysics.alwaysScrollable(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardHeader(
                description:
                    'Shift: 8:00 AM - 5:00 PM'
                    '\n6 Bookings today',
              ),

              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Expanded(
                      child: QuickActionButton(
                        backgroundColor: isDark
                            ? AppTheme.primaryColor
                            : Colors.black,
                        text: "New Booking",
                        icon: HugeIcons.strokeRoundedAddCircle,
                        onTap: () => context.pushNamed(AppRoutes.newBookings),
                        iconColor: Colors.white,
                        textColor: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: QuickActionButton(
                        backgroundColor: AppTheme.secondaryColor,
                        text: "Find Client",
                        icon: HugeIcons.strokeRoundedUserSearch01,
                        textColor: Colors.black,
                        iconColor: AppTheme.primaryColor,
                        onTap: () => context.pushNamed(AppRoutes.search),
                      ),
                    ),
                  ],
                ),
              ),

              title_widget(text: "Shift Updates"),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const AlwaysScrollableScrollPhysics(),
                child: Row(
                  children: [
                    const SizedBox(width: 15),

                    Consumer<StaffDashboardProvider>(
                      builder: (context, provider, child) {
                        final arrivingSoon = provider.arrivingSoon;

                        if (arrivingSoon.clientCount == 0) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: ArrivingSoonCard(
                            clientCount: arrivingSoon.clientCount,
                            minutesUntilNext: arrivingSoon.minutesUntilNext,
                            nextClientName: arrivingSoon.nextClientName,
                            onTap: () {},
                          ),
                        );
                      },
                    ),

                    Consumer<StaffDashboardProvider>(
                      builder: (context, provider, child) {
                        final upNext = provider.upNext;
                        return UpNextCard(
                          nextClientName: upNext.nextClientName,
                          nextAppointmentTime: upNext.nextAppointmentTime,
                          appointmentEndTime: upNext.appointmentEndTime,
                          onTap: () {},
                        );
                      },
                    ),

                    const SizedBox(width: 15),

                    Consumer<StaffDashboardProvider>(builder: (context, provider, child) {
                             final myLoad = provider.myLoad;
                             return   MyLoadCard(
                               appointmentCount: myLoad.appointmentCount,
                               availableHours: myLoad.availableHours,
                               bookedHours: myLoad.bookedHours,
                               onTap: () {},
                             );
                                        },

                    ),

                    const SizedBox(width: 15),
                    PendingPaymentCard(
                      currencySymbol: '\$',
                      pendingAmount: 700,
                      pendingCount: 4,
                    ),
                    const SizedBox(width: 15),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              title_widget(text: "Today's Appointments"),
              SizedBox(height: 10),
              Consumer<StaffDashboardProvider>(builder: (context, provider, child) {
                final statusCount = provider.appointmentStatusCounts;
               return AppointmentStatusTabs(
                  selectedIndex: _selectedTab,
                  activeCount:statusCount.activeCount,
                  completedCount: statusCount.completedCount,
                  invitationsCount:statusCount.invitationsCount,
                  onChanged: (int value) {
                    setState(() {
                      _selectedTab = value;
                    });
                  },
                );
                },
              ),

              const SizedBox(height: 16),

              _buildAppointmentList(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildInvitations() {
  //   // if (invitation.isEmpty) {
  //   //   return const Center(child: Text('No active appointments'));
  //   // }
  //
  //   return ListView.builder(
  //     itemCount: 6,
  //     // invitation.length,
  //     itemBuilder: (context, index) {
  //       final invitations = invitation[index];
  //
  //       return  InvitationCard(
  //           clientName: 'Sophia Taylor',
  //           serviceName: 'Hydration Glow Therapy',
  //           durationMinutes: 45,
  //           payout: 65,
  //           appointmentDateTime: 'Today, 3:30 PM',
  //           roomName: 'Room 3',
  //           label: '⚡ Urgent',
  //           assignedBy: 'Assigned By Manager (Sarah K.)',
  //           clientNote:
  //               'Client requested gentle serum due to sensitive skin. Arriving via Uber.',
  //           onAccept: () {
  //             // Accept invitation
  //           },
  //           onDecline: () {
  //             // Decline invitation
  //           },
  //
  //       );
  //       // Pass your appointment model fields here
  //     },
  //   );
  // }

  Widget _buildInvitations() {
    if (invitation.isEmpty) {
      return Column(
        children: List.generate(3, (index) {
          return InvitationCard(
            clientName: 'Sophia Taylor',
            serviceName: 'Hydration Glow Therapy',
            durationMinutes: 45,
            payout: 65,
            appointmentDateTime: 'Today, 3:30 PM',
            roomName: 'Room 3',
            label: '⚡ Urgent',
            assignedBy: 'Assigned By Manager (Sarah K.)',
            clientNote:
                'Client requested gentle serum due to sensitive skin. Arriving via Uber.',
            onAccept: () {
              // Accept invitation
            },
            onDecline: () {
              // Decline invitation
            },
          );
        }),
      );
    }

    return Column(
      children: invitation.map<Widget>((item) {
        // Replace with your invitation model fields
        return InvitationCard(
          clientName: 'Sophia Taylor',
          serviceName: 'Hydration Glow Therapy',
          durationMinutes: 45,
          payout: 65,
          appointmentDateTime: 'Today, 3:30 PM',
          roomName: 'Room 3',
        );
      }).toList(),
    );
  }

  Widget _buildActiveAppointments() {
    return Consumer<StaffDashboardProvider>(
      builder: (context, provider, child) {
        final appointments = provider.activeAppointments;

        if (appointments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(30),
            child: Center(
              child: Text('No active appointments'),
            ),
          );
        }

        return Column(
          children: appointments.map((appointment) {
            return ActiveAppointmentCard(
              clientName: appointment.clientName,
              serviceName: appointment.serviceName,
              durationMinutes: appointment.durationMinutes,
              payout: appointment.payout,
              appointmentDateTime: appointment.appointmentDateTime,
              clientImage: appointment.clientImage,
              clientNote: appointment.clientNote,

              onViewDetails: () {
                // Navigate to appointment details
                // Use appointment.id here.
              },

              onStart: () {
                // Start this appointment
                // Use appointment.id here.
              },
            );
          }).toList(),
        );
      },
    );
  }



  Widget _buildCompletedAppointments() {
    return Column(
      children: List.generate(3, (index) {
        return CompletedAppointmentCard(
          clientName: 'Sophia Taylor',
          serviceName: 'Hydration Glow Therapy',
          durationMinutes: 45,
          payout: 65,
          appointmentDateTime: 'Today, 11:30 AM',
          roomName: 'Room 3',
          assignedBy: 'Sarah Kim',
          clientNote: 'Client was happy with the treatment.',
          onViewDetails: () {
            // Navigate to appointment details
          },
        );
      }),
    );
  }
}
