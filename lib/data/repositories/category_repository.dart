import '../../domain/models/transaction_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/database/database_helper.dart';
import '../../domain/models/category_model.dart';
import '../services/transaction_check_service.dart';



class CategoryRepository {
  final DatabaseHelper _db = DatabaseHelper();
   final TransactionCheckService _transactionCheckService = TransactionCheckService();


  Future<List<CategoryModel>> getCategories({String? type}) async {
    final defaultCategories = type == TransactionType.income.name
        ? defaultIncomeCategories
        : defaultExpenseCategories;
    final db = await _db.database;
    final List<Map<String, dynamic>> categories = await db.query(
      'categories',
      where: type != null ? 'type = ?' : null,
      whereArgs: type != null ? [type] : null,
      orderBy: 'name ASC',
    );
    final allcategories = [...defaultCategories, ...categories];
    final List<CategoryModel> categoryList = [];
    for (var category in allcategories) {
      final List<Map<String, dynamic>> subcategories = await db.query(
        'subcategories',
        where: 'category_id = ?',
        whereArgs: [category['id']],
        orderBy: 'name ASC',
      );

      categoryList.add(
        CategoryModel.fromJson({
          ...category,
          'subcategories': subcategories,
        }),
      );
    }

    return categoryList;
  }

  Future<CategoryModel> getCategoryById(int id) async {
    final defaultCategories = [
      ...defaultExpenseCategories,
      ...defaultIncomeCategories
    ];
    if (defaultCategories.any((category) => category['id'] == id)) {
      return CategoryModel.fromJson(
          defaultCategories.firstWhere((category) => category['id'] == id));
    }

    final db = await _db.database;
    final List<Map<String, dynamic>> categories = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (categories.isEmpty) {
      throw Exception('Category not found');
    }

    final List<Map<String, dynamic>> subcategories = await db.query(
      'subcategories',
      where: 'category_id = ?',
      whereArgs: [id],
      orderBy: 'name ASC',
    );

    return CategoryModel.fromJson({
      ...categories.first,
      'subcategories': subcategories,
    });
  }

  Future<bool> categoryExists(String name, String type) async {
    final defaultCategories = type == TransactionType.income.name
        ? defaultIncomeCategories
        : defaultExpenseCategories;
    if (defaultCategories.any(
        (category) => category['name'] == name && category['type'] == type)) {
      return true;
    }
    final db = await _db.database;
    final result = await db.query(
      'categories',
      where: 'name = ? AND type = ?',
      whereArgs: [name, type],
    );
    return result.isNotEmpty;
  }

  Future<int> addCategory(CategoryModel category) async {
    try {
      final db = await _db.database;

      // Check if category already exists
      final exists = await categoryExists(category.name, category.type);
      if (exists) {
        throw Exception(
            'Category with name "${category.name}" already exists for type "${category.type}"');
      }

      // Create the category map with null-safe values
      final categoryMap = {
        'name': category.name,
        'type': category.type,
        'color': category.color.value,
        'created_at': category.createdAt.toIso8601String(),
      };

      // Only add icon if it's not null
      if (category.icon != null) {
        categoryMap['icon'] = category.icon!;
      }

      // print('Attempting to insert category with data: $categoryMap');

      final id = await db.insert(
        'categories',
        categoryMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // print('Successfully inserted category with ID: $id');

      return id;
    } catch (e) {
      // print('Error adding category: $e');
      // print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<int> addSubcategory(SubcategoryModel subcategory) async {
    //add try catch block
    final db = await _db.database;
    return await db.insert('subcategories', {
      'category_id': subcategory.categoryId,
      'name': subcategory.name,
      'created_at': subcategory.createdAt.toIso8601String(),
    });
  }

  Future<bool> updateCategory(CategoryModel category) async {
    final db = await _db.database;
    final result = await db.update(
      'categories',
      {
        'name': category.name,
        'icon': category.icon,
        'type': category.type,
        'color': category.color.value,
      },
      where: 'id = ?',
      whereArgs: [category.id],
    );
    return result > 0;
  }

  Future<bool> updateSubcategory(SubcategoryModel subcategory) async {
    final db = await _db.database;
    final result = await db.update(
      'subcategories',
      {'name': subcategory.name},
      where: 'id = ?',
      whereArgs: [subcategory.id],
    );
    return result > 0;
  }

   Future<bool> deleteCategory(int id) async {
    // Check for linked transactions
    final hasTransactions = await _transactionCheckService.hasTransactionsForCategory(id);
    if (hasTransactions) {
      throw Exception('Cannot delete category: It has linked transactions');
    }

    final db = await _db.database;
    // First delete all subcategories
    await db.delete(
      'subcategories',
      where: 'category_id = ?',
      whereArgs: [id],
    );

    final result = await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }

  Future<bool> deleteSubcategory(int id) async {
    // Check for linked transactions
    final hasTransactions = await _transactionCheckService.hasTransactionsForSubcategory(id);
    if (hasTransactions) {
      throw Exception('Cannot delete subcategory: It has linked transactions');
    }

    final db = await _db.database;
    final result = await db.delete(
      'subcategories',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }
}
