import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../models/bill.dart';
import '../logic/split_calculator.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  void _showBillSummaryPopup(BuildContext context, Bill bill) {
    final results = SplitCalculator.calculateItemizedSplit(bill);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bill.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                'Total pagado: ${bill.currency.symbol}${bill.total.toStringAsFixed(bill.currency.decimalPlaces)}', 
                style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor)
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: results.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final friendId = results.keys.elementAt(index);
                final amount = results[friendId] ?? 0.0;
                final friend = bill.friends.firstWhere((f) => f.id == friendId);
                final fallbackInitial = friend.name.isNotEmpty ? friend.name[0].toUpperCase() : '?';

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                      backgroundColor: Theme.of(context).cardTheme.color,
                      child: Text(friend.avatarUrl ?? fallbackInitial, style: friend.avatarUrl != null ? const TextStyle(fontSize: 20) : TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor))
                  ),
                  title: Text(friend.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text(
                    '${bill.currency.symbol}${amount.toStringAsFixed(bill.currency.decimalPlaces)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: amount > 0 ? null : Colors.green,
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escucha automáticamente los cambios del historial
    final historyProvider = Provider.of<HistoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archivos / Historial'),
      ),
      body: SafeArea(
        child: historyProvider.savedBills.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_toggle_off, size: 80, color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    const Text('Tu historial está impecable. No hay boletas aún.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: historyProvider.savedBills.length,
                itemBuilder: (context, index) {
                  final bill = historyProvider.savedBills[index];
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        child: Icon(Icons.receipt_long, color: Theme.of(context).primaryColor),
                      ),
                      title: Text(bill.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${bill.date.day}/${bill.date.month}/${bill.date.year} • ${bill.friends.length} amig@s'),
                      trailing: Text(
                        '${bill.currency.symbol}${bill.total.toStringAsFixed(bill.currency.decimalPlaces)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      onTap: () => _showBillSummaryPopup(context, bill),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
