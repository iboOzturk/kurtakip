import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/currency_service.dart';
import '../services/storage_service.dart';

import 'currency_converter_screen.dart';

class LiveRatesScreen extends StatefulWidget {
  const LiveRatesScreen({super.key});

  @override
  State<LiveRatesScreen> createState() => _LiveRatesScreenState();
}

class _LiveRatesScreenState extends State<LiveRatesScreen> with SingleTickerProviderStateMixin {
  final CurrencyService _currencyService = CurrencyService();
  final StorageService _storageService = Get.find<StorageService>();
  Map<String, dynamic> _rates = {};
  bool _isLoading = true;
  List<String> _favoriteRates = [];
  late TabController _tabController;
  DateTime? _lastUpdated;

  final List<String> _mainCurrencies = [
    'USDTRY', 'EURTRY', 'GBPTRY', 'JPYTRY',
    'AUDTRY', 'CADTRY', 'SARTRY', 'NOKTRY', 'DKKTRY',
  ];

  final List<String> _goldTypes = [
    'ALTIN', 'AYAR22', 'CEYREK_YENI', 'YARIM_YENI',
    'TEK_YENI', 'ATA_YENI',
  ];

  final Map<String, String> _goldNames = {
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
    _tabController = TabController(length: 3, vsync: this);
    _loadFavoriteRates();
    _fetchRates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchRates() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final newRates = await _currencyService.getLiveRates();
      setState(() {
        _rates = newRates;
        _isLoading = false;
        _lastUpdated = DateTime.now();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kurlar alınırken hata oluştu')),
        );
      }
    }
  }

  Future<void> _loadFavoriteRates() async {
    _favoriteRates = await _storageService.getFavoriteRates();
    setState(() {});
  }

  void _toggleFavorite(String code) async {
    setState(() {
      if (_favoriteRates.contains(code)) {
        _favoriteRates.remove(code);
      } else {
        _favoriteRates.add(code);
      }
    });
    await _storageService.saveFavoriteRates(_favoriteRates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Canlı Kurlar'),
            if (_lastUpdated != null)
              Text(
                'Son güncelleme: ${DateFormat('HH:mm:ss').format(_lastUpdated!)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.currency_exchange),
            tooltip: 'Kur Dönüştürücü',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CurrencyConverterScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
            onPressed: _fetchRates,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          tabs: const [
            Tab(
              icon: Icon(Icons.currency_exchange),
              text: 'Dövizler',
            ),
            Tab(
              icon: Icon(Icons.monetization_on),
              text: 'Altınlar',
            ),
            Tab(
              icon: Icon(Icons.star),
              text: 'Favoriler',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRatesList(_mainCurrencies),
          _buildRatesList(_goldTypes),
          _buildFavoritesList(),
        ],
      ),
    );
  }

  Widget _buildRatesList(List<String> codes) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _fetchRates,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: codes.length,
        itemBuilder: (context, index) {
          final code = codes[index];
          return _buildRateCard(code);
        },
      ),
    );
  }

  Widget _buildFavoritesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final favoriteItems = [..._mainCurrencies, ..._goldTypes]
        .where((code) => _favoriteRates.contains(code))
        .toList();

    if (favoriteItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz favori eklemediniz',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRates,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: favoriteItems.length,
        itemBuilder: (context, index) {
          return _buildRateCard(favoriteItems[index]);
        },
      ),
    );
  }

  Widget _buildRateCard(String code) {
    if (!_rates.containsKey(code)) return const SizedBox.shrink();
    
    final data = _rates[code];
    final alis = data['alis']?.toString() ?? '0.0';
    final satis = data['satis']?.toString() ?? '0.0';
    final isGold = _goldTypes.contains(code);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showDetailSheet(context, code, data);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [

              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isGold 
                            ? Colors.amber.withOpacity(0.2)
                            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isGold ? Icons.monetization_on : Icons.currency_exchange,
                        size: 16,
                        color: isGold 
                            ? Colors.amber[700]
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGold 
                                ? _goldNames[code] ?? code
                                : _getCurrencyName(code),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Orta: Alış/Satış
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Alış',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '₺${double.parse(alis).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Satış',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '₺${double.parse(satis).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Sağ taraf: Favori butonu
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  _favoriteRates.contains(code)
                      ? Icons.star
                      : Icons.star_border,
                  size: 20,
                  color: _favoriteRates.contains(code)
                      ? Colors.amber
                      : Colors.grey,
                ),
                onPressed: () => _toggleFavorite(code),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, String code, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getCurrencyName(code),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem('En Düşük', data['dusuk']?.toString() ?? '0.0', Colors.blue),
                _buildDetailItem('En Yüksek', data['yuksek']?.toString() ?? '0.0', Colors.orange),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          '₺${double.parse(value).toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case 'USDTRY':
        return 'Amerikan Doları';
      case 'EURTRY':
        return 'Euro';
      case 'GBPTRY':
        return 'İngiliz Sterlini';
      case 'NOKTRY':
        return 'Norveç Kronu';
      case 'DKKTRY':
        return 'Danimarka Kronu';
      case 'SEKTRY':
        return 'İsveç Kronu';
      case 'AUDTRY':
        return 'Avustralya Doları';
      case 'CADTRY':
        return 'Kanada Doları';
      case 'SARTRY':
        return 'Suudi Arabistan Riyali';
      case 'JPYTRY':
        return 'Japon Yeni';
      default:
        return code;
    }
  }
}

class TrendPainter extends CustomPainter {
  final List<double> trend;
  final Color color;

  TrendPainter({required this.trend, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (trend.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final maxValue = trend.reduce(max).abs();
    final minValue = trend.reduce(min).abs();
    final range = maxValue + minValue;
    
    final xStep = size.width / (trend.length - 1);
    final yMiddle = size.height / 2;
    final yScale = size.height / (range * 2);

    path.moveTo(0, yMiddle - (trend.first * yScale));
    
    for (int i = 1; i < trend.length; i++) {
      path.lineTo(
        i * xStep,
        yMiddle - (trend[i] * yScale),
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrendPainter oldDelegate) => true;
}
