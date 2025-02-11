import 'package:flutter/material.dart';
import '../models/currency.dart';
import '../services/currency_service.dart';

class AddCurrencyScreen extends StatefulWidget {
  const AddCurrencyScreen({super.key});

  @override
  State<AddCurrencyScreen> createState() => _AddCurrencyScreenState();
}

class _AddCurrencyScreenState extends State<AddCurrencyScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCode = 'USD';
  final _amountController = TextEditingController();
  final _currencyService = CurrencyService();
  bool _isLoading = false;
  double? _currentRate;

  final Map<String, String> _currencyCodes = {
    'USD': 'Amerikan Doları',
    'EUR': 'Euro',
    'GBP': 'İngiliz Sterlini',
  };

  @override
  void initState() {
    super.initState();
    _fetchCurrentRate(_selectedCode);
  }

  Future<void> _fetchCurrentRate(String currencyCode) async {
    setState(() {
      _isLoading = true;
      _currentRate = null;
    });

    try {
      final rates = await _currencyService.getLiveRates();
      String apiKey = '${currencyCode}TRY';
      if (rates.containsKey(apiKey)) {
        setState(() {
          _currentRate = double.tryParse(rates[apiKey]['satis'].toString());
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kur bilgisi alınamadı')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Döviz Ekle'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCode,
                decoration: const InputDecoration(
                  labelText: 'Döviz Türü',
                ),
                items: _currencyCodes.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text('${entry.key} - ${entry.value}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCode = value!;
                  });
                  _fetchCurrentRate(value!);
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Miktar',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen miktar giriniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_currentRate != null)
                Text(
                  'Güncel Kur: ${_currentRate!.toStringAsFixed(4)} TL',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading || _currentRate == null
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          final currency = Currency(
                            code: _selectedCode,
                            name: _currencyCodes[_selectedCode]!,
                            amount: double.parse(_amountController.text),
                            currentRate: _currentRate!,
                          );
                          Navigator.pop(context, currency);
                        }
                      },
                child: const Text('Ekle'),
              ),
            ],
          ),
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