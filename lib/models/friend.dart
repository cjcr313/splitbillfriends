class Friend {
  final String id;
  String name;
  String? avatarUrl;

  Friend({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  // Copia el objeto con campos actualizados (útil para estado inmutable en Flutter)
  Friend copyWith({
    String? id,
    String? name,
    String? avatarUrl,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  // Soporte JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
    };
  }

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
    );
  }
}
