import 'package:book_manager/database/database_helper.dart';
import 'package:book_manager/models/book_memo.dart';

/// メモのリポジトリ（データアクセス層）
class BookMemoRepository {
  BookMemoRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper();

  final DatabaseHelper _dbHelper;

  /// メモを追加
  Future<BookMemo> addMemo({
    required String bookId,
    required MemoType type,
    required String content,
    int? page,
    String? section,
    bool? isCompleted,
  }) async {
    final now = DateTime.now();
    final memo = BookMemo(
      id: 0, // AUTOINCREMENTで自動採番
      bookId: bookId,
      type: type,
      content: content,
      page: page,
      section: section,
      isCompleted: isCompleted,
      createdAt: now,
      updatedAt: now,
    );

    final map = memo.toMap();
    map.remove('id'); // AUTOINCREMENTのため除外
    final id = await _dbHelper.insertMemo(map);
    return memo.copyWith(id: id);
  }

  /// 本IDでメモを取得
  Future<List<BookMemo>> getMemosByBookId(String bookId) async {
    final maps = await _dbHelper.queryMemosByBookId(bookId);
    return maps.map((map) => BookMemo.fromMap(map)).toList();
  }

  /// メモを更新
  Future<BookMemo> updateMemo(BookMemo memo) async {
    final updatedMemo = memo.copyWith(updatedAt: DateTime.now());
    await _dbHelper.updateMemo(updatedMemo.toMap());
    return updatedMemo;
  }

  /// メモを削除
  Future<void> deleteMemo(int id) async {
    await _dbHelper.deleteMemo(id);
  }

  /// 本IDでメモを全削除
  Future<void> deleteMemosByBookId(String bookId) async {
    await _dbHelper.deleteMemosByBookId(bookId);
  }
}
