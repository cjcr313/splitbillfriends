import 'dart:math';
import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../models/friend.dart';
import '../models/item.dart';
import '../models/currency.dart';

class BillProvider extends ChangeNotifier {
  static const List<String> _animalAvatars = [
    '🐶', '🐱', '🦓', '🐘', '🐬', '🐧', '🦊', '🐸', '🐭', '🦁', 
    '🐯', '🐻', '🐼', '🐨', '🐷', '🐰', '🐙', '🐢', '🦉', '🦄'
  ];

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

  void addFriend(String name) {
    if (_currentBill == null || name.trim().isEmpty) return;
    
    String avatar = '🤷';
    final currentAvatars = _currentBill!.friends.map((f) => f.avatarUrl).toSet();
    final availableAvatars = _animalAvatars.where((a) => !currentAvatars.contains(a)).toList();
    if (availableAvatars.isNotEmpty) {
      avatar = availableAvatars[Random().nextInt(availableAvatars.length)];
    } else {
       avatar = _animalAvatars[Random().nextInt(_animalAvatars.length)];
    }

    final newFriend = Friend(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
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
