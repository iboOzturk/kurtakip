import 'package:get/get.dart';
import '../models/currency.dart';

class PortfolioController extends GetxController {
  final RxList<Currency> currencies = <Currency>[].obs;
  final RxDouble totalValue = 0.0.obs;

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
} 