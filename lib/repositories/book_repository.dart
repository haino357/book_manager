import 'package:book_manager/database/database_helper.dart';
import 'package:book_manager/models/book.dart';
import 'package:uuid/uuid.dart';

/// 本のリポジトリ（データアクセス層）
class BookRepository {

  BookRepository({
    DatabaseHelper? dbHelper,
    Uuid? uuid,
  })  : _dbHelper = dbHelper ?? DatabaseHelper(),
        _uuid = uuid ?? const Uuid();
  final DatabaseHelper _dbHelper;
  final Uuid _uuid;

  /// 本を追加
  Future<Book> addBook({
    required String title,
    required String author,
    String? isbn,
    String? coverUrl,
    ReadingStatus status = ReadingStatus.unread,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final now = DateTime.now();

    // ステータスに応じて日付を自動設定（明示的に渡されていない場合）
    DateTime? effectiveStartedAt = startedAt;
    DateTime? effectiveCompletedAt = completedAt;
    if (status == ReadingStatus.reading) {
      effectiveStartedAt ??= now;
    } else if (status == ReadingStatus.completed) {
      effectiveStartedAt ??= now;
      effectiveCompletedAt ??= now;
    }

    final book = Book(
      id: _uuid.v4(),
      title: title,
      author: author,
      isbn: isbn,
      coverUrl: coverUrl,
      status: status,
      createdAt: now,
      startedAt: effectiveStartedAt,
      completedAt: effectiveCompletedAt,
    );

    await _dbHelper.insert(book.toMap());
    return book;
  }

  /// 全ての本を取得
  Future<List<Book>> getAllBooks() async {
    final maps = await _dbHelper.queryAll();
    return maps.map((map) => Book.fromMap(map)).toList();
  }

  /// IDで本を取得
  Future<Book?> getBookById(String id) async {
    final map = await _dbHelper.queryById(id);
    return map != null ? Book.fromMap(map) : null;
  }

  /// ステータスで本を取得
  Future<List<Book>> getBooksByStatus(ReadingStatus status) async {
    final maps = await _dbHelper.queryByStatus(status.value);
    return maps.map((map) => Book.fromMap(map)).toList();
  }

  /// 本を更新
  Future<Book> updateBook(Book book) async {
    Book updatedBook = book;

    // reading に変更 → startedAt が null なら自動設定
    if (book.status == ReadingStatus.reading && book.startedAt == null) {
      updatedBook = updatedBook.copyWith(startedAt: DateTime.now());
    }

    // completed に変更 → completedAt が null なら自動設定
    if (book.status == ReadingStatus.completed && book.completedAt == null) {
      updatedBook = updatedBook.copyWith(completedAt: DateTime.now());
    }

    // completed 以外に変更 → completedAt クリア
    if (book.status != ReadingStatus.completed && book.completedAt != null) {
      updatedBook = updatedBook.copyWith(completedAt: null);
    }

    // unread に変更 → startedAt もクリア
    if (book.status == ReadingStatus.unread && book.startedAt != null) {
      updatedBook = updatedBook.copyWith(startedAt: null);
    }

    await _dbHelper.update(updatedBook.toMap());
    return updatedBook;
  }

  /// 本を削除
  Future<void> deleteBook(String id) async {
    await _dbHelper.delete(id);
  }
}
