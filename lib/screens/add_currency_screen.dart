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
  final _amountController = TextEditingController();
  final _currencyService = CurrencyService();
  bool _isLoading = false;
  double? _currentRate;
  AssetType _selectedType = AssetType.currency;
  String _selectedCode = 'USD';

  final Map<String, String> _currencyCodes = {
    'USD': 'Amerikan Doları',
    'EUR': 'Euro',
    'GBP': 'İngiliz Sterlini',
  };

  final Map<String, String> _goldCodes = {
    'ALTIN': 'Gram Altın',
    'CEYREK_YENI': 'Çeyrek Altın',
    'YARIM_YENI': 'Yarım Altın',
    'TEK_YENI': 'Tam Altın',
    'ATA_YENI': 'Cumhuriyet Altını',
  };

  @override
  void initState() {
    super.initState();
    _fetchCurrentRate();
  }

  Future<void> _fetchCurrentRate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rates = await _currencyService.getLiveRates();
      String apiKey = _selectedType == AssetType.currency 
          ? '${_selectedCode}TRY' 
          : _selectedCode;
          
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
        title: Text(_selectedType == AssetType.currency 
            ? 'Döviz Ekle' 
            : 'Altın Ekle'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                      children: [
                        SegmentedButton<AssetType>(
                          segments: const [
                            ButtonSegment(
                              value: AssetType.currency,
                              icon: Icon(Icons.currency_exchange),
                              label: Text('Döviz'),
                            ),
                            ButtonSegment(
                              value: AssetType.gold,
                              icon: Icon(Icons.monetization_on),
                              label: Text('Altın'),
                            ),
                          ],
                          selected: {_selectedType},
                          onSelectionChanged: (Set<AssetType> newSelection) {
                            setState(() {
                              _selectedType = newSelection.first;
                              _selectedCode = _selectedType == AssetType.currency
                                  ? 'USD'
                                  : 'ALTIN';
                              _fetchCurrentRate();
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCode,
                          decoration: InputDecoration(
                            labelText: _selectedType == AssetType.currency
                                ? 'Döviz Türü'
                                : 'Altın Türü',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: (_selectedType == AssetType.currency
                                  ? _currencyCodes
                                  : _goldCodes)
                              .entries
                              .map((entry) {
                            return DropdownMenuItem(
                              value: entry.key,
                              child: Text('${entry.value}'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCode = value!;
                              _fetchCurrentRate();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _amountController,
                          decoration: InputDecoration(
                            labelText: _selectedType == AssetType.currency
                                ? 'Miktar'
                                : 'Adet/Gram',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen miktar giriniz';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_isLoading)
                          const CircularProgressIndicator()
                        else if (_currentRate != null)
                          Column(
                            children: [
                              Text(
                                'Güncel Kur',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_currentRate!.toStringAsFixed(2)} ₺',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading || _currentRate == null
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            final currency = Currency(
                              code: _selectedCode,
                              name: _selectedType == AssetType.currency
                                  ? _currencyCodes[_selectedCode]!
                                  : _goldCodes[_selectedCode]!,
                              amount: double.parse(_amountController.text),
                              currentRate: _currentRate!,
                              type: _selectedType,
                            );
                            Navigator.pop(context, currency);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Ekle'),
                ),
              ],
            ),
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