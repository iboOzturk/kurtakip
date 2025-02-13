import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/currency_converter_service.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final _amountController = TextEditingController();
  final _currencyService = CurrencyConverterService();
  String _fromCurrency = 'USD';
  String _toCurrency = 'TRY';
  double? _result;
  bool _isLoading = false;
  Map<String, double> _rates = {};

  final Map<String, String> _currencyCodes = {
    'USD': 'Amerikan Doları',
    'EUR': 'Euro',
    'GBP': 'İngiliz Sterlini',
    'TRY': 'Türk Lirası',
  };

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _rates = await _currencyService.getAllRates();
      if (_amountController.text.isNotEmpty) {
        _convertCurrency();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _convertCurrency() {
    if (_amountController.text.isEmpty) return;
    
    final amount = double.tryParse(_amountController.text) ?? 0;
    final fromRate = _rates[_fromCurrency] ?? 0;
    final toRate = _rates[_toCurrency] ?? 0;
    
    setState(() {
      _result = _currencyService.convert(amount, fromRate, toRate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const Text('Kur Dönüştürücü'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRates,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.currency_exchange,
                    size: 48,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Döviz Hesaplama',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          hintText: "Miktarı giriniz",
                          labelText: 'Miktar',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.calculate),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        onChanged: (_) => _convertCurrency(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Kaynak'),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _fromCurrency,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: _currencyCodes.entries.map((entry) {
                                    return DropdownMenuItem(
                                      value: entry.key,
                                      child: Text(entry.key),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _fromCurrency = value!;
                                      _convertCurrency();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: IconButton(
                              icon: const Icon(Icons.swap_horiz),
                              onPressed: () {
                                setState(() {
                                  final temp = _fromCurrency;
                                  _fromCurrency = _toCurrency;
                                  _toCurrency = temp;
                                  _convertCurrency();
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Hedef'),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _toCurrency,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: _currencyCodes.entries.map((entry) {
                                    return DropdownMenuItem(
                                      value: entry.key,
                                      child: Text(entry.key),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _toCurrency = value!;
                                      _convertCurrency();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else if (_result != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Sonuç',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_amountController.text} $_fromCurrency = ${_result!.toStringAsFixed(2)} $_toCurrency',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (_rates.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '1 $_fromCurrency = ${(_rates[_fromCurrency]! / _rates[_toCurrency]!).toStringAsFixed(4)} $_toCurrency',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
} 