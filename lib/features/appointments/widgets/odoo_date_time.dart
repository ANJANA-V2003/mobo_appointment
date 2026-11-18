import 'package:timezone/timezone.dart' as tz;

class OdooDateTime {
  static DateTime? convertToUserTimezone(
      dynamic value,
      String timezone,
      ) {
    if (value == null || value == false || value.toString().isEmpty) {
      return null;
    }

    try {
      String dateString = value.toString().trim();

      // Odoo datetime format: yyyy-MM-dd HH:mm:ss
      dateString = dateString.replaceFirst(' ', 'T');

      // Odoo returns UTC without Z.
      // Explicitly mark it as UTC.
      if (!dateString.endsWith('Z') &&
          !RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(dateString)) {
        dateString += 'Z';
      }

      final utcDate = DateTime.parse(dateString).toUtc();

      final location = tz.getLocation(timezone);

      return tz.TZDateTime.from(utcDate, location);
    } catch (e) {
      // Invalid timezone or date.
      return null;
    }
  }
}