import '../../core/database/database_helper.dart';

class TransactionCheckService {
  final DatabaseHelper _db = DatabaseHelper();

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
}
