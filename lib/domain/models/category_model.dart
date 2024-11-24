import 'package:flutter/material.dart';

const List<Map<String, dynamic>> defaultExpenseCategories = [
  {'id':1,'name': 'Food & Drinks', 'icon': 'food', 'type': 'expense', 'color': 0xFFF44336, 'isDefault': true},  // Red
  {'id':2,'name': 'Transport', 'icon': 'transport', 'type': 'expense', 'color': 0xFF4CAF50, 'isDefault': true},  // Green
  {'id':3,'name': 'Bills', 'icon': 'bills', 'type': 'expense', 'color': 0xFF9C27B0, 'isDefault': true},  // Purple
  {'id':4, 'name': 'Entertainment', 'icon': 'entertainment', 'type': 'expense', 'color': 0xFFFF9800, 'isDefault': true},  // Orange
  {'id':5,'name': 'Health', 'icon': 'health', 'type': 'expense', 'color': 0xFF00BCD4, 'isDefault': true},  // Cyan
  {'id':6,'name': 'Education', 'icon': 'education', 'type': 'expense', 'color': 0xFF795548, 'isDefault': true},  // Brown
  {'id':7,'name': 'Groceries', 'icon': 'groceries', 'type': 'expense', 'color': 0xFF8BC34A, 'isDefault': true},  // Light Green
  {'id':8,'name': 'Travel', 'icon': 'travel', 'type': 'expense', 'color': 0xFF3F51B5, 'isDefault': true},  // Indigo
  {'id':9,'name': 'Fitness', 'icon': 'fitness', 'type': 'expense', 'color': 0xFFE91E63, 'isDefault': true},  // Pink
  {'id':10,'name': 'Clothing', 'icon': 'clothing', 'type': 'expense', 'color': 0xFF009688, 'isDefault': true},  // Teal
  {'id':11,'name': 'Electronics', 'icon': 'electronics', 'type': 'expense', 'color': 0xFF673AB7, 'isDefault': true},  // Deep Purple
  {'id':12,'name': 'Pets', 'icon': 'pets', 'type': 'expense', 'color': 0xFFFFEB3B, 'isDefault': true},  // Yellow
  {'id':13,'name': 'Gifts', 'icon': 'gifts', 'type': 'expense', 'color': 0xFFFF5722, 'isDefault': true},  // Deep Orange
  {'id':14,'name': 'Charity', 'icon': 'charity', 'type': 'expense', 'color': 0xFF607D8B, 'isDefault': true},  // Blue Grey
  {'id':15,'name': 'Other', 'icon': 'other_expense', 'type': 'expense', 'color': 0xFF9E9E9E, 'isDefault': true},  // Grey
];

const List<Map<String, dynamic>> defaultIncomeCategories = [
  {'id':16,'name': 'Salary', 'icon': 'salary', 'type': 'income', 'color': 0xFF66BB6A, 'isDefault': true},  // Green
  {'id':17,'name': 'Business', 'icon': 'business', 'type': 'income', 'color': 0xFF42A5F5, 'isDefault': true},  // Blue
  {'id':18,'name': 'Investments', 'icon': 'investment', 'type': 'income', 'color': 0xFFAB47BC, 'isDefault': true},  // Purple
  {'id':19,'name': 'Gifts', 'icon': 'gift', 'type': 'income', 'color': 0xFFEC407A, 'isDefault': true},  // Pink
  {'id':20,'name': 'Other', 'icon': 'other_income', 'type': 'income', 'color': 0xFF78909C, 'isDefault': true},  // Blue Grey
];

class CategoryModel {
  final int? id;
  final String name;
  final String? icon;
  final String type;
  final DateTime createdAt;
  final Color color;
  final List<SubcategoryModel>? subcategories;
  final bool isDefault;

  CategoryModel({
    this.id,
    required this.name,
    this.icon,
    required this.type,
    required this.createdAt,
    required this.color,
    this.subcategories,
    this.isDefault = false,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int?,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      type: json['type'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      color: Color(json['color'] as int? ?? Colors.blue.value),
      subcategories: json['subcategories'] != null
          ? (json['subcategories'] as List)
              .map((e) => SubcategoryModel.fromJson(e))
              .toList()
          : null,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (icon != null) 'icon': icon,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'color': color.value,
      if (subcategories != null)
        'subcategories': subcategories?.map((e) => e.toJson()).toList(),
      'isDefault': isDefault,
    };
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    String? icon,
    String? type,
    DateTime? createdAt,
    Color? color,
    List<SubcategoryModel>? subcategories,
    bool? isDefault,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      color: color ?? this.color,
      subcategories: subcategories ?? this.subcategories,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class SubcategoryModel {
  final int? id;
  final int categoryId;
  final String name;
  final DateTime createdAt;

  SubcategoryModel({
    this.id,
    required this.categoryId,
    required this.name,
    required this.createdAt,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'] as int?,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  SubcategoryModel copyWith({
    int? id,
    int? categoryId,
    String? name,
    DateTime? createdAt,
  }) {
    return SubcategoryModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
