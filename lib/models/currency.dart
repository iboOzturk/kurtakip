enum AssetType {
  currency,
  gold,
}

class Currency {
  final String code;
  final String name;
  final double amount;
  final double currentRate;
  final double initialRate;
  final DateTime addedDate;
  final AssetType type;

  Currency({
    required this.code,
    required this.name,
    required this.amount,
    required this.currentRate,
    double? initialRate,
    DateTime? addedDate,
    this.type = AssetType.currency,
  })  : initialRate = initialRate ?? currentRate,
        addedDate = addedDate ?? DateTime.now();

  double get totalValueInTRY => amount * currentRate;
  double get initialValueInTRY => amount * initialRate;
  
  double get profitLoss => totalValueInTRY - initialValueInTRY;
  
  double get profitLossPercentage => 
      ((currentRate - initialRate) / initialRate) * 100;

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'amount': amount,
      'currentRate': currentRate,
      'initialRate': initialRate,
      'addedDate': addedDate.toIso8601String(),
      'type': type.toString(),
    };
  }

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'],
      name: json['name'],
      amount: json['amount'],
      currentRate: json['currentRate'],
      initialRate: json['initialRate'],
      addedDate: DateTime.parse(json['addedDate']),
      type: AssetType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AssetType.currency,
      ),
    );
  }
} 