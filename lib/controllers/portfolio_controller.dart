import 'package:get/get.dart';
import '../models/currency.dart';
import '../services/currency_service.dart';

class PortfolioController extends GetxController {
  final RxList<Currency> currencies = <Currency>[].obs;
  final RxDouble totalValue = 0.0.obs;
  final CurrencyService _currencyService = CurrencyService();

  @override
  void onInit() {
    super.onInit();
    updateRates();
  }

  void addCurrency(Currency currency) {
    currencies.add(currency);
    calculateTotal();
  }

  void removeCurrency(int index) {
    currencies.removeAt(index);
    calculateTotal();
  }

  void updateCurrency(int index, Currency updatedCurrency) {
    currencies[index] = updatedCurrency;
    calculateTotal();
  }

  void calculateTotal() {
    totalValue.value = currencies.fold(
      0,
      (sum, currency) => sum + currency.totalValueInTRY,
    );
  }

    Future<void> updateRates() async {
    try {
      final rates = await _currencyService.getLiveRates();
      
       for (int i = 0; i < currencies.length; i++) {
        final currency = currencies[i];
        final String apiKey = '${currency.code}TRY';
        
        if (rates.containsKey(apiKey)) {
          final newRate = double.tryParse(rates[apiKey]['satis'].toString());
          if (newRate != null) {
             currencies[i] = Currency(
              code: currency.code,
              name: currency.name,
              amount: currency.amount,
              currentRate: newRate,
              initialRate: currency.initialRate,
              addedDate: currency.addedDate,
            );
          }
        }
      }
      
       calculateTotal();
    } catch (e) {
      print('Kurlar güncellenirken hata: $e');
    }
  }
} 