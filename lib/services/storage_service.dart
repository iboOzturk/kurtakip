import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency.dart';

class StorageService {
  static const String _portfolioKey = 'portfolio';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<void> savePortfolio(List<Currency> portfolio) async {
    final List<String> encodedPortfolio = portfolio
        .map((currency) => jsonEncode(currency.toJson()))
        .toList();

    await _prefs.setStringList(_portfolioKey, encodedPortfolio);
  }

  List<Currency> loadPortfolio() {
    final List<String>? encodedPortfolio = _prefs.getStringList(_portfolioKey);

    if (encodedPortfolio == null) return [];

    return encodedPortfolio
        .map((item) => Currency.fromJson(jsonDecode(item)))
        .toList();
  }
}