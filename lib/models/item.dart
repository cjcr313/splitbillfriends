class Item {
  final String id;
  String name;
  double price;
  
  // IDs de los amigos a quienes se asignará el costo de este item (vacío = no asignado o de uso común)
  List<String> assignedFriendIds;

  Item({
    required this.id,
    required this.name,
    required this.price,
    this.assignedFriendIds = const [],
  });

  Item copyWith({
    String? id,
    String? name,
    double? price,
    List<String>? assignedFriendIds,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      assignedFriendIds: assignedFriendIds ?? this.assignedFriendIds,
    );
  }

  // Soporte JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'assignedFriendIds': assignedFriendIds,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      assignedFriendIds: List<String>.from(json['assignedFriendIds'] ?? []),
    );
  }
}
