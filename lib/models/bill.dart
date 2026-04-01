import 'friend.dart';
import 'item.dart';
import 'currency.dart';

class Bill {
  final String id;
  DateTime date;
  String title; // Nuevo campo: Permite etiquetar "Cena en McDonald's"
  List<Friend> friends;
  List<Item> items;
  
  // Monto acumulado de impuestos o propinas
  double taxAndTip;
  
  // Especificamos la moneda por defecto al crear una cuenta
  AppCurrency currency;

  Bill({
    required this.id,
    required this.date,
    this.title = '',
    List<Friend>? friends,
    List<Item>? items,
    this.taxAndTip = 0.0,
    this.currency = AppCurrency.clp,
  })  : friends = friends ?? [],
        items = items ?? [];

  // El subtotal es solo la suma del precio de todos los items
  double get subtotal => items.fold(0, (sum, item) => sum + item.price);
  
  // El total general que paga la mesa (items + propinas/impuestos)
  double get total => subtotal + taxAndTip;

  // Serializar a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'taxAndTip': taxAndTip,
      'currency': currency.code, // Guardamos el código ej 'CLP'
      'friends': friends.map((f) => f.toJson()).toList(),
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  // Re-ensamblar la boleta desde JSON
  factory Bill.fromJson(Map<String, dynamic> json) {
    final curCode = json['currency'] as String? ?? 'CLP';
    // Buscamos el Enum coincidente
    final currencyEnum = AppCurrency.values.firstWhere(
      (e) => e.code == curCode, 
      orElse: () => AppCurrency.clp
    );

    return Bill(
      id: json['id'],
      date: DateTime.parse(json['date']),
      title: json['title'] ?? '',
      taxAndTip: (json['taxAndTip'] as num).toDouble(),
      currency: currencyEnum,
      friends: (json['friends'] as List? ?? []).map((e) => Friend.fromJson(e)).toList(),
      items: (json['items'] as List? ?? []).map((e) => Item.fromJson(e)).toList(),
    );
  }
}
