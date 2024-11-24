import '../../core/database/database_helper.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/models/category_model.dart';
import 'dart:convert';

import 'category_repository.dart';


class TransactionRepository {
  final DatabaseHelper _db = DatabaseHelper();
  final CategoryRepository _categoryRepository = CategoryRepository();

  Future<List<TransactionModel>> getTransactions({
    required int userId,
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
    int? offset,
  }) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> results = await db.query(
      'transactions',
      where: 'user_id = ? AND date BETWEEN ? AND ?',
      whereArgs: [userId, startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );

    return results.map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<Map<String, double>> getMonthlyTotals({
    required int userId,
    required DateTime month,
  }) async {
    final db = await _db.database;
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT type, SUM(amount) as total
      FROM transactions
      WHERE user_id = ? AND date BETWEEN ? AND ?
      GROUP BY type
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);

    double income = 0.0;
    double expense = 0.0;

    for (var row in results) {
      if (row['type'] == 'income') {
        income = row['total'] as double;
      } else {
        expense = row['total'] as double;
      }
    }

    return {
      'income': income,
      'expense': expense,
    };
  }

  Future<Map<String, double>> getCategoryTotals({
    required int userId,
    required DateTime startDate,
    required DateTime endDate,
    required String type,
    int? categoryId,
  }) async {
    final db = await _db.database;
    String query;
    List<dynamic> args;

    if (categoryId != null) {
      // Get subcategory totals for a specific category
      query = '''
        SELECT s.name, COALESCE(SUM(t.amount), 0) as total
        FROM subcategories s
        LEFT JOIN transactions t ON t.subcategory_id = s.id
          AND t.user_id = ?
          AND t.date BETWEEN ? AND ?
          AND t.type = ?
        WHERE s.category_id = ?
        GROUP BY s.id, s.name
      ''';
      args = [userId, startDate.toIso8601String(), endDate.toIso8601String(), type, categoryId];
    } else {
      // Get category totals
      query = '''
        SELECT c.name, COALESCE(SUM(t.amount), 0) as total
        FROM categories c
        LEFT JOIN transactions t ON t.category_id = c.id
          AND t.user_id = ?
          AND t.date BETWEEN ? AND ?
          AND t.type = ?
        WHERE c.type = ?
        GROUP BY c.id, c.name
      ''';
      args = [userId, startDate.toIso8601String(), endDate.toIso8601String(), type, type];
    }

    final List<Map<String, dynamic>> results = await db.rawQuery(query, args);
    return Map.fromEntries(
      results.map((row) => MapEntry(row['name'] as String, row['total'] as double)),
    );
  }

  Future<String> getCategoryName(int categoryId) async {
    try {
      final category = await _categoryRepository.getCategoryById(categoryId);
      return category.name;
    } catch (e) {
      return 'Unknown Category';
    }
  }

  Future<CategoryModel?> getCategory(int categoryId) async {
    try {
      return await _categoryRepository.getCategoryById(categoryId);
    } catch (e) {
      return null;
    }
  }

  Future<int> addTransaction(TransactionModel transaction) async {
    final db = await _db.database;
    return await db.insert('transactions', transaction.toJson());
  }

  Future<bool> updateTransaction(TransactionModel transaction) async {
    final db = await _db.database;
    final result = await db.update(
      'transactions',
      transaction.toJson(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
    return result > 0;
  }

  Future<bool> deleteTransaction(int id) async {
    final db = await _db.database;
    final result = await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }

  Future<bool> hasTransactionsForCategory(int categoryId) async {
    final db = await _db.database;
    final result = await db.query(
      'transactions',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<bool> hasTransactionsForSubcategory(int subcategoryId) async {
    final db = await _db.database;
    final result = await db.query(
      'transactions',
      where: 'subcategory_id = ?',
      whereArgs: [subcategoryId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<List<String>> getAllTags() async {
    final db = await _db.database;
    final List<Map<String, dynamic>> results = await db.query('transactions');
    
    // Collect all tags from transactions
    final Set<String> uniqueTags = {};
    for (var row in results) {
      if (row['tags'] != null) {
        final List<dynamic> tags = json.decode(row['tags']);
        uniqueTags.addAll(tags.cast<String>());
      }
    }
    
    return uniqueTags.toList()..sort();
  }
}
