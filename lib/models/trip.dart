import 'packing_item.dart';

class Trip {
  final String id;
  final String title;
  final String destination;
  final DateTime departureDate;
  final DateTime? returnDate;
  final String templateType;
  final double maxWeightKg;
  final List<PackingItem> items;

  const Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.departureDate,
    this.returnDate,
    required this.templateType,
    this.maxWeightKg = 23.0,
    required this.items,
  });

  int get totalItems => items.length;
  int get packedItems => items.where((item) => item.isPacked).length;
  int get remainingItems => totalItems - packedItems;

  double get packedPercentage =>
      totalItems == 0 ? 0.0 : (packedItems / totalItems).clamp(0.0, 1.0);

  double get totalWeightKg => items.fold(
        0.0,
        (sum, item) => sum + (item.weightKg * item.quantity),
      );

  double get packedWeightKg => items.where((item) => item.isPacked).fold(
        0.0,
        (sum, item) => sum + (item.weightKg * item.quantity),
      );

  bool get isOverweight => totalWeightKg > maxWeightKg;

  double get excessWeightKg {
    final diff = totalWeightKg - maxWeightKg;
    return diff > 0 ? diff : 0.0;
  }

  double get remainingWeightKg {
    final diff = maxWeightKg - totalWeightKg;
    return diff > 0 ? diff : 0.0;
  }

  int get daysUntilDeparture {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final depDay = DateTime(
      departureDate.year,
      departureDate.month,
      departureDate.day,
    );
    return depDay.difference(today).inDays;
  }

  List<String> get categories {
    final set = <String>{};
    for (final item in items) {
      set.add(item.category);
    }
    final list = set.toList();
    list.sort();
    return list;
  }

  List<PackingItem> getItemsByCategory(String category) {
    return items.where((item) => item.category == category).toList();
  }

  Trip copyWith({
    String? id,
    String? title,
    String? destination,
    DateTime? departureDate,
    DateTime? returnDate,
    String? templateType,
    double? maxWeightKg,
    List<PackingItem>? items,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      templateType: templateType ?? this.templateType,
      maxWeightKg: maxWeightKg ?? this.maxWeightKg,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'departureDate': departureDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'templateType': templateType,
      'maxWeightKg': maxWeightKg,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'My Trip',
      destination: json['destination'] as String? ?? '',
      departureDate: json['departureDate'] != null
          ? DateTime.tryParse(json['departureDate'] as String) ??
              DateTime.now().add(const Duration(days: 7))
          : DateTime.now().add(const Duration(days: 7)),
      returnDate: json['returnDate'] != null
          ? DateTime.tryParse(json['returnDate'] as String)
          : null,
      templateType: json['templateType'] as String? ?? 'Custom',
      maxWeightKg: (json['maxWeightKg'] as num?)?.toDouble() ?? 23.0,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => PackingItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
