import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency.dart';

class StorageService {
  static const String _portfolioKey = 'portfolio';
  static const String _hideValuesKey = 'hide_values';
  static const String _favoriteRatesKey = 'favoriteRates';
  final SharedPreferences _prefs;


  StorageService(this._prefs);

  Future<void> setHideValues(bool hide) async {
    await _prefs.setBool(_hideValuesKey, hide);
  }

  bool getHideValues() {
    return _prefs.getBool(_hideValuesKey) ?? false;
  }

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

  Future<void> saveFavoriteRates(List<String> codes) async {
    await _prefs.setStringList(_favoriteRatesKey, codes);
  }

  List<String> getFavoriteRates() {
    return _prefs.getStringList(_favoriteRatesKey) ?? [];
  }
}