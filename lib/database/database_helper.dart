import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// SQLiteデータベースヘルパー
class DatabaseHelper {

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  DatabaseHelper._internal();
  static const _databaseName = 'book_manager.db';
  static const _databaseVersion = 4;

  static const tableName = 'books';
  static const readingHistoriesTable = 'reading_histories';
  static const bookMemosTable = 'book_memos';

  // シングルトンインスタンス
  static DatabaseHelper? _instance;
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT,
        isbn TEXT,
        cover_url TEXT,
        memo TEXT,
        status INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        started_at INTEGER,
        completed_at INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE $readingHistoriesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id TEXT NOT NULL,
        started_at INTEGER,
        completed_at INTEGER,
        FOREIGN KEY (book_id) REFERENCES $tableName (id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE $bookMemosTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id TEXT NOT NULL,
        type INTEGER NOT NULL DEFAULT 0,
        content TEXT NOT NULL,
        page INTEGER,
        section TEXT,
        is_completed INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (book_id) REFERENCES $tableName (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE $tableName ADD COLUMN started_at INTEGER',
      );
      await db.execute('''
        CREATE TABLE $readingHistoriesTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          book_id TEXT NOT NULL,
          started_at INTEGER,
          completed_at INTEGER,
          FOREIGN KEY (book_id) REFERENCES $tableName (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE $tableName ADD COLUMN memo TEXT',
      );
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE $bookMemosTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          book_id TEXT NOT NULL,
          type INTEGER NOT NULL DEFAULT 0,
          content TEXT NOT NULL,
          page INTEGER,
          section TEXT,
          is_completed INTEGER,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          FOREIGN KEY (book_id) REFERENCES $tableName (id) ON DELETE CASCADE
        )
      ''');
      // 既存のbook.memoデータをbook_memosテーブルに移行
      final books = await db.query(
        tableName,
        columns: ['id', 'memo', 'created_at'],
        where: 'memo IS NOT NULL AND memo != ?',
        whereArgs: [''],
      );
      for (final book in books) {
        final now = DateTime.now().millisecondsSinceEpoch;
        await db.insert(bookMemosTable, {
          'book_id': book['id'],
          'type': 0, // note
          'content': book['memo'],
          'created_at': book['created_at'] ?? now,
          'updated_at': now,
        });
      }
    }
  }

  /// 本を挿入
  Future<int> insert(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(tableName, row);
  }

  /// 全ての本を取得
  Future<List<Map<String, dynamic>>> queryAll() async {
    final db = await database;
    return await db.query(
      tableName,
      orderBy: 'created_at DESC',
    );
  }

  /// IDで本を取得
  Future<Map<String, dynamic>?> queryById(String id) async {
    final db = await database;
    final results = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// ステータスで本を取得
  Future<List<Map<String, dynamic>>> queryByStatus(int status) async {
    final db = await database;
    return await db.query(
      tableName,
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'created_at DESC',
    );
  }

  /// 本を更新
  Future<int> update(Map<String, dynamic> row) async {
    final db = await database;
    final id = row['id'];
    return await db.update(
      tableName,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 本を削除
  Future<int> delete(String id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 読書履歴を挿入
  Future<int> insertHistory(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(readingHistoriesTable, row);
  }

  /// 本IDで読書履歴を取得
  Future<List<Map<String, dynamic>>> queryHistoriesByBookId(
    String bookId,
  ) async {
    final db = await database;
    return await db.query(
      readingHistoriesTable,
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'id ASC',
    );
  }

  /// 本IDで読書履歴を削除
  Future<int> deleteHistoriesByBookId(String bookId) async {
    final db = await database;
    return await db.delete(
      readingHistoriesTable,
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
  }

  /// メモを挿入
  Future<int> insertMemo(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(bookMemosTable, row);
  }

  /// 本IDでメモを取得
  Future<List<Map<String, dynamic>>> queryMemosByBookId(
    String bookId,
  ) async {
    final db = await database;
    return await db.query(
      bookMemosTable,
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'created_at DESC',
    );
  }

  /// メモを更新
  Future<int> updateMemo(Map<String, dynamic> row) async {
    final db = await database;
    final id = row['id'];
    return await db.update(
      bookMemosTable,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// メモを削除
  Future<int> deleteMemo(int id) async {
    final db = await database;
    return await db.delete(
      bookMemosTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 本IDでメモを全削除
  Future<int> deleteMemosByBookId(String bookId) async {
    final db = await database;
    return await db.delete(
      bookMemosTable,
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
  }
}
