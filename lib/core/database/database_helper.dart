import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      String path = join(databasesPath, AppConstants.dbName);

      final db = await openDatabase(
        path,
        version: AppConstants.dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: (db) async {
          // Print schema information
          // final tables = await db.query('sqlite_master', columns: ['name', 'sql']);
          // for (var table in tables) {
          //   print('Table ${table['name']}: ${table['sql']}');
          // }
        },
      );

      return db;
    } catch (e) {
      // print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      // print('Creating database tables for version $version');

      // Users table
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL,
          name TEXT NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      // print('Users table created successfully');

      // Categories table with nullable icon
      await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          icon TEXT,
          type TEXT NOT NULL,
          color INTEGER DEFAULT 4280391411,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      
      // Set the auto-increment start value to 30
      await db.execute('INSERT INTO sqlite_sequence(name,seq) VALUES("categories",29)');
      // print('Categories table created successfully');

      // Subcategories table
      await db.execute('''
        CREATE TABLE subcategories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (category_id) REFERENCES categories (id)
        )
      ''');
      // print('Subcategories table created successfully');

      // Transactions table
      await db.execute('''
        CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          category_id INTEGER NOT NULL,
          subcategory_id INTEGER,
          amount REAL NOT NULL,
          type TEXT NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          tags TEXT,
          date TIMESTAMP NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users (id),
          FOREIGN KEY (category_id) REFERENCES categories (id),
          FOREIGN KEY (subcategory_id) REFERENCES subcategories (id)
        )
      ''');
      // print('Transactions table created successfully');

      // Insert default categories
      // await _insertDefaultCategories(db);
      // print('Default categories inserted successfully');
    } catch (e) {
      // print('Error creating database: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      // print('Upgrading database from version $oldVersion to $newVersion');

      if (oldVersion < 2) {
        // Add color column to categories table if it doesn't exist
        await db.execute('''
          ALTER TABLE categories
          ADD COLUMN color INTEGER DEFAULT 4280391411
        ''');
        // print('Added color column to categories table');
      }

      if (oldVersion < 3) {
        // Create a temporary table with the correct schema
        await db.execute('''
          CREATE TABLE categories_temp (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            icon TEXT,
            type TEXT NOT NULL,
            color INTEGER DEFAULT 4280391411,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        // Copy data from the old table to the new one
        await db.execute('''
          INSERT INTO categories_temp (id, name, icon, type, color, created_at)
          SELECT id, name, icon, type, color, created_at FROM categories
        ''');

        // Drop the old table
        await db.execute('DROP TABLE categories');

        // Rename the new table to the original name
        await db.execute('ALTER TABLE categories_temp RENAME TO categories');

        // print('Updated categories table schema to make icon nullable');
      }

      if (oldVersion < 4) {
        // Add title and tags columns to transactions table
        await db.execute('ALTER TABLE transactions ADD COLUMN title TEXT NOT NULL DEFAULT "Untitled"');
        await db.execute('ALTER TABLE transactions ADD COLUMN tags TEXT');
      }
    } catch (e) {
      // print('Error during database upgrade: $e');
      rethrow;
    }
  }

  // Future<void> _insertDefaultCategories(Database db) async {
  //   final Batch batch = db.batch();

  //   for (var category in [
  //     ...defaultExpenseCategories,
  //     ...defaultExpenseCategories
  //   ]) {
  //     batch.insert('categories', category);
  //   }

  //   await batch.commit();
  // }

  // Added method to reset database instance
  static void resetDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
