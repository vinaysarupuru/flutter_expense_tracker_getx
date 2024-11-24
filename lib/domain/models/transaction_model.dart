import 'dart:convert';

enum TransactionType { expense, income }

class TransactionModel {
  final int? id;
  final int userId;
  final int categoryId;
  final int? subcategoryId;
  final double amount;
  final TransactionType type;
  final String title;
  final String? description;
  final List<String> tags;
  final DateTime date;
  final DateTime createdAt;

  TransactionModel({
    this.id,
    required this.userId,
    required this.categoryId,
    this.subcategoryId,
    required this.amount,
    required this.type,
    required this.title,
    this.description,
    List<String>? tags,
    required this.date,
    required this.createdAt,
  }) : tags = tags ?? [];

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    List<String> parseTags(dynamic tagsJson) {
      if (tagsJson == null) return [];
      try {
        final List<dynamic> parsed = jsonDecode(tagsJson);
        return parsed.map((e) => e.toString()).toList();
      } catch (e) {
        return [];
      }
    }

    return TransactionModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int,
      categoryId: json['category_id'] as int,
      subcategoryId: json['subcategory_id'] as int?,
      amount: json['amount'] as double,
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String?,
      tags: parseTags(json['tags']),
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'subcategory_id': subcategoryId,
      'amount': amount,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'tags': tags.isEmpty ? null : jsonEncode(tags),
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  TransactionModel copyWith({
    int? id,
    int? userId,
    int? categoryId,
    int? subcategoryId,
    double? amount,
    TransactionType? type,
    String? title,
    String? description,
    List<String>? tags,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? List.from(this.tags),
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
