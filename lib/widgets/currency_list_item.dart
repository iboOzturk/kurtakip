import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/currency.dart';
import '../controllers/portfolio_controller.dart';
import '../screens/edit_currency_screen.dart';
import 'package:intl/intl.dart';

class CurrencyListItem extends StatefulWidget {
  final Currency currency;
  final int index;

  const CurrencyListItem({
    super.key,
    required this.currency,
    required this.index,
  });

  @override
  State<CurrencyListItem> createState() => _CurrencyListItemState();
}

class _CurrencyListItemState extends State<CurrencyListItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PortfolioController>();
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final profitLossColor = widget.currency.profitLossPercentage >= 0 ? Colors.green : Colors.red;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      widget.currency.type == AssetType.currency
                          ? Icons.currency_exchange
                          : Icons.monetization_on,
                      color: widget.currency.type == AssetType.currency
                          ? Theme.of(context).colorScheme.primary
                          : Colors.amber[700],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.currency.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.currency.type == AssetType.currency
                              ? '${widget.currency.amount} ${widget.currency.code}'
                              : '${widget.currency.amount} Adet',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.currency.totalValueInTRY.toStringAsFixed(2)} ₺',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: profitLossColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.currency.profitLossPercentage >= 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 16,
                              color: profitLossColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.currency.profitLossPercentage.abs().toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: profitLossColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  RotatedBox(
                    quarterTurns: _isExpanded ? 2 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildValueColumn(
                        context,
                        'Alış Değeri',
                        widget.currency.initialValueInTRY,
                        widget.currency.initialRate,
                        isDarkMode,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildValueColumn(
                        context,
                        'Güncel Değer',
                        widget.currency.totalValueInTRY,
                        widget.currency.currentRate,
                        isDarkMode,
                        isCurrentValue: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kar/Zarar:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${widget.currency.profitLoss >= 0 ? '+' : ''}${widget.currency.profitLoss.toStringAsFixed(2)} ₺',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: profitLossColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Eklenme Tarihi: ${dateFormat.format(widget.currency.addedDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueColumn(
    BuildContext context,
    String label,
    double totalValue,
    double rate,
    bool isDarkMode, {
    bool isCurrentValue = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentValue
            ? (isDarkMode
                ? Colors.blue.withOpacity(0.1)
                : Colors.blue.withOpacity(0.05))
            : (isDarkMode
                ? Colors.grey.withOpacity(0.1)
                : Colors.grey.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentValue
              ? Colors.blue.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isCurrentValue ? Colors.blue : null,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '${totalValue.toStringAsFixed(2)} ₺',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCurrentValue ? Colors.blue : null,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Birim: ${rate.toStringAsFixed(2)} ₺',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, PortfolioController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Düzenle'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditCurrencyScreen(currency: widget.currency),
                  ),
                );
                if (result != null && result is Currency) {
                  controller.updateCurrency(widget.index, result);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Sil', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, controller);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PortfolioController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Döviz Sil'),
        content: Text('${widget.currency.code} dövizini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              controller.removeCurrency(widget.index);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
} 