import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bill_provider.dart';
import 'summary_screen.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  
  // Lista temporal para armar los seleccionados en el BottomSheet
  final Set<String> _selectedFriendIds = {};

  void _showAddItemSheet(BuildContext context) {
    final billProvider = Provider.of<BillProvider>(context, listen: false);
    final friends = billProvider.currentBill?.friends ?? [];
    _selectedFriendIds.clear();
    _nameController.clear();
    _priceController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                top: 24, left: 24, right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Añadir Artículo', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Campo Nombre del Item
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Ej. Pizza Grande',
                      filled: true,
                      fillColor: Theme.of(context).cardTheme.color,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Campo Precio del Item
                  TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Precio (Ej. 10000)',
                      filled: true,
                      fillColor: Theme.of(context).cardTheme.color,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text('¿Quiénes lo comieron?', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  Text('Si no marcas a nadie, se divide entre todos.', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  const SizedBox(height: 12),
                  
                  // Selector de Amigos
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: friends.map((f) {
                      final isSelected = _selectedFriendIds.contains(f.id);
                      final primaryColor = Theme.of(context).primaryColor;
                      return FilterChip(
                        selected: isSelected,
                        selectedColor: primaryColor.withValues(alpha: 0.2),
                        checkmarkColor: primaryColor,
                        label: Text(f.name),
                        onSelected: (bool selected) {
                          setSheetState(() {
                            if (selected) {
                              _selectedFriendIds.add(f.id);
                            } else {
                              _selectedFriendIds.remove(f.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Botón Guardar
                  ElevatedButton(
                    onPressed: () {
                      final price = double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0;
                      if (_nameController.text.isNotEmpty && price > 0) {
                        billProvider.addItem(
                          _nameController.text,
                          price,
                          _selectedFriendIds.toList(), // Enviamos IDs seleccionados
                        );
                        Navigator.pop(sheetContext);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('AGREGAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      }
    );
  }

  void _showTipDialog(BuildContext context, BillProvider provider) {
    final TextEditingController tipController = TextEditingController(
      text: (provider.currentBill?.taxAndTip ?? 0) > 0 ? provider.currentBill?.taxAndTip.toString() : ''
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Propina / Impuestos'),
          content: TextField(
            controller: tipController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Monto extra',
              prefixIcon: Icon(Icons.monetization_on_outlined),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(tipController.text.replaceAll(',', '.')) ?? 0;
                provider.setTaxAndTip(amount);
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final billProvider = Provider.of<BillProvider>(context);
    final items = billProvider.currentBill?.items ?? [];
    final currentBill = billProvider.currentBill;
    
    // Obtener nombres a partir de IDs para pintarlos en la boleta
    String getAssignedNames(List<String> ids) {
       if (ids.isEmpty) return 'Todos comparten';
       final friends = currentBill?.friends ?? [];
       final names = ids.map((id) => friends.firstWhere((f) => f.id == id, orElse: () => friends.first).name).toList();
       return names.join(', ');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Desglose de la Cuenta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.room_service),
            tooltip: 'Añadir Propina',
            onPressed: () => _showTipDialog(context, billProvider),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Resumen Rápido Superior
            Container(
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).cardTheme.color,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Subtotal', style: TextStyle(color: Colors.grey)),
                      Text('${currentBill?.currency.symbol}${currentBill?.subtotal.toStringAsFixed(currentBill.currency.decimalPlaces)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('+ Propina/Imp', style: TextStyle(color: Colors.grey)),
                      Text('${currentBill?.currency.symbol}${currentBill?.taxAndTip.toStringAsFixed(currentBill.currency.decimalPlaces)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                    ],
                  )
                ],
              ),
            ),

            // Lista de Items
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'Ningún gasto ingresado. Presiona + para comenzar.',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              child: Icon(Icons.fastfood, color: Theme.of(context).primaryColor),
                            ),
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(getAssignedNames(item.assignedFriendIds)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${currentBill!.currency.symbol}${item.price.toStringAsFixed(currentBill.currency.decimalPlaces)}',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () => billProvider.removeItem(item.id),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addItemBtn',
            onPressed: () => _showAddItemSheet(context),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          if (items.isNotEmpty)
            FloatingActionButton.extended(
              heroTag: 'goSummaryBtn',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SummaryScreen()));
              },
              icon: const Icon(Icons.calculate),
              label: const Text('CALCULAR'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
        ],
      ),
    );
  }
}
