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
  int _selectedTab = 0;

  List completedAppointments = [];
  List invitation = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _refreshDashboard();
    });
  }

  Future<void> _refreshDashboard() async {
    await Future.wait([
      _fetchArrivingSoon(),
      _fetchUpNext(),
      _fetchMyLoad(),
      _fetchAppointmentCounts(),
      _fetchActiveAppointments(),
      _fetchInvitationRequests(),
      _fetchCompletedAppointments(),
    ]);
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
      client: authProvider.client!,
      timezone: 'Asia/Kolkata',
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
      client: client,
      userId: userId,
    );
  }

  Future<void> _fetchAppointmentCounts() async {
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
    );
  }

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

  Future<void> _fetchInvitationRequests() async {
    final authProvider = context.read<AuthProvider>();

    final client = authProvider.client;

    if (client == null) return;

    await context.read<StaffDashboardProvider>().fetchInvitationRequests(
      client: client,
    );
    // await _refreshDashboard();
  }

  Future<void> _fetchCompletedAppointments() async {
    final authProvider = context.read<AuthProvider>();
    final client = authProvider.client;

    if (client == null) return;

    await context.read<StaffDashboardProvider>().fetchCompletedAppointments(
      client: client,
    );
  }

  Widget buildAppointmentList() {
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

  @override
  Widget build(BuildContext context) {
    // Dummy data for changing the visibility of arriving soon

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
                          isLoading: provider.isUpNextLoading,
                          onTap: () {},
                        );
                      },
                    ),

                    const SizedBox(width: 15),

                    Consumer<StaffDashboardProvider>(
                      builder: (context, provider, child) {
                        final myLoad = provider.myLoad;
                        return MyLoadCard(
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
              Consumer<StaffDashboardProvider>(
                builder: (context, provider, child) {
                  final statusCount = provider.appointmentStatusCounts;
                  return AppointmentStatusTabs(
                    selectedIndex: _selectedTab,
                    activeCount: statusCount.activeCount,
                    completedCount: statusCount.completedCount,
                    invitationsCount: statusCount.invitationsCount,
                    onChanged: (int value) {
                      setState(() {
                        _selectedTab = value;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              buildAppointmentList(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvitations() {
    return Consumer<StaffDashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingInvitations) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.invitationError != null) {
          return Center(child: Text(provider.invitationError!));
        }

        final invitations = provider.invitationRequests;

        if (invitations.isEmpty) {
          return const Center(child: Text('No invitations for today'));
        }

        return Column(
          children: invitations.map((invitation) {
            return InvitationCard(
              clientName: invitation.clientName,
              serviceName: invitation.serviceName,
              durationMinutes: invitation.durationMinutes,
              appointmentDateTime: invitation.formattedDateTime,
              assignedBy: '',
              clientNote: invitation.clientNote,
              onAccept: () async {
                final authProvider = context.read<AuthProvider>();
                final dashboardProvider = context
                    .read<StaffDashboardProvider>();

                final client = authProvider.client;
                final userId = authProvider.session?.userId;

                if (client == null || userId == null) return;

                try {
                  await dashboardProvider.acceptInvitation(
                    client: client,
                    appointmentId: invitation.id,
                    userId: userId,
                  );

                  if (!context.mounted) return;

                  await _fetchAppointmentCounts();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment accepted')),
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not accept appointment'),
                    ),
                  );
                }
              },

              onDecline: () async {
                final authProvider = context.read<AuthProvider>();
                final dashboardProvider = context
                    .read<StaffDashboardProvider>();

                final client = authProvider.client;

                if (client == null) return;

                try {
                  await dashboardProvider.declineInvitation(
                    client: client,
                    appointmentId: invitation.id,
                  );

                  if (!context.mounted) return;

                  await _fetchAppointmentCounts();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invitation declined')),
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not decline invitation'),
                    ),
                  );
                }
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildActiveAppointments() {
    return Consumer<StaffDashboardProvider>(
      builder: (context, provider, child) {
        final appointments = provider.activeAppointments;

        if (appointments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: Text('No active appointments')),
          );
        }

        return Column(
          children: appointments.map((appointment) {
            return ActiveAppointmentCard(
              clientName: appointment.clientName,
              serviceName: appointment.serviceName,
              durationMinutes: appointment.durationMinutes,
              appointmentDateTime: appointment.appointmentDateTime,
              clientNote: appointment.clientNote,

              onViewDetails: () {
                // Navigate to appointment details
                // Use appointment.id here.
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCompletedAppointments() {
    return Consumer<StaffDashboardProvider>(
      builder: (context, provider, child) {
        final completed = provider.completedAppointments;

        if (completed.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: Text('No completed appointments')),
          );
        }

        return Column(
          children: completed.map((appointment) {
            return CompletedAppointmentCard(
              clientName: appointment.clientName,
              serviceName: appointment.serviceName,
              durationMinutes: appointment.durationMinutes,
              payout: 0.0,
              appointmentDateTime: appointment.appointmentDateTime,
              roomName: '',
              onViewDetails: () {
                            },
            );
          }).toList(),
        );
      },
    );
  }
}
