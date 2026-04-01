import 'package:flutter_test/flutter_test.dart';
import 'package:splitbillfriends/models/bill.dart';
import 'package:splitbillfriends/models/currency.dart';
import 'package:splitbillfriends/models/friend.dart';
import 'package:splitbillfriends/models/item.dart';
import 'package:splitbillfriends/logic/split_calculator.dart';

void main() {
  group('SplitCalculator Tests (Currency & Itemized)', () {
    test('calculateEqualSplit divides total equally in CLP (No decimals)', () {
      final bill = Bill(
        id: '1',
        date: DateTime.now(),
        currency: AppCurrency.clp,
        friends: [
          Friend(id: 'a1', name: 'Ami 1'),
          Friend(id: 'a2', name: 'Ami 2'),
          Friend(id: 'a3', name: 'Ami 3'),
        ],
        items: [
          Item(id: 'i1', name: 'Cuenta grande', price: 10000), // 10,000 / 3 = 3333.33 -> 3333
        ],
        taxAndTip: 0,
      );

      final result = SplitCalculator.calculateEqualSplit(bill);

      // CLP no tiene decimales en redondeo final
      expect(result['a1'], 3333.0);
      expect(result['a2'], 3333.0); 
      expect(result['a3'], 3333.0);
    });

    test('calculateEqualSplit divides total equally in USD (2 decimals)', () {
      final bill = Bill(
        id: '1',
        date: DateTime.now(),
        currency: AppCurrency.usd,
        friends: [
          Friend(id: 'a1', name: 'Ami 1'),
          Friend(id: 'a2', name: 'Ami 2'),
          Friend(id: 'a3', name: 'Ami 3'),
        ],
        items: [
          Item(id: 'i1', name: 'Dinner', price: 10.0), // 10 / 3 = 3.3333 -> 3.33
        ],
        taxAndTip: 0,
      );

      final result = SplitCalculator.calculateEqualSplit(bill);

      // USD mantiene 2 decimales
      expect(result['a1'], 3.33);
      expect(result['a2'], 3.33); 
      expect(result['a3'], 3.33);
    });

    test('calculateItemizedSplit divides proportionally to items consumed', () {
      final bill = Bill(
        id: '1',
        date: DateTime.now(),
        currency: AppCurrency.clp,
        friends: [
          Friend(id: 'a1', name: 'Ami 1'),
          Friend(id: 'a2', name: 'Ami 2'),
          Friend(id: 'a3', name: 'Ami 3'),
        ],
        items: [
          // Ami 1 consumió solo Hamburguesa
          Item(id: 'i1', name: 'Hamburguesa', price: 5000, assignedFriendIds: ['a1']),
          // Ami 2 y 3 compartieron una Pizzeta
          Item(id: 'i2', name: 'Pizzeta', price: 6000, assignedFriendIds: ['a2', 'a3']),
          // Bebida compartida por todos (Sin asignar a nadie explícitamente)
          Item(id: 'i3', name: 'Gaseosa c/Refill', price: 3000, assignedFriendIds: []),
        ],
        taxAndTip: 1400, // 10% del subtotal (14000) de propina
      );

      final result = SplitCalculator.calculateItemizedSplit(bill);

      // En CLP sin decimales
      expect(result['a1'], 6600.0);
      expect(result['a2'], 4400.0);
      expect(result['a3'], 4400.0);
    });
  });
}
