class PackingItem {
  final String id;
  final String name;
  final String category;
  final bool isPacked;
  final double weightKg;
  final int quantity;
  final String? notes;

  const PackingItem({
    required this.id,
    required this.name,
    required this.category,
    this.isPacked = false,
    this.weightKg = 0.0,
    this.quantity = 1,
    this.notes,
  });

  PackingItem copyWith({
    String? id,
    String? name,
    String? category,
    bool? isPacked,
    double? weightKg,
    int? quantity,
    String? notes,
  }) {
    return PackingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      isPacked: isPacked ?? this.isPacked,
      weightKg: weightKg ?? this.weightKg,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'isPacked': isPacked,
      'weightKg': weightKg,
      'quantity': quantity,
      'notes': notes,
    };
  }

  factory PackingItem.fromJson(Map<String, dynamic> json) {
    return PackingItem(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      isPacked: json['isPacked'] as bool? ?? false,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      notes: json['notes'] as String?,
    );
  }
}
