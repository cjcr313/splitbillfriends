import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/bill_provider.dart';
import '../providers/history_provider.dart';
import '../logic/split_calculator.dart';
import '../models/bill.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  void _saveAndFinish(BuildContext context, Bill currentBill) {
    final titleController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Guardar Boleta', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Escribe un título para recordar esta salida:'),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Ej. Pizza viernes',
                  prefixIcon: Icon(Icons.edit),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                 final billProvider = Provider.of<BillProvider>(context, listen: false);
                 final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
                 
                 // 1. Guardar en Storage local
                 await historyProvider.saveBill(currentBill, titleController.text);
                 
                 // Limpiamos la boleta actual en memoria
                 billProvider.clearBill();

                 // 2. Volver al Home, sacando todas las pantallas de la pila de navegación
                 if(context.mounted) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado en Historial 💾'), backgroundColor: Colors.green));
                 }
              },
              child: const Text('GUARDAR Y FINALIZAR', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        );
      }
    );
  }

  void _executeShare(Bill currentBill, Map<String, double> results) {
     StringBuffer sb = StringBuffer();
     sb.writeln('🧾 **SplitBillFriends**');
     sb.writeln('Total mesa: ${currentBill.currency.symbol}${currentBill.total.toStringAsFixed(currentBill.currency.decimalPlaces)}');
     sb.writeln('---');
     
     results.forEach((friendId, amount) {
        final friend = currentBill.friends.firstWhere((f) => f.id == friendId);
        if(amount > 0) {
           sb.writeln('👤 ${friend.name} debe: ${currentBill.currency.symbol}${amount.toStringAsFixed(currentBill.currency.decimalPlaces)}');
        }
     });
     sb.writeln('---');
     sb.writeln('¡Gracias por usar SplitBillFriends! 💸');
     
     // ignore: deprecated_member_use
     Share.share(sb.toString());
  }

  @override
  Widget build(BuildContext context) {
    final billProvider = Provider.of<BillProvider>(context, listen: false);
    final currentBill = billProvider.currentBill;

    if (currentBill == null || currentBill.friends.isEmpty) {
      return const Scaffold(body: Center(child: Text('Error: Boleta vacía.')));
    }

    final Map<String, double> results = SplitCalculator.calculateItemizedSplit(currentBill);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
             Container(
               width: double.infinity,
               padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
               decoration: BoxDecoration(
                 color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                 border: Border(bottom: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.2))),
               ),
               child: Column(
                 children: [
                   Text('TOTAL CANCELADO', style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7))),
                   const SizedBox(height: 8),
                   Text(
                     '${currentBill.currency.symbol}${currentBill.total.toStringAsFixed(currentBill.currency.decimalPlaces)}',
                     style: TextStyle(
                       fontSize: 48, 
                       fontWeight: FontWeight.w900, 
                       color: Theme.of(context).primaryColor
                     ),
                   ),
                 ],
               ),
             ),
             
             Expanded(
               child: ListView.separated(
                 padding: const EdgeInsets.all(24),
                 itemCount: results.length,
                 separatorBuilder: (context, index) => const Divider(height: 32),
                 itemBuilder: (context, index) {
                   String friendId = results.keys.elementAt(index);
                   double amount = results[friendId] ?? 0.0;
                   var friend = currentBill.friends.firstWhere((f) => f.id == friendId);
                   
                   final fallbackInitial = friend.name.isNotEmpty ? friend.name[0].toUpperCase() : '?';

                   return Row(
                     children: [
                       CircleAvatar(
                         radius: 24,
                         backgroundColor: Theme.of(context).cardTheme.color,
                         child: Text(
                           friend.avatarUrl ?? fallbackInitial, 
                           style: friend.avatarUrl != null
                               ? const TextStyle(fontSize: 24)
                               : TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)
                         ),
                       ),
                       const SizedBox(width: 16),
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(friend.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                             if(amount == 0)
                               const Text('Consumo gratuito / Todo Pagado', style: TextStyle(fontSize: 12, color: Colors.green)),
                           ],
                         ),
                       ),
                       Text(
                         '${currentBill.currency.symbol}${amount.toStringAsFixed(currentBill.currency.decimalPlaces)}',
                         style: TextStyle(
                           fontSize: 22, 
                           fontWeight: FontWeight.w900,
                           color: amount > 0 ? null : Colors.green 
                         ),
                       )
                     ],
                   );
                 },
               ),
             ),
             
             Padding(
               padding: const EdgeInsets.all(24.0),
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   OutlinedButton.icon(
                     onPressed: () => _executeShare(currentBill, results),
                     icon: const Icon(Icons.ios_share_rounded),
                     label: const Text('COMPARTIR RESULTADOS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                     style: OutlinedButton.styleFrom(
                       minimumSize: const Size(double.infinity, 50),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                     ),
                   ),
                   const SizedBox(height: 12),
                   ElevatedButton.icon(
                     onPressed: () => _saveAndFinish(context, currentBill),
                     icon: const Icon(Icons.bookmark_added_rounded),
                     label: const Text('FINALIZAR Y GUARDAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                     style: ElevatedButton.styleFrom(
                       minimumSize: const Size(double.infinity, 56),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                       backgroundColor: Theme.of(context).primaryColor,
                       foregroundColor: Colors.white,
                       elevation: 4,
                     ),
                   ),
                 ],
               ),
             )
          ],
        ),
      ),
    );
  }
}
