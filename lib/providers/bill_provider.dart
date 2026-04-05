import 'dart:math';
import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../models/friend.dart';
import '../models/item.dart';
import '../models/currency.dart';

class BillProvider extends ChangeNotifier {
  static const Map<String, String> _animalMap = {
    '🐶': 'Perro', '🐱': 'Gato', '🦓': 'Cebra', '🐘': 'Elefante', '🐬': 'Delfín',
    '🐧': 'Pingüino', '🦊': 'Zorro', '🐸': 'Rana', '🐭': 'Ratón', '🦁': 'León',
    '🐯': 'Tigre', '🐻': 'Oso', '🐼': 'Panda', '🐨': 'Koala', '🐷': 'Cerdo',
    '🐰': 'Conejo', '🐙': 'Pulpo', '🐢': 'Tortuga', '🦉': 'Búho', '🦄': 'Unicornio'
  };

  Bill? _currentBill;

  Bill? get currentBill => _currentBill;

  void startNewBill({AppCurrency currency = AppCurrency.clp}) {
    _currentBill = Bill(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        currency: currency,
    );
    notifyListeners();
  }

  void clearBill() {
    _currentBill = null;
    notifyListeners();
  }

  void addFriend([String? name]) {
    if (_currentBill == null) return;
    
    String finalName = (name != null) ? name.trim() : '';
    if (finalName.isEmpty && name != null && name.trim().isNotEmpty) return; // Validación original adaptada

    String avatar = '🤷';
    final avatarsList = _animalMap.keys.toList();
    final currentAvatars = _currentBill!.friends.map((f) => f.avatarUrl).toSet();
    final availableAvatars = avatarsList.where((a) => !currentAvatars.contains(a)).toList();
    
    if (availableAvatars.isNotEmpty) {
      avatar = availableAvatars[Random().nextInt(availableAvatars.length)];
    } else {
       avatar = avatarsList[Random().nextInt(avatarsList.length)];
    }

    if (finalName.isEmpty) {
      finalName = _animalMap[avatar] ?? 'Amig@';
    }

    final newFriend = Friend(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: finalName,
      avatarUrl: avatar,
    );
    
    _currentBill!.friends.add(newFriend);
    notifyListeners();
  }

  void removeFriend(String id) {
    if (_currentBill == null) return;
    _currentBill!.friends.removeWhere((friend) => friend.id == id);
    notifyListeners();
  }

  // ---- NUEVOS MÉTODOS REQUERIDOS PARA ITEMS Y PROPINA ----

  void addItem(String name, double price, List<String> assignedFriendIds) {
    if (_currentBill == null || name.trim().isEmpty || price <= 0) return;
    
    final newItem = Item(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      price: price,
      assignedFriendIds: assignedFriendIds,
    );
    _currentBill!.items.add(newItem);
    notifyListeners();
  }

  void removeItem(String id) {
    if (_currentBill == null) return;
    _currentBill!.items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void setTaxAndTip(double amount) {
    if (_currentBill == null) return;
    _currentBill!.taxAndTip = amount;
    notifyListeners();
  }
}
