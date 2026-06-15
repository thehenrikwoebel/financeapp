import 'package:flutter/material.dart';
import 'package:material_symbols_icons/get.dart';

class Category {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final IconData icon;
  final double? totalAmount;
  final int? count;

  Category({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.icon,
    this.totalAmount,
    this.count,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['ID'],
      name: json['Name'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['CreatedAt']),
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['UpdatedAt'])
          : null,
      icon: mapIcon(json['icon']),
      totalAmount: (json['TotalAmount'] as num?)?.toDouble(),
      count: (json['count'] as num?)?.toInt(),
    );
  }

  static IconData mapIcon(String iconName) {
    return SymbolsGet.get(iconName, SymbolStyle.outlined);
  }

  static String iconToString(IconData icon) {
    return SymbolsGet.map.entries
        .firstWhere(
          (e) => e.value == icon.codePoint,
          orElse: () => const MapEntry('help', 0),
        )
        .key;
  }
}
