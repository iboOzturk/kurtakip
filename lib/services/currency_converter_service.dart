import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyConverterService {
  static const String apiUrl = 'https://canlipiyasalar.haremaltin.com/tmp/altin.json?dil_kodu=tr';

  Future<Map<String, double>> getAllRates() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['data'] as Map<String, dynamic>;
        Map<String, double> result = {};

        result['TRY'] = 1.0;

        rates.forEach((key, value) {
          if (key.endsWith('TRY')) {
            String currency = key.substring(0, key.length - 3);
            result[currency] = double.tryParse(value['satis'].toString()) ?? 0.0;
          }
        });
        
        return result;
      }
      throw Exception('Failed to load rates');
    } catch (e) {
      throw Exception('Failed to load rates: $e');
    }
  }

  double convert(double amount, double fromRate, double toRate) {
    if (toRate == 0) return 0;
    return amount * (fromRate / toRate);
  }
} 