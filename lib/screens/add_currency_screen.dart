import 'package:flutter/material.dart';
import '../models/currency.dart';
import '../services/currency_service.dart';
import 'package:intl/intl.dart';

class AddCurrencyScreen extends StatefulWidget {
  const AddCurrencyScreen({super.key});

  @override
  State<AddCurrencyScreen> createState() => _AddCurrencyScreenState();
}

class _AddCurrencyScreenState extends State<AddCurrencyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _initialRateController = TextEditingController();
  final _currencyService = CurrencyService();
  bool _isLoading = false;
  bool _isHistorical = false;
  double? _currentRate;
  AssetType _selectedType = AssetType.currency;
  String _selectedCode = 'USD';
  DateTime _purchaseDate = DateTime.now();

  final Map<String, String> _currencyCodes = {
    'USD': 'Amerikan Doları',
    'EUR': 'Euro',
    'GBP': 'İngiliz Sterlini',
    'NOK': 'Norveç Kronu',
    'DKK': 'Danimarka Kronu',
    'SEK': 'İsveç Kronu',
    'AUD': 'Avustralya Doları',
    'CAD': 'Kanada Doları',
    'SAR': 'Suudi Arabistan Riyali',
    'JPY': 'Japon Yeni'
  };

  final Map<String, String> _goldCodes = {
    'ALTIN': 'Gram Altın',
    'AYAR22': '22 Ayar Altın',
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          title: const Text('Geçmiş Alım'),
                          subtitle: const Text('Önceden alınmış varlık için'),
                          value: _isHistorical,
                          onChanged: (value) {
                            setState(() {
                              _isHistorical = value;
                              if (!value) {
                                _initialRateController.text = '';
                                _purchaseDate = DateTime.now();
                              }
                            });
                          },
                        ),
                        if (_isHistorical) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _initialRateController,
                            decoration: InputDecoration(
                              labelText: 'Alış Kuru (TL)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.price_change),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen alış kurunu giriniz';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Geçerli bir sayı giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _purchaseDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null && picked != _purchaseDate) {
                                setState(() {
                                  _purchaseDate = picked;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Alış Tarihi',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.calendar_today),
                              ),
                              child: Text(
                                DateFormat('dd.MM.yyyy').format(_purchaseDate),
                              ),
                            ),
                          ),
                        ],
                        if (!_isHistorical && _currentRate != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Güncel Kur: ${_currentRate!.toStringAsFixed(2)} ₺',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading || (_currentRate == null && !_isHistorical)
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
                              initialRate: _isHistorical 
                                  ? double.parse(_initialRateController.text)
                                  : _currentRate!,
                              addedDate: _isHistorical 
                                  ? _purchaseDate
                                  : DateTime.now(),
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
    _initialRateController.dispose();
    super.dispose();
  }
} 