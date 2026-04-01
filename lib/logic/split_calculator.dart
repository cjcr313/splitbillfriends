import '../models/bill.dart';

class SplitCalculator {
  
  /// Calcula la cuenta dividiéndola en partes exactamente iguales.
  /// Retorna un mapa donde la llave es el ID del amigo y el valor es la cantidad (tipo double) que debe, redondeada a su moneda local.
  static Map<String, double> calculateEqualSplit(Bill bill) {
    if (bill.friends.isEmpty) return {};
    
    double perPerson = bill.total / bill.friends.length;
    
    Map<String, double> result = {};
    for (var friend in bill.friends) {
      result[friend.id] = bill.currency.roundAmount(perPerson);
    }
    
    // Si quedan remanentes por decimales, aquí opcionalmente podríamos asignables aleatoriamente,
    // pero para un bill-splitter simple basta calcular exacto al centavo y en monedas grandes (CLP) al peso.  
    return result;
  }

  /// Calcula la cuenta basada en lo que consumió explícitamente cada persona.
  static Map<String, double> calculateItemizedSplit(Bill bill) {
    if (bill.friends.isEmpty) return {};

    Map<String, double> totals = {};
    for (var friend in bill.friends) {
      totals[friend.id] = 0.0;
    }

    // Calcular montos base por Item
    for (var item in bill.items) {
      List<String> assigned = item.assignedFriendIds;
      
      // Si el item no fue asignado a nadie personal, se asume que lo pagan todos
      if (assigned.isEmpty) {
        double costPerPerson = item.price / bill.friends.length;
        for (var friend in bill.friends) {
          totals[friend.id] = totals[friend.id]! + costPerPerson;
        }
      } else {
        // Solo calcular entre las partes asignadas
        double costPerPerson = item.price / assigned.length;
        for (var friendId in assigned) {
          if (totals.containsKey(friendId)) {
             totals[friendId] = totals[friendId]! + costPerPerson;
          }
        }
      }
    }

    // Dividir Tax & Tip de forma PROPORCIONAL al subtotal gastado
    double subtotal = bill.subtotal;
    if (subtotal > 0 && bill.taxAndTip > 0) {
      for (var friend in bill.friends) {
        double proportion = totals[friend.id]! / subtotal;
        double additionalAmount = bill.taxAndTip * proportion;
        totals[friend.id] = totals[friend.id]! + additionalAmount;
      }
    } else if (subtotal == 0 && bill.taxAndTip > 0) {
       // Caso borde: nadie gastó un item per-se pero algo se cobra como extra
       double splitExtra = bill.taxAndTip / bill.friends.length;
       for (var friend in bill.friends) {
         totals[friend.id] = totals[friend.id]! + splitExtra;
       }
    }

    // Redondear todo según la moneda actual (USD 2 decimas, CLP sin decimales, etc.)
    Map<String, double> finalTotals = {};
    totals.forEach((id, amount) {
      finalTotals[id] = bill.currency.roundAmount(amount);
    });

    return finalTotals;
  }
}
