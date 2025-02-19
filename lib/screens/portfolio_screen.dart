import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/currency.dart';
import '../controllers/portfolio_controller.dart';
import 'add_currency_screen.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PortfolioController controller = Get.find();

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            snap: false,
            title: const Text('Portföyüm'),
            centerTitle: true,
            actions: [
              Obx(() => IconButton(
                    icon: Icon(
                      controller.hideValues.value
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white,
                    ),
                    onPressed: controller.toggleHideValues,
                  )),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => controller.updateRates(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
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
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          'Toplam Değer',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Obx(() => Text(
                              controller.hideValues.value
                                  ? '* * * * * ₺'
                                  : '${controller.formatNumber(controller.totalValue.value)} ₺',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              collapseMode: CollapseMode.pin,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                if (controller.currencies.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz varlık eklenmemiş',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                // Varlıkları grupla
                final groupedAssets = _groupAssets(controller.currencies);

                return Column(
                  children: [
                    // Dövizler
                    if (groupedAssets.currencies.isNotEmpty) ...[
                      _buildGroupHeader(
                        context,
                        'Dövizler',
                        Icons.currency_exchange,
                        groupedAssets.getCurrencyTotal(),
                        controller.hideValues.value,
                      ),
                      ...groupedAssets.currencies.entries.map(
                        (entry) => _buildGroupedCurrencyCard(
                          context,
                          entry.key,
                          entry.value,
                          controller.hideValues.value,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Altınlar
                    if (groupedAssets.golds.isNotEmpty) ...[
                      _buildGroupHeader(
                        context,
                        'Altınlar',
                        Icons.monetization_on,
                        groupedAssets.getGoldTotal(),
                        controller.hideValues.value,
                      ),
                      ...groupedAssets.golds.entries.map(
                        (entry) => _buildGroupedCurrencyCard(
                          context,
                          entry.key,
                          entry.value,
                          controller.hideValues.value,
                        ),
                      ),
                    ],
                  ],
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCurrencyScreen(),
            ),
          );
          if (result != null && result is Currency) {
            controller.addCurrency(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGroupHeader(
    BuildContext context,
    String title,
    IconData icon,
    double total,
    bool hideValues,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Text(
            hideValues
                ? '* * * * * ₺'
                : '${NumberFormat.currency(locale: 'tr', symbol: '₺', decimalDigits: 2).format(total)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedCurrencyCard(
    BuildContext context,
    String code,
    List<Currency> currencies,
    bool hideValues,
  ) {
    final totalAmount = currencies.fold(0.0, (sum, item) => sum + item.amount);
    final totalValue = currencies.fold(
      0.0,
      (sum, item) => sum + item.totalValueInTRY,
    );
    final totalInitialValue = currencies.fold(
      0.0,
      (sum, item) => sum + (item.amount * item.initialRate),
    );
    final profitLoss = totalValue - totalInitialValue;
    final profitLossPercentage = (profitLoss / totalInitialValue) * 100;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            currencies.first.type == AssetType.currency
                ? Icons.currency_exchange
                : Icons.monetization_on,
            color: currencies.first.type == AssetType.currency
                ? Theme.of(context).colorScheme.primary
                : Colors.amber[700],
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currencies.first.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencies.first.type == AssetType.currency
                        ? '$totalAmount $code'
                        : '$totalAmount Adet',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  hideValues
                      ? '* * * * * ₺'
                      : NumberFormat.currency(
                          locale: 'tr',
                          symbol: '₺',
                          decimalDigits: 2,
                        ).format(totalValue),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  hideValues
                      ? '* * * * *'
                      : '${profitLossPercentage >= 0 ? '+' : ''}${profitLossPercentage.toStringAsFixed(2)}%',
                  style: TextStyle(
                    color: profitLossPercentage >= 0 ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: currencies.asMap().entries.map((entry) {
          final Currency currency = entry.value;
          final itemProfitLoss = currency.totalValueInTRY - (currency.amount * currency.initialRate);
          final itemProfitLossPercentage = (itemProfitLoss / (currency.amount * currency.initialRate)) * 100;

          return Dismissible(
            key: Key(currency.addedDate.toString()),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Silme Onayı'),
                  content: const Text('Bu varlığı silmek istediğinizden emin misiniz?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Sil', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) {
              final controller = Get.find<PortfolioController>();
              final globalIndex = controller.currencies.indexWhere(
                (c) => c.addedDate == currency.addedDate,
              );
              if (globalIndex != -1) {
                controller.removeCurrency(globalIndex);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Varlık silindi')),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: Column(
                children: [
                  // Tarih ve Miktar Satırı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd.MM.yyyy').format(currency.addedDate),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        currency.type == AssetType.currency
                            ? '${currency.amount} $code'
                            : '${currency.amount} Adet',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  // Birim Fiyatlar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alış Birim Fiyatı',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hideValues
                                  ? '* * * * * ₺'
                                  : NumberFormat.currency(
                                      locale: 'tr',
                                      symbol: '₺',
                                      decimalDigits: 2,
                                    ).format(currency.initialRate),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Güncel Birim Fiyat',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hideValues
                                  ? '* * * * * ₺'
                                  : NumberFormat.currency(
                                      locale: 'tr',
                                      symbol: '₺',
                                      decimalDigits: 2,
                                    ).format(currency.currentRate),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Toplam Değerler
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alış Değeri',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hideValues
                                  ? '* * * * * ₺'
                                  : NumberFormat.currency(
                                      locale: 'tr',
                                      symbol: '₺',
                                      decimalDigits: 2,
                                    ).format(currency.amount * currency.initialRate),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Güncel Değer',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hideValues
                                  ? '* * * * * ₺'
                                  : NumberFormat.currency(
                                      locale: 'tr',
                                      symbol: '₺',
                                      decimalDigits: 2,
                                    ).format(currency.totalValueInTRY),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!hideValues) ...[
                    const Divider(height: 16),
                    // Kar/Zarar Bilgisi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kar/Zarar:',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${itemProfitLossPercentage >= 0 ? '+' : ''}${itemProfitLossPercentage.toStringAsFixed(2)}% (${NumberFormat.currency(
                            locale: 'tr',
                            symbol: '₺',
                            decimalDigits: 2,
                          ).format(itemProfitLoss)})',
                          style: TextStyle(
                            color: itemProfitLossPercentage >= 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }


}

class GroupedAssets {
  final Map<String, List<Currency>> currencies = {};
  final Map<String, List<Currency>> golds = {};

  void addCurrency(Currency currency) {
    if (currency.type == AssetType.currency) {
      currencies.putIfAbsent(currency.code, () => []).add(currency);
    } else {
      golds.putIfAbsent(currency.code, () => []).add(currency);
    }
  }

  double getCurrencyTotal() {
    return currencies.values.fold(
      0.0,
      (sum, currencies) => sum + currencies.fold(
        0.0,
        (sum, currency) => sum + currency.totalValueInTRY,
      ),
    );
  }

  double getGoldTotal() {
    return golds.values.fold(
      0.0,
      (sum, golds) => sum + golds.fold(
        0.0,
        (sum, gold) => sum + gold.totalValueInTRY,
      ),
    );
  }
}

GroupedAssets _groupAssets(List<Currency> currencies) {
  final grouped = GroupedAssets();
  for (var currency in currencies) {
    grouped.addCurrency(currency);
  }
  return grouped;
}