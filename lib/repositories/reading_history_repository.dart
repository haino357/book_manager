import 'package:book_manager/database/database_helper.dart';
import 'package:book_manager/models/reading_history.dart';

/// 読書履歴のリポジトリ（データアクセス層）
class ReadingHistoryRepository {

  ReadingHistoryRepository({
    DatabaseHelper? dbHelper,
  }) : _dbHelper = dbHelper ?? DatabaseHelper();
  final DatabaseHelper _dbHelper;

  /// 読書履歴を追加
  Future<ReadingHistory> addHistory({
    required String bookId,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final map = {
      'book_id': bookId,
      'started_at': startedAt?.millisecondsSinceEpoch,
      'completed_at': completedAt?.millisecondsSinceEpoch,
    };
    final id = await _dbHelper.insertHistory(map);
    return ReadingHistory(
      id: id,
      bookId: bookId,
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }

  /// 本IDで読書履歴を取得
  Future<List<ReadingHistory>> getHistoriesByBookId(String bookId) async {
    final maps = await _dbHelper.queryHistoriesByBookId(bookId);
    return maps.map((map) => ReadingHistory.fromMap(map)).toList();
  }

  /// 本IDで読書履歴を削除
  Future<void> deleteHistoriesByBookId(String bookId) async {
    await _dbHelper.deleteHistoriesByBookId(bookId);
  }
}
