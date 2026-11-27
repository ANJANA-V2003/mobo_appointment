import 'package:flutter/material.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

import '../models/appointment_booking_model.dart';
import '../services/appointment_booking_service.dart';

class AppointmentBookingProvider extends ChangeNotifier {
  final AppointmentBookingService _service = AppointmentBookingService();

  List<AppointmentBookingModel> _bookings = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<AppointmentBookingModel> get bookings => _bookings;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<void> fetchBookings({
    required OdooClient client,
    required DateTime startDate,
    required DateTime endDate,
    int? staffId,
    bool isManager = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // 1. Fetch booking lines
      final bookingLines = await _service.fetchBookingLines(
        client: client,
        startDate: startDate,
        endDate: endDate,
        staffId: staffId,
        isManager: isManager,
      );

      // 2. Get calendar event IDs
      final eventIds = bookingLines
          .map((booking) => _many2oneId(booking['calendar_event_id']))
          .whereType<int>()
          .toSet()
          .toList();
      // 3. Fetch calendar events
      final events = await _service.fetchCalendarEvents(
        client: client,
        eventIds: eventIds,
      );

      final eventMap = {for (final event in events) event['id'] as int: event};
      // 4. Get customer partner IDs
      final partnerIds = <int>{};

      for (final event in events) {
        final partners = event['partner_ids'];

        if (partners is List) {
          partnerIds.addAll(partners.whereType<int>());
        }
      }

      // 5. Fetch customer details
      final partners = await _service.fetchPartners(
        client: client,
        partnerIds: partnerIds.toList(),
      );

      final partnerMap = {
        for (final partner in partners) partner['id'] as int: partner,
      };

      // 6. Convert data into booking models
      _bookings = bookingLines.map((booking) {
        final eventId = _many2oneId(booking['calendar_event_id']);
        final event = eventMap[eventId];

        final eventPartnerIds = event?['partner_ids'] as List? ?? [];

        final customerId = eventPartnerIds.isNotEmpty
            ? eventPartnerIds.first as int
            : null;

        final customer = customerId != null ? partnerMap[customerId] : null;

        final staff = booking['appointment_user_id'];
        final appointmentType = booking['appointment_type_id'];
        final resource = booking['appointment_resource_id'];

        final phone = customer?['phone']?.toString() ?? '';
        final mobile = customer?['mobile']?.toString() ?? '';

        return AppointmentBookingModel(
          id: booking['id'] as int,
          customerId: customerId,
          customerName: customer?['name'] ?? '',
          customerPhone: phone.isNotEmpty ? phone : mobile,
          customerEmail: customer?['email'] ?? '',
          appointmentTypeId: _many2oneId(appointmentType),
          appointmentTypeName: _many2oneName(appointmentType),
          staffId: _many2oneId(staff),
          staffName: _many2oneName(staff),
          resourceId: _many2oneId(resource),
          resourceName: _many2oneName(resource),
          startDateTime: _parseDateTime(booking['event_start']),
          endDateTime: _parseDateTime(booking['event_stop'] ?? event?['stop']),
          status: '',
        );
      }).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int? _many2oneId(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value[0] as int?;
    }

    if (value is int) {
      return value;
    }

    return null;
  }

  String _many2oneName(dynamic value) {
    if (value is List && value.length > 1) {
      return value[1]?.toString() ?? '';
    }

    return '';
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    var dateString = value.toString().replaceFirst(' ', 'T');

    // Odoo often returns UTC datetime without a timezone suffix.
    if (!dateString.endsWith('Z') &&
        !dateString.contains('+') &&
        !RegExp(r'-\d{2}:\d{2}$').hasMatch(dateString)) {
      dateString += 'Z';
    }

    return DateTime.tryParse(dateString)?.toLocal();
  }

  void clearBookings() {
    _bookings = [];
    _errorMessage = null;
    notifyListeners();
  }
}
