class DatabaseModel {
  final String name;

  DatabaseModel({
    required this.name,
  });

  factory DatabaseModel.fromJson(String json) {
    return DatabaseModel(name: json);
  }
}