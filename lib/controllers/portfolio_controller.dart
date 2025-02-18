import 'package:get/get.dart';
import '../models/currency.dart';
import '../services/currency_service.dart';
import '../services/storage_service.dart';

class PortfolioController extends GetxController {
  final RxList<Currency> currencies = <Currency>[].obs;
  final RxDouble totalValue = 0.0.obs;
  final CurrencyService _currencyService = CurrencyService();
  final StorageService _storageService = Get.find<StorageService>();
  final RxBool hideValues = false.obs;

  @override
  void onInit() {
    super.onInit();
    hideValues.value = _storageService.getHideValues();
    _loadPortfolio();
    updateRates();
  }

  void _loadPortfolio() {
    final savedPortfolio = _storageService.loadPortfolio();
    currencies.assignAll(savedPortfolio);
    calculateTotal();
  }

  String formatNumber(double number) {
    List<String> parts = number.toStringAsFixed(2).split('.');
    parts[0] = parts[0].replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]}.');
    return '${parts[0]},${parts[1]}';
  }

  void addCurrency(Currency currency) {
    currencies.add(currency);
    _savePortfolio();
    calculateTotal();
  }

  void removeCurrency(int index) {
    currencies.removeAt(index);
    _savePortfolio();
    calculateTotal();
  }

  void updateCurrency(int index, Currency updatedCurrency) {
    currencies[index] = updatedCurrency;
    _savePortfolio();
    calculateTotal();
  }

  Future<void> _savePortfolio() async {
    await _storageService.savePortfolio(currencies.toList());
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
        final String apiKey = currency.type == AssetType.currency
            ? '${currency.code}TRY'
            : currency.code;
        
        if (rates.containsKey(apiKey)) {
          final newRate = double.tryParse(rates[apiKey]['alis'].toString());
          if (newRate != null) {
            currencies[i] = Currency(
              code: currency.code,
              name: currency.name,
              amount: currency.amount,
              currentRate: newRate,
              initialRate: currency.initialRate,
              addedDate: currency.addedDate,
              type: currency.type,
            );
          }
        }
      }
      
      calculateTotal();
      _savePortfolio();
    } catch (e) {
      print('Kurlar güncellenirken hata: $e');
    }
  }

  void toggleHideValues() {
    hideValues.value = !hideValues.value;
    _storageService.setHideValues(hideValues.value);
  }
} 