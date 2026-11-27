import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mobo_appointment_project/features/appointments/models/appointment_booking_model.dart';
import 'package:mobo_appointment_project/features/appointments/models/appointment_filter_model.dart';
import 'package:mobo_appointment_project/features/appointments/providers/appointment_booking_provider.dart';
import 'package:mobo_appointment_project/features/appointments/widgets/appointment_card.dart';
import 'package:mobo_appointment_project/features/appointments/widgets/appointment_day_header.dart';
import 'package:mobo_appointment_project/features/appointments/widgets/appointment_filter_sheet.dart';
import 'package:mobo_appointment_project/features/appointments/widgets/appointment_search_bar.dart';
import 'package:mobo_appointment_project/features/appointments/widgets/appointment_staff_filter.dart';
import 'package:mobo_appointment_project/features/login/provider/auth_provider.dart';
import 'package:provider/provider.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final TextEditingController searchController = TextEditingController();
  String _selectedStaffFilter = 'all';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    final authProvider = context.read<AuthProvider>();
    final client = authProvider.client;
    final userId = authProvider.userId;
    final bookingProvider = context.read<AppointmentBookingProvider>();

    final today = DateTime.now();

    final startDate = DateTime(today.year, today.month, today.day);

    final endDate = DateTime(today.year, today.month, today.day, 23, 59, 59);

    if (client == null || userId == null) {
      return;
    }

    await bookingProvider.fetchBookings(
      client: client,
      startDate: startDate,
      endDate: endDate,
      staffId: userId,
      isManager: _selectedStaffFilter == 'all',
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;

    final minute = dateTime.minute.toString().padLeft(2, '0');

    final period = dateTime.hour >= 12 ? 'pm' : 'am';

    return '$hour:$minute $period';
  }

  void openAppointmentFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AppointmentFilterSheet(
          initialFilters: const AppointmentFilterModel(),
          onApply: (filters) {
            // Store the filters in your AppointmentProvider.
            // Then fetch appointments using the selected filters.
          },
        );
      },
    );
  }

  List<AppointmentBookingModel> _searchBookings(
    List<AppointmentBookingModel> bookings,
  ) {
    final query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return bookings;
    }

    return bookings.where((booking) {
      return booking.customerName.toLowerCase().contains(query) ||
          booking.customerPhone.toLowerCase().contains(query) ||
          booking.customerEmail.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<AppointmentBookingProvider>();
    final bookings = bookingProvider.bookings;
    final filteredBookings = _searchBookings(bookings);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: HugeIcon(icon: HugeIcons.strokeRoundedChevronLeft),
        ),
        title: Text(
          "Appointments",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: ScrollPhysics.alwaysScrollable(),
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SizedBox(height: 15),
              AppointmentSearchBar(
                controller: searchController,
                onChanged: (value) {
                  setState(() {});
                },
                onFilterTap: () => openAppointmentFilters(this.context),
              ),

              SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: AppointmentStaffFilter(
                      selectedFilter: _selectedStaffFilter,
                      onChanged: (value) {
                        setState(() {
                          _selectedStaffFilter = value;
                        });
                        _loadBookings();
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15),
              bookingProvider.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFC03355),
                        ),
                      ),
                    )
                  : filteredBookings.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(30),
                      child: Text(
                        searchController.text.isNotEmpty
                            ? 'No matching appointments found'
                            : 'No appointments found',
                      ),
                    )
                  : Column(
                      children: [
                        AppointmentDayHeader(
                          title: 'Today',
                          appointmentSummary:
                              '${filteredBookings.length} Appointments',
                          isToday: true,
                        ),
                        const SizedBox(height: 20),
                        ...filteredBookings.map(
                          (booking) => AppointmentCard(
                            clientName: booking.customerName,
                            clientEmail: booking.customerEmail,
                            clientPhone: booking.customerPhone,
                            appointmentTime:
                                '${_formatTime(booking.startDateTime)} - '
                                '${_formatTime(booking.endDateTime)}',
                            serviceName: booking.appointmentTypeName,
                          ),
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
