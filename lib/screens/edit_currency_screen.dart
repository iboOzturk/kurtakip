import 'package:flutter/material.dart';
import '../models/currency.dart';
import '../services/currency_service.dart';

class EditCurrencyScreen extends StatefulWidget {
  final Currency currency;

  const EditCurrencyScreen({
    super.key,
    required this.currency,
  });

  @override
  State<EditCurrencyScreen> createState() => _EditCurrencyScreenState();
}

class _EditCurrencyScreenState extends State<EditCurrencyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _currencyService = CurrencyService();
  bool _isLoading = false;
  double? _currentRate;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.currency.amount.toString();
    _fetchCurrentRate();
  }

  Future<void> _fetchCurrentRate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rates = await _currencyService.getLiveRates();
      String apiKey = '${widget.currency.code}TRY';
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
        title: Text('${widget.currency.code} Düzenle'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.currency.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else if (_currentRate != null)
                        Text(
                          'Güncel Kur: ${_currentRate!.toStringAsFixed(4)} TL',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Miktar',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen miktar giriniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading || _currentRate == null
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          final updatedCurrency = Currency(
                            code: widget.currency.code,
                            name: widget.currency.name,
                            amount: double.parse(_amountController.text),
                            currentRate: _currentRate!,
                          );
                          Navigator.pop(context, updatedCurrency);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Güncelle'),
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