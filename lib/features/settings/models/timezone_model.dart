class TimezoneModel {
  final String name;
  final String displayName;

  TimezoneModel({
    required this.name,
    required this.displayName,
  });

  factory TimezoneModel.fromJson(List<dynamic> json) {
    return TimezoneModel(
      name: json[0],
      displayName: json[1],
    );
  }
}