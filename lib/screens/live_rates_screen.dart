import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/currency_service.dart';
import '../widgets/custom_refresh_indicator.dart';

class LiveRatesScreen extends StatefulWidget {
  const LiveRatesScreen({super.key});

  @override
  State<LiveRatesScreen> createState() => _LiveRatesScreenState();
}

class _LiveRatesScreenState extends State<LiveRatesScreen> with SingleTickerProviderStateMixin {
  final CurrencyService _currencyService = CurrencyService();
  Map<String, dynamic>? _rates;
  bool _isLoading = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _fetchRates();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchRates() async {
    try {
      final rates = await _currencyService.getLiveRates();
      setState(() {
        _rates = rates;
        _isLoading = false;
      });
      _controller.forward(from: 0.0);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('Hata: $e'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomRefreshIndicator(
        onRefresh: _fetchRates,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: true,
              pinned: true,
              stretch: true,
              flexibleSpace: FlexibleSpaceBar(
                title:  Text('Canlı Döviz Kurları',style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold),),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchRates,
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: _isLoading
                  ? const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildListDelegate(_buildCurrencyCards()),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCurrencyCards() {
    if (_rates == null) return [];

    final mainCurrencies = ['USDTRY', 'EURTRY', 'GBPTRY', 'ALTIN'];
    return mainCurrencies.map((code) {
      final data = _rates![code];
      if (data == null) return const SizedBox.shrink();

      final double change = double.tryParse(data['degisim'] ?? '0') ?? 0;
      final bool isPositive = change >= 0;

      return FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // Gelecekte detay sayfası için
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getCurrencyName(code),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      _buildChangeIndicator(change),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRateColumn('Alış', data['alis'], Colors.green),
                      _buildRateColumn('Satış', data['satis'], Colors.red),
                      _buildRateColumn('En Düşük', data['dusuk'], Colors.blue),
                      _buildRateColumn('En Yüksek', data['yuksek'], Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildChangeIndicator(double change) {
    final bool isPositive = change >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: isPositive ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${change.abs().toStringAsFixed(2)}%',
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateColumn(String label, dynamic value, Color color) {
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
          '$value ₺',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case 'USDTRY':
        return 'USD/TRY';
      case 'EURTRY':
        return 'EUR/TRY';
      case 'GBPTRY':
        return 'GBP/TRY';
      case 'ALTIN':
        return 'Altın';
      default:
        return code;
    }
  }
} 