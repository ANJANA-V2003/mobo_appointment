
enum AppointmentGroupBy {
  day,
  status,
  type,
  staff,
  resource,
}

extension AppointmentGroupByLabel on AppointmentGroupBy {
  String get label {
    switch (this) {
      case AppointmentGroupBy.day:
        return 'By Day';
      case AppointmentGroupBy.status:
        return 'By Status';
      case AppointmentGroupBy.type:
        return 'By Type';
      case AppointmentGroupBy.staff:
        return 'By Staff';
      case AppointmentGroupBy.resource:
        return 'By Resource';
    }
  }
}

class AppointmentFilterOption {
  final int id;
  final String name;

  const AppointmentFilterOption({
    required this.id,
    required this.name,
  });
}

class AppointmentFilterModel {
  final DateTime? startDate;
  final DateTime? endDate;

  final Set<String> statuses;
  final Set<int> typeIds;
  final Set<int> staffIds;
  final Set<int> resourceIds;

  final AppointmentGroupBy groupBy;

  const AppointmentFilterModel({
    this.startDate,
    this.endDate,
    this.statuses = const {},
    this.typeIds = const {},
    this.staffIds = const {},
    this.resourceIds = const {},
    this.groupBy = AppointmentGroupBy.day,
  });

  AppointmentFilterModel copyWith({
    DateTime? startDate,
    DateTime? endDate,
    bool clearStartDate = false,
    bool clearEndDate = false,
    Set<String>? statuses,
    Set<int>? typeIds,
    Set<int>? staffIds,
    Set<int>? resourceIds,
    AppointmentGroupBy? groupBy,
  }) {
    return AppointmentFilterModel(
      startDate: clearStartDate ? null : startDate ?? this.startDate,
      endDate: clearEndDate ? null : endDate ?? this.endDate,
      statuses: statuses ?? this.statuses,
      typeIds: typeIds ?? this.typeIds,
      staffIds: staffIds ?? this.staffIds,
      resourceIds: resourceIds ?? this.resourceIds,
      groupBy: groupBy ?? this.groupBy,
    );
  }

  factory AppointmentFilterModel.empty() {
    return const AppointmentFilterModel();
  }
}
