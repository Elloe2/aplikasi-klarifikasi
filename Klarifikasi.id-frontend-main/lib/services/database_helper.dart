import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName =
      "klarifikasi_v4.db"; // Changed name to force fresh DB
  static const _databaseVersion = 2;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Handle migration
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration to version 2: Add age and education columns
      await db.execute('ALTER TABLE users ADD COLUMN age INTEGER');
      await db.execute('ALTER TABLE users ADD COLUMN education TEXT');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Table for saved analyses
    await db.execute('''
      CREATE TABLE saved_analyses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        claim TEXT,
        verdict TEXT,
        explanation TEXT,
        confidence REAL,
        user_note TEXT,
        source_url TEXT,
        analysis TEXT,
        saved_at TEXT,
        is_favorite INTEGER DEFAULT 0
      )
    ''');

    // Table for local users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        email TEXT UNIQUE,
        password TEXT,
        full_name TEXT,
        age INTEGER,
        education TEXT,
        created_at TEXT
      )
    ''');
  }

  // --- Generic Helpers ---

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAll(
    String table, {
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(table, orderBy: orderBy);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> row,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.update(table, row, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // --- Auth Specific Helpers ---

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }
}
