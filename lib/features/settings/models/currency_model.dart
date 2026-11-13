class CurrencyModel {
  final int id;
  final String name;
  final String fullName;
  final String symbol;


  CurrencyModel({
    required this.id,
    required this.name,
    required this.fullName,
    required this.symbol,

  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      id: json['id'],
      name: json['name'] ?? '',
      fullName: json['full_name'] ?? '',
      symbol: json['symbol'] ?? '',
    );
  }
}