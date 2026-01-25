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
  }) async {
    final book = Book(
      id: _uuid.v4(),
      title: title,
      author: author,
      isbn: isbn,
      coverUrl: coverUrl,
      status: status,
      createdAt: DateTime.now(),
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
    // 読了ステータスに変更された場合、completedAtを設定
    final updatedBook = book.status == ReadingStatus.completed &&
            book.completedAt == null
        ? book.copyWith(completedAt: DateTime.now())
        : book;

    await _dbHelper.update(updatedBook.toMap());
    return updatedBook;
  }

  /// 本を削除
  Future<void> deleteBook(String id) async {
    await _dbHelper.delete(id);
  }
}
