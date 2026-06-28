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
      id: json['ID'] as int,
      name: json['Name'] as String,
      createdAt: json['CreatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['CreatedAt'] as num).toInt() * 1000,
            )
          : DateTime(0), // Fallback
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (json['UpdatedAt'] as num).toInt() * 1000,
            )
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
