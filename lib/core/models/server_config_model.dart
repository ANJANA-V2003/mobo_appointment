class ServerConfigModel {
  final String protocol;
  final String url;
  final String? database;

  ServerConfigModel({
    required this.protocol,
    required this.url,
    this.database
  });

  String get fullUrl => '$protocol$url';
}
