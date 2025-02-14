import 'package:flutter/material.dart';
import '../services/currency_service.dart';

import 'currency_converter_screen.dart';

class LiveRatesScreen extends StatefulWidget {
  const LiveRatesScreen({super.key});

  @override
  State<LiveRatesScreen> createState() => _LiveRatesScreenState();
}

class _LiveRatesScreenState extends State<LiveRatesScreen> with SingleTickerProviderStateMixin {
  final CurrencyService _currencyService = CurrencyService();
  Map<String, dynamic>? _rates;
  bool _isLoading = true;
  late TabController _tabController;

  final List<String> _mainCurrencies = ['USDTRY', 'EURTRY', 'GBPTRY','NOKTRY','DKKTRY','SEKTRY','AUDTRY','CADTRY','SARTRY','JPYTRY'];
  final List<String> _goldTypes = ['ALTIN', 'CEYREK_YENI', 'YARIM_YENI', 'TEK_YENI', 'ATA_YENI'];

  final Map<String, String> _goldNames = {
    'ALTIN': 'Gram Altın',
    'CEYREK_YENI': 'Çeyrek Altın',
    'YARIM_YENI': 'Yarım Altın',
    'TEK_YENI': 'Tam Altın',
    'ATA_YENI': 'Cumhuriyet Altını',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      final rates = await _currencyService.getLiveRates();
      setState(() {
        _rates = rates;
        _isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      Theme.of(context).colorScheme.primary,
                    ]
                  : [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text('Canlı Kurlar',style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
            ),),
            Text(
              'Son Güncelleme: ${DateTime.now().hour}:${DateTime.now().minute}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calculate,
              color: Colors.white,
            ),
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
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: _fetchRates,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Theme.of(context).colorScheme.surface
                  : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.currency_exchange,
                        size: 20,
                        color: _tabController.index == 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      const Text('Dövizler'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 20,
                        color: _tabController.index == 1
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      const Text('Altın'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: isDarkMode
            ? Theme.of(context).colorScheme.surface
            : Colors.white,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildCurrenciesTab(),
                  _buildGoldTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildCurrencyCard(String currencyCode) {
    final data = _rates?[currencyCode];
    if (data == null) return const SizedBox.shrink();

    final alis = double.tryParse(data['alis'].toString()) ?? 0;
    final satis = double.tryParse(data['satis'].toString()) ?? 0;
    final dusuk = double.tryParse(data['dusuk'].toString()) ?? 0;
    final yuksek = double.tryParse(data['yuksek'].toString()) ?? 0;


    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getCurrencyName(currencyCode),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    currencyCode.substring(0, 3),
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark?Colors.white:Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRateColumn('Alış', alis, Colors.green),
                _buildRateColumn('Satış', satis, Colors.red),
                _buildRateColumn('En Düşük', dusuk, Colors.blue),
                _buildRateColumn('En Yüksek', yuksek, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldCard(String goldCode) {
    final data = _rates?[goldCode];
    if (data == null) return const SizedBox.shrink();

    final alis = double.tryParse(data['alis'].toString()) ?? 0;
    final satis = double.tryParse(data['satis'].toString()) ?? 0;


    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _goldNames[goldCode] ?? goldCode,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: Colors.amber[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Altın',
                      style: TextStyle(
                        color: Colors.amber[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRateColumn('Alış', alis, Colors.green),
                _buildRateColumn('Satış', satis, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrenciesTab() {
    return RefreshIndicator(
      onRefresh: _fetchRates,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: _mainCurrencies.map((code) => _buildCurrencyCard(code)).toList(),
      ),
    );
  }

  Widget _buildGoldTab() {
    return RefreshIndicator(
      onRefresh: _fetchRates,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: _goldTypes.map((code) => _buildGoldCard(code)).toList(),
      ),
    );
  }

  Widget _buildRateColumn(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(2),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
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
