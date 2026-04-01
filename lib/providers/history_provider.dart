import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bill.dart';

class HistoryProvider extends ChangeNotifier {
  static const String _storageKey = 'splitbill_history_data';
  
  List<Bill> _savedBills = [];
  bool _isLoading = true;

  List<Bill> get savedBills => _savedBills;
  bool get isLoading => _isLoading;

  HistoryProvider() {
    loadHistory();
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners(); // Notifica la pantalla de carga (opcional)

    final prefs = await SharedPreferences.getInstance();
    final String? billsJsonStr = prefs.getString(_storageKey);

    if (billsJsonStr != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(billsJsonStr);
        _savedBills = decodedList.map((j) => Bill.fromJson(j)).toList();
        
        // Ordenamos desde la más reciente cronológicamente a la más antigua
        _savedBills.sort((a, b) => b.date.compareTo(a.date));
      } catch (e) {
        debugPrint('Error loading history: $e');
        _savedBills = [];
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Guarda una boleta finalizada al Storage. El límite es estricto en 100 elementos.
  Future<void> saveBill(Bill bill, String title) async {
    // Aplicamos el nombre
    bill.title = title.trim().isNotEmpty ? title.trim() : 'Boleta del ${bill.date.day}/${bill.date.month}';
    
    // Si la boleta ya existe (mismo id), la removemos para colocar la moderna primero
    _savedBills.removeWhere((b) => b.id == bill.id);
    
    // La inyectamos arriba de la lista
    _savedBills.insert(0, bill);

    // Límite Silencioso: Cortar la lista a solo 100 boletas
    if (_savedBills.length > 100) {
       _savedBills = _savedBills.sublist(0, 100);
    }

    // Persistir escribiendo todo el String JSON al disco
    final prefs = await SharedPreferences.getInstance();
    final String encodedStr = jsonEncode(_savedBills.map((b) => b.toJson()).toList());
    await prefs.setString(_storageKey, encodedStr);
    
    notifyListeners();
  }

  /// (Funcionalidad extra) Limpia la base de datos por completo
  Future<void> eraseAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    _savedBills.clear();
    notifyListeners();
  }
}
