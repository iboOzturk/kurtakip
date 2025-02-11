import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String apiUrl = 'https://canlipiyasalar.haremaltin.com/tmp/altin.json?dil_kodu=tr';

  Future<Map<String, dynamic>> getLiveRates() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to load currency rates');
    } catch (e) {
      throw Exception('Failed to load currency rates: $e');
    }
  }
} 